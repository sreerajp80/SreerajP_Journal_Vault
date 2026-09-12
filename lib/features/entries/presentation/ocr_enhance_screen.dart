import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/image_edit_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/ocr_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/image_edit_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_capture_downscaler.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_enhancer.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

enum _EnhanceToolTab { none, filters, adjust }

/// Interactive screen for rotating, cropping, filtering, and adjusting brightness/contrast
/// of document photos with real-time live OCR text recognition preview.
class OcrEnhanceScreen extends ConsumerStatefulWidget {
  const OcrEnhanceScreen({
    super.key,
    required this.imagePath,
    this.ocrService,
    this.ocrEnhancer,
    this.imageEditService,
    this.captureDownscaler,
  });

  /// Path to the captured or imported document photo.
  final String imagePath;

  /// Optional injected OCR service (used for testing).
  final OcrService? ocrService;

  /// Optional injected image enhancer (used for testing).
  final OcrEnhancer? ocrEnhancer;

  /// Optional injected image cropper (used for testing).
  final ImageEditService? imageEditService;

  /// Optional injected capture downscaler (used for testing).
  final OcrCaptureDownscaler? captureDownscaler;

  @override
  ConsumerState<OcrEnhanceScreen> createState() => _OcrEnhanceScreenState();
}

class _OcrEnhanceScreenState extends ConsumerState<OcrEnhanceScreen> {
  late String _currentSourcePath;
  String? _enhancedOutputPath;
  Uint8List? _previewBytes;

  int _rotationAngle = 0;
  int _brightness = 0;
  int _contrast = 0;
  OcrEnhanceFilter _selectedFilter = OcrEnhanceFilter.original;
  bool _invert = false;
  String _selectedLanguage = 'eng+mal';

  _EnhanceToolTab _activeTab = _EnhanceToolTab.none;
  bool _isEnhancing = true;
  bool _isScanning = false;
  bool _isTextPanelExpanded = true;
  String _recognizedText = '';
  int _wordCount = 0;

  Timer? _debounceTimer;
  final List<String> _tempFilesToDelete = [];

  /// Labels each recognition run. Only the newest one is kept; older ones are
  /// cancelled so they do not hold the single recognition queue.
  int _ocrRequestCounter = 0;
  final Set<int> _pendingOcrRequests = <int>{};

  @override
  void initState() {
    super.initState();
    _currentSourcePath = widget.imagePath;
    unawaited(_prepareMaster());
  }

  /// Shrinks the full-resolution capture once, natively, into the working copy
  /// every later step reads from. The camera shoots at full sensor size, which
  /// is 50 MP or more on a modern phone; decoding that in Dart would cost
  /// hundreds of megabytes per copy, and the enhance pipeline makes several.
  ///
  /// This is also where EXIF rotation is applied, exactly once, so a photo
  /// taken sideways arrives upright.
  Future<void> _prepareMaster() async {
    final OcrCaptureDownscaler downscaler =
        widget.captureDownscaler ?? ref.read(ocrCaptureDownscalerProvider);

    String master;
    try {
      master = await downscaler.downscale(widget.imagePath);
    } catch (e, st) {
      AppLogger.error(
        'OcrEnhanceScreen: capture preparation failed',
        error: e,
        stackTrace: st,
      );
      master = widget.imagePath;
    }

    if (!mounted) return;

    // A working copy is ours to clean up; the original capture is not.
    if (master != widget.imagePath) _tempFilesToDelete.add(master);

    _currentSourcePath = master;
    _scheduleEnhancement(immediate: true);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    // Nobody is waiting for these results any more, so let the platform drop
    // them instead of making the next screen wait for the processor.
    _cancelPendingOcr();
    // Clean up temporary processed files off the UI thread, so closing this
    // screen is instant even when many preview files were made.
    unawaited(_deleteTempFiles(List<String>.of(_tempFilesToDelete)));
    _tempFilesToDelete.clear();
    super.dispose();
  }

  /// Tells the OCR service to drop every recognition run still in flight.
  void _cancelPendingOcr() {
    if (_pendingOcrRequests.isEmpty) return;
    final ids = List<int>.of(_pendingOcrRequests);
    _pendingOcrRequests.clear();
    final OcrService ocrService =
        widget.ocrService ?? ref.read(ocrServiceProvider);
    unawaited(ocrService.cancelRequests(ids));
  }

  Future<void> _deleteTempFiles(List<String> paths) async {
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }

  void _scheduleEnhancement({bool immediate = false}) {
    _debounceTimer?.cancel();
    if (immediate) {
      _applyEnhancements();
    } else {
      _debounceTimer = Timer(const Duration(milliseconds: 250), () {
        if (mounted) _applyEnhancements();
      });
    }
  }

  Future<void> _applyEnhancements() async {
    if (!mounted) return;

    setState(() {
      _isEnhancing = true;
      _recognizedText = '';
      _wordCount = 0;
      _isScanning = true;
    });

    try {
      final OcrEnhancer enhancer =
          widget.ocrEnhancer ?? ref.read(ocrEnhancerProvider);
      final targetPath = p.join(
        Directory.systemTemp.path,
        'ocr_enh_${DateTime.now().microsecondsSinceEpoch}.png',
      );
      _tempFilesToDelete.add(targetPath);

      final result = await enhancer.enhance(
        OcrEnhanceParams(
          sourcePath: _currentSourcePath,
          targetPath: targetPath,
          rotationAngle: _rotationAngle,
          brightness: _brightness,
          contrast: _contrast,
          filter: _selectedFilter,
          invert: _invert,
        ),
      );

      if (!mounted) return;

      setState(() {
        _enhancedOutputPath = result.targetPath;
        _previewBytes = result.previewBytes;
        _isEnhancing = false;
      });

      // Run live OCR recognition on the newly enhanced image
      _runLiveOcr(result.targetPath);
    } catch (e, st) {
      AppLogger.error(
        'OcrEnhanceScreen: enhancement error',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        setState(() => _isEnhancing = false);
      }
    }
  }

  Future<void> _runLiveOcr(String imagePath) async {
    if (!mounted) return;

    // Anything still queued is out of date now.
    _cancelPendingOcr();

    setState(() => _isScanning = true);

    final requestId = ++_ocrRequestCounter;
    _pendingOcrRequests.add(requestId);

    try {
      final OcrService ocrService =
          widget.ocrService ?? ref.read(ocrServiceProvider);
      final text = await ocrService.extractTextFromImage(
        imagePath,
        language: _selectedLanguage,
        requestId: requestId,
      );

      _pendingOcrRequests.remove(requestId);
      // A newer run started while this one was waiting; its answer wins.
      if (!mounted || requestId != _ocrRequestCounter) return;

      final words = text
          .trim()
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .length;

      setState(() {
        _recognizedText = text.trim();
        _wordCount = words;
        _isScanning = false;
      });
    } catch (e, st) {
      _pendingOcrRequests.remove(requestId);
      AppLogger.error(
        'OcrEnhanceScreen: live OCR failed',
        error: e,
        stackTrace: st,
      );
      if (mounted && requestId == _ocrRequestCounter) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _onLanguageChanged(String newLang) {
    if (_selectedLanguage == newLang) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedLanguage = newLang;
      _recognizedText = '';
      _wordCount = 0;
      _isScanning = true;
    });
    final pathToScan = _enhancedOutputPath ?? _currentSourcePath;
    _runLiveOcr(pathToScan);
  }

  Future<void> _rotateClockwise() async {
    HapticFeedback.selectionClick();
    setState(() {
      _rotationAngle = (_rotationAngle + 90) % 360;
      _recognizedText = '';
      _wordCount = 0;
      _isScanning = true;
    });
    _scheduleEnhancement(immediate: true);
  }

  Future<void> _rotateCounterClockwise() async {
    HapticFeedback.selectionClick();
    setState(() {
      _rotationAngle = (_rotationAngle - 90 + 360) % 360;
      _recognizedText = '';
      _wordCount = 0;
      _isScanning = true;
    });
    _scheduleEnhancement(immediate: true);
  }

  Future<void> _openCropper() async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ImageEditService imageEditService =
        widget.imageEditService ?? ref.read(imageEditServiceProvider);

    // Crop uses the current enhanced output if available, or the source.
    final cropInputPath = _enhancedOutputPath ?? _currentSourcePath;

    try {
      final cropped = await imageEditService.cropAndRotate(
        sourcePath: cropInputPath,
        toolbarTitle: l10n.entryEditorCropImageTitle,
        toolbarColor: theme.colorScheme.surface,
        toolbarWidgetColor: theme.colorScheme.onSurface,
        statusBarBrightness: theme.brightness,
        activeControlColor: theme.colorScheme.primary,
      );

      if (cropped != null && mounted) {
        _tempFilesToDelete.add(cropped);
        setState(() {
          _currentSourcePath = cropped;
          _enhancedOutputPath = null;
          _previewBytes = null;
          _rotationAngle = 0; // Cropper handles its own rotation
          _recognizedText = '';
          _wordCount = 0;
          _isScanning = true;
        });
        _scheduleEnhancement(immediate: true);
      }
    } catch (e, st) {
      AppLogger.error(
        'OcrEnhanceScreen: crop failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  void _resetAdjustments() {
    HapticFeedback.selectionClick();
    setState(() {
      _brightness = 0;
      _contrast = 0;
      _selectedFilter = OcrEnhanceFilter.original;
      _recognizedText = '';
      _wordCount = 0;
      _isScanning = true;
    });
    _scheduleEnhancement(immediate: true);
  }

  void _confirmAndInsert() {
    HapticFeedback.mediumImpact();
    // Return recognized text to caller.
    Navigator.of(context).pop(_recognizedText);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.ocrEnhanceRetake,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.ocrEnhanceTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              key: const Key('ocr-enhance-insert-btn'),
              onPressed: _isScanning ? null : _confirmAndInsert,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              icon: const Icon(Icons.check, size: 20),
              label: Text(
                l10n.ocrEnhanceInsertText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Center Image Preview Area
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImagePreview(),
                  if (_isEnhancing)
                    Container(
                      color: Colors.black38,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.amber,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.ocrEnhanceProcessing,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Live OCR Text Preview Card
            _buildLiveTextCard(l10n),

            // Active Tool Adjustments (Sliders or Filter chips)
            if (_activeTab != _EnhanceToolTab.none) _buildToolDrawer(l10n),

            // Bottom Tools Navigation Bar
            _buildBottomToolsBar(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_previewBytes != null) {
      return InteractiveViewer(
        maxScale: 4.0,
        child: Center(
          child: Image.memory(
            _previewBytes!,
            key: const Key('ocr-enhanced-preview-image'),
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    final initialFile = File(_currentSourcePath);
    if (initialFile.existsSync()) {
      return InteractiveViewer(
        maxScale: 4.0,
        child: Center(
          child: Image.file(
            initialFile,
            key: const Key('ocr-initial-preview-image'),
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildLiveTextCard(AppLocalizations l10n) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _wordCount > 0
              ? Colors.amber.withValues(alpha: 0.5)
              : Colors.white12,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar with Word Count & Expand Toggle
          InkWell(
            onTap: () {
              setState(() => _isTextPanelExpanded = !_isTextPanelExpanded);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.document_scanner_outlined,
                    size: 18,
                    color: _wordCount > 0 ? Colors.amber : Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.ocrEnhanceLiveText,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildLanguageSelector(l10n),
                  const SizedBox(width: 8),
                  if (_isScanning)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _wordCount > 0 ? Colors.amber : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _wordCount > 0
                          ? l10n.ocrEnhanceLiveWordCount(_wordCount)
                          : (_isScanning
                                ? l10n.ocrEnhanceLiveScanning
                                : l10n.entryEditorOcrNoTextFound),
                      style: TextStyle(
                        color: _wordCount > 0 ? Colors.black : Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _isTextPanelExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: Colors.white54,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Text View
          if (_isTextPanelExpanded)
            Container(
              constraints: const BoxConstraints(maxHeight: 120),
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              width: double.infinity,
              child: _recognizedText.isNotEmpty
                  ? SingleChildScrollView(
                      child: SelectableText(
                        _recognizedText,
                        key: const Key('ocr-live-text-content'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    )
                  : Text(
                      l10n.ocrEnhanceLiveTextNone,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(AppLocalizations l10n) {
    return PopupMenuButton<String>(
      key: const Key('ocr-language-selector'),
      tooltip: l10n.ocrLanguageSelectTooltip,
      initialValue: _selectedLanguage,
      onSelected: _onLanguageChanged,
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 13, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              _getLanguageLabel(l10n, _selectedLanguage),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 14, color: Colors.white70),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'eng+mal',
          child: Text(
            l10n.ocrLanguageAll,
            style: TextStyle(
              color: _selectedLanguage == 'eng+mal'
                  ? Colors.amber
                  : Colors.white,
              fontWeight: _selectedLanguage == 'eng+mal'
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
        PopupMenuItem(
          value: 'mal',
          child: Text(
            l10n.ocrLanguageMalayalam,
            style: TextStyle(
              color: _selectedLanguage == 'mal' ? Colors.amber : Colors.white,
              fontWeight: _selectedLanguage == 'mal'
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
        PopupMenuItem(
          value: 'eng',
          child: Text(
            l10n.ocrLanguageEnglish,
            style: TextStyle(
              color: _selectedLanguage == 'eng' ? Colors.amber : Colors.white,
              fontWeight: _selectedLanguage == 'eng'
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  String _getLanguageLabel(AppLocalizations l10n, String lang) {
    switch (lang) {
      case 'mal':
        return l10n.ocrLanguageMalayalam;
      case 'eng':
        return l10n.ocrLanguageEnglish;
      case 'eng+mal':
      default:
        return l10n.ocrLanguageAll;
    }
  }

  Widget _buildToolDrawer(AppLocalizations l10n) {
    return Container(
      color: const Color(0xFF161616),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: switch (_activeTab) {
        _EnhanceToolTab.filters => _buildFilterSelector(l10n),
        _EnhanceToolTab.adjust => _buildAdjustSliders(l10n),
        _EnhanceToolTab.none => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildFilterSelector(AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: l10n.ocrEnhanceFilterOriginal,
            filter: OcrEnhanceFilter.original,
            icon: Icons.image_outlined,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.ocrEnhanceFilterDocument,
            filter: OcrEnhanceFilter.documentBw,
            icon: Icons.article_outlined,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.ocrEnhanceFilterGrayscale,
            filter: OcrEnhanceFilter.grayscale,
            icon: Icons.gradient,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.ocrEnhanceFilterEnhance,
            filter: OcrEnhanceFilter.enhance,
            icon: Icons.tonality,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required OcrEnhanceFilter filter,
    required IconData icon,
  }) {
    final isSelected = _selectedFilter == filter;

    return FilterChip(
      selected: isSelected,
      showCheckmark: false,
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.black : Colors.white70,
      ),
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: const Color(0xFF242424),
      selectedColor: Colors.amber,
      onSelected: (selected) {
        if (selected) {
          HapticFeedback.selectionClick();
          setState(() => _selectedFilter = filter);
          _scheduleEnhancement();
        }
      },
    );
  }

  Widget _buildAdjustSliders(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brightness Slider
        Row(
          children: [
            const Icon(Icons.brightness_6, color: Colors.amber, size: 20),
            const SizedBox(width: 10),
            SizedBox(
              width: 70,
              child: Text(
                l10n.ocrEnhanceBrightness,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.amber,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.amber,
                  overlayColor: Colors.amber.withValues(alpha: 0.2),
                  trackHeight: 3,
                ),
                child: Slider(
                  key: const Key('ocr-brightness-slider'),
                  value: _brightness.toDouble(),
                  min: -100,
                  max: 100,
                  divisions: 40,
                  onChanged: (val) {
                    setState(() => _brightness = val.round());
                    _scheduleEnhancement();
                  },
                ),
              ),
            ),
            SizedBox(
              width: 38,
              child: Text(
                '$_brightness',
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),

        // Contrast Slider
        Row(
          children: [
            const Icon(Icons.contrast, color: Colors.amber, size: 20),
            const SizedBox(width: 10),
            SizedBox(
              width: 70,
              child: Text(
                l10n.ocrEnhanceContrast,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.amber,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.amber,
                  overlayColor: Colors.amber.withValues(alpha: 0.2),
                  trackHeight: 3,
                ),
                child: Slider(
                  key: const Key('ocr-contrast-slider'),
                  value: _contrast.toDouble(),
                  min: -100,
                  max: 100,
                  divisions: 40,
                  onChanged: (val) {
                    setState(() => _contrast = val.round());
                    _scheduleEnhancement();
                  },
                ),
              ),
            ),
            SizedBox(
              width: 38,
              child: Text(
                '$_contrast',
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),

        // Reset Button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            key: const Key('ocr-adjust-reset-btn'),
            icon: const Icon(
              Icons.restart_alt,
              size: 16,
              color: Colors.white70,
            ),
            label: Text(
              l10n.ocrCameraReset,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            onPressed: (_brightness != 0 || _contrast != 0)
                ? _resetAdjustments
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomToolsBar(AppLocalizations l10n) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Rotate Left
          _buildToolButton(
            key: const Key('ocr-rotate-left-btn'),
            icon: Icons.rotate_left,
            label: l10n.ocrEnhanceRotateLeft,
            onPressed: _rotateCounterClockwise,
          ),

          // Rotate Right
          _buildToolButton(
            key: const Key('ocr-rotate-right-btn'),
            icon: Icons.rotate_right,
            label: l10n.ocrEnhanceRotateRight,
            onPressed: _rotateClockwise,
          ),

          // Crop
          _buildToolButton(
            key: const Key('ocr-crop-btn'),
            icon: Icons.crop,
            label: l10n.ocrEnhanceCrop,
            onPressed: _openCropper,
          ),

          // Invert light and dark, for light text on a dark background
          _buildToolButton(
            key: const Key('ocr-invert-btn'),
            icon: Icons.invert_colors,
            label: l10n.ocrEnhanceInvert,
            isActive: _invert,
            onPressed: () {
              setState(() => _invert = !_invert);
              _scheduleEnhancement(immediate: true);
            },
          ),

          // Filter presets tab toggle
          _buildToolButton(
            key: const Key('ocr-filter-tab-btn'),
            icon: Icons.photo_filter,
            label: l10n.ocrEnhanceFilter,
            isActive: _activeTab == _EnhanceToolTab.filters,
            onPressed: () {
              setState(() {
                _activeTab = _activeTab == _EnhanceToolTab.filters
                    ? _EnhanceToolTab.none
                    : _EnhanceToolTab.filters;
              });
            },
          ),

          // Adjust (Brightness & Contrast) tab toggle
          _buildToolButton(
            key: const Key('ocr-adjust-tab-btn'),
            icon: Icons.tune,
            label: l10n.ocrEnhanceAdjust,
            isActive: _activeTab == _EnhanceToolTab.adjust,
            onPressed: () {
              setState(() {
                _activeTab = _activeTab == _EnhanceToolTab.adjust
                    ? _EnhanceToolTab.none
                    : _EnhanceToolTab.adjust;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required Key key,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return InkWell(
      key: key,
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? Colors.amber : Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.amber : Colors.white70,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
