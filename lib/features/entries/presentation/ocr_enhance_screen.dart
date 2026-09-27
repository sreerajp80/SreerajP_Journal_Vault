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
import 'package:sreerajp_journal_vault/features/entries/services/ocr_blur_detector.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_capture_downscaler.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/ocr_text_preview_sheet.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_enhancer.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_language_store.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_temp_file_sweeper.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

part 'ocr_enhance_tools.dart';
part 'ocr_enhance_tools_2.dart';

enum _EnhanceToolTab { none, filters, adjust }

/// Largest pinch-zoom on the preview.
const double _kPreviewMaxZoom = 8.0;

/// Zoom level a double-tap jumps to.
const double _kDoubleTapZoom = 2.5;

/// Width the photo is decoded at for display before the working copy is ready.
/// Showing a 50 MP capture at full size would cost hundreds of megabytes.
const int _kInitialPreviewDecodeWidth = 2048;

/// Source of recognition request ids for every enhance screen in this run of
/// the app. Ids are never reused, so a late cancel meant for a closed screen can
/// never drop a request from the next one.
int _lastOcrRequestId = 0;

/// Interactive screen for rotating, cropping, filtering, and adjusting brightness/contrast
/// of document photos before their text is read.
///
/// Text is read only when the user asks for it — from the text preview icon or
/// the insert button — never after each image change. Reading is slow, and
/// running it on every edit kept the screen busy and made the image tools lag.
class OcrEnhanceScreen extends ConsumerStatefulWidget {
  const OcrEnhanceScreen({
    super.key,
    required this.imagePath,
    this.ocrService,
    this.ocrEnhancer,
    this.imageEditService,
    this.captureDownscaler,
    this.languageStore,
    this.blurDetector,
    this.tempFileSweeper,
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

  /// Optional injected OCR language store (used for testing).
  final OcrLanguageStore? languageStore;

  /// Optional injected blur detector (used for testing).
  final OcrBlurDetector? blurDetector;

  /// Optional injected temp file sweeper (used for testing).
  final OcrTempFileSweeper? tempFileSweeper;

  @override
  ConsumerState<OcrEnhanceScreen> createState() => _OcrEnhanceScreenState();
}

class _OcrEnhanceScreenState extends ConsumerState<OcrEnhanceScreen> {
  /// Lets the extensions in this library's part files rebuild the
  /// widget: `setState` is protected, so they cannot call it directly.
  void _rebuild(VoidCallback fn) => setState(fn);

  late String _currentSourcePath;
  String? _enhancedOutputPath;
  Uint8List? _previewBytes;

  int _rotationAngle = 0;
  int _brightness = 0;
  int _contrast = 0;
  OcrEnhanceFilter _selectedFilter = OcrEnhanceFilter.original;
  bool _invert = false;

  /// Scale-up factor for small text: 1, 2 or 3.
  int _enlargeFactor = 1;

  /// Unsharp-mask strength, 0 (off) to 100.
  int _sharpen = 0;

  /// Pan and zoom of the preview, so a double-tap can zoom in and back out.
  final TransformationController _zoomController = TransformationController();

  /// Where the last double-tap landed, so zooming centres on that spot.
  Offset? _doubleTapPosition;
  String _selectedLanguage = OcrLanguageStore.defaultLanguage;

  /// True once the user has picked a language on this screen, so a slow read
  /// of the saved choice cannot overwrite it.
  bool _languagePickedHere = false;

  _EnhanceToolTab _activeTab = _EnhanceToolTab.none;
  bool _isEnhancing = true;

  /// True while insert is reading the text before closing the screen.
  bool _isInserting = false;

  /// Text read for [_keptTextPath] in [_keptTextLanguage]. Kept so opening the
  /// preview again, or inserting, does not read the same image twice. Every
  /// image change writes a new file, so a different path means stale text.
  String? _keptText;
  String? _keptTextPath;
  String? _keptTextLanguage;

  /// Finishes when the full-size capture has been shrunk into the working copy.
  late final Future<void> _masterReady;

  /// The enhancement currently running, if any.
  Future<void>? _enhancementInFlight;

  Timer? _debounceTimer;
  final List<String> _tempFilesToDelete = [];

  /// Folder this screen writes its working files into. Set before the first
  /// enhancement runs.
  Directory _tempDir = Directory.systemTemp;

  /// Labels the newest recognition run, taken from [_lastOcrRequestId]. Older
  /// runs are cancelled so they do not hold the single recognition queue.
  int _ocrRequestCounter = 0;
  final Set<int> _pendingOcrRequests = <int>{};

  @override
  void initState() {
    super.initState();
    _currentSourcePath = widget.imagePath;
    _masterReady = _prepareMaster();
    unawaited(_loadSavedLanguage());
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
    _zoomController.dispose();
    super.dispose();
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
          tooltip: l10n.actionOcrEnhanceRetake,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.titleOcrEnhance,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          _buildAppBarLanguageSelector(l10n),
          IconButton(
            key: const Key('ocr-text-preview-btn'),
            icon: const Icon(Icons.text_snippet_outlined),
            tooltip: l10n.tooltipOcrPreviewText,
            onPressed: _isInserting ? null : _openTextPreview,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              key: const Key('ocr-enhance-insert-btn'),
              onPressed: _isInserting ? null : _confirmAndInsert,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              icon: const Icon(Icons.check, size: 20),
              label: Text(
                l10n.actionOcrEnhanceInsertText,
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
                  if (_isEnhancing || _isInserting)
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
                              _isInserting
                                  ? l10n.bodyOcrEnhanceLiveScanning
                                  : l10n.bodyOcrEnhanceProcessing,
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

            // Active Tool Adjustments (Sliders or Filter chips)
            if (_activeTab != _EnhanceToolTab.none) _buildToolDrawer(l10n),

            // Bottom Tools Navigation Bar
            _buildBottomToolsBar(l10n),
          ],
        ),
      ),
    );
  }
}
