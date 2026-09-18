part of 'ocr_enhance_screen.dart';

extension _OcrEnhanceScreenStatePart1 on _OcrEnhanceScreenState {
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

  /// Applies the OCR language the user chose last time.
  Future<void> _loadSavedLanguage() async {
    final OcrLanguageStore store =
        widget.languageStore ?? ref.read(ocrLanguageStoreProvider);
    final saved = await store.read();
    if (!mounted || _languagePickedHere) return;
    _rebuild(() => _selectedLanguage = saved);
  }

  /// Tells the OCR service to drop every recognition run still in flight.
  ///
  /// A cancelled run still answers, with empty text. Moving the counter on
  /// marks that answer as out of date, so it is never kept or inserted.
  void _cancelPendingOcr() {
    if (_pendingOcrRequests.isEmpty) return;
    _ocrRequestCounter++;
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
    // The image is about to change, so any text read from it is out of date.
    _keptText = null;
    _cancelPendingOcr();
    if (immediate) {
      _startEnhancement();
    } else {
      _debounceTimer = Timer(const Duration(milliseconds: 250), () {
        if (mounted) _startEnhancement();
      });
    }
  }

  void _startEnhancement() {
    late final Future<void> run;
    run = _applyEnhancements().whenComplete(() {
      if (identical(_enhancementInFlight, run)) _enhancementInFlight = null;
    });
    _enhancementInFlight = run;
  }

  /// Waits until the image on screen is final: the capture is prepared, no
  /// edit is waiting on the debounce timer, and no enhancement is running.
  Future<void> _waitForImage() async {
    await _masterReady;
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
      _startEnhancement();
    }
    while (true) {
      final run = _enhancementInFlight;
      if (run == null) return;
      await run;
      if (identical(run, _enhancementInFlight)) return;
    }
  }

  Future<void> _applyEnhancements() async {
    if (!mounted) return;

    _rebuild(() => _isEnhancing = true);

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

      _rebuild(() {
        _enhancedOutputPath = result.targetPath;
        _previewBytes = result.previewBytes;
        _isEnhancing = false;
      });
    } catch (e, st) {
      AppLogger.error(
        'OcrEnhanceScreen: enhancement error',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        _rebuild(() => _isEnhancing = false);
      }
    }
  }

  /// Reads the text of the current image in [language].
  ///
  /// Returns the kept text when this image was already read in that language.
  /// Returns `null` when the answer is out of date — the image changed or a
  /// newer read replaced this one while it ran. Throws when recognition fails.
  Future<String?> _readText(String language) async {
    await _waitForImage();
    if (!mounted) return null;

    final path = _enhancedOutputPath ?? _currentSourcePath;
    if (_keptText != null &&
        _keptTextPath == path &&
        _keptTextLanguage == language) {
      return _keptText;
    }

    // Anything still queued is out of date now.
    _cancelPendingOcr();
    final requestId = ++_ocrRequestCounter;
    _pendingOcrRequests.add(requestId);

    try {
      final OcrService ocrService =
          widget.ocrService ?? ref.read(ocrServiceProvider);
      final text = await ocrService.extractTextFromImage(
        path,
        language: language,
        requestId: requestId,
      );
      _pendingOcrRequests.remove(requestId);

      if (!mounted || requestId != _ocrRequestCounter) return null;
      if ((_enhancedOutputPath ?? _currentSourcePath) != path) return null;

      final trimmed = text.trim();
      _keptText = trimmed;
      _keptTextPath = path;
      _keptTextLanguage = language;
      return trimmed;
    } catch (e, st) {
      _pendingOcrRequests.remove(requestId);
      AppLogger.error(
        'OcrEnhanceScreen: text recognition failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  void _onLanguageChanged(String newLang) {
    if (_selectedLanguage == newLang) return;
    _languagePickedHere = true;
    _rebuild(() => _selectedLanguage = newLang);
    final OcrLanguageStore store =
        widget.languageStore ?? ref.read(ocrLanguageStoreProvider);
    unawaited(store.save(newLang));
  }

  /// Opens the sheet that reads and shows the text of the current image.
  Future<void> _openTextPreview() async {
    HapticFeedback.selectionClick();
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => OcrTextPreviewSheet(
        initialLanguage: _selectedLanguage,
        readText: _readText,
        onLanguageChanged: _onLanguageChanged,
        onClosedWhileReading: _cancelPendingOcr,
      ),
    );
    if (text != null && mounted) Navigator.of(context).pop(text);
  }

  Future<void> _rotateClockwise() async {
    HapticFeedback.selectionClick();
    _rebuild(() {
      _rotationAngle = (_rotationAngle + 90) % 360;
    });
    _scheduleEnhancement(immediate: true);
  }

  Future<void> _rotateCounterClockwise() async {
    HapticFeedback.selectionClick();
    _rebuild(() {
      _rotationAngle = (_rotationAngle - 90 + 360) % 360;
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
        toolbarTitle: l10n.titleEntryEditorCropImage,
        toolbarColor: theme.colorScheme.surface,
        toolbarWidgetColor: theme.colorScheme.onSurface,
        statusBarBrightness: theme.brightness,
        activeControlColor: theme.colorScheme.primary,
      );

      if (cropped != null && mounted) {
        _tempFilesToDelete.add(cropped);
        _rebuild(() {
          _currentSourcePath = cropped;
          _enhancedOutputPath = null;
          _previewBytes = null;
          _rotationAngle = 0; // Cropper handles its own rotation
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
    _rebuild(() {
      _brightness = 0;
      _contrast = 0;
      _selectedFilter = OcrEnhanceFilter.original;
    });
    _scheduleEnhancement(immediate: true);
  }

  /// Reads the text if it has not been read for this image yet, then returns
  /// it to the caller.
  Future<void> _confirmAndInsert() async {
    HapticFeedback.mediumImpact();
    _rebuild(() => _isInserting = true);

    String? text;
    var failed = false;
    try {
      text = await _readText(_selectedLanguage);
    } catch (_) {
      // Already logged by _readText.
      failed = true;
    }

    if (!mounted) return;
    _rebuild(() => _isInserting = false);

    if (text != null) {
      Navigator.of(context).pop(text);
    } else if (failed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorEntryEditorOcr),
        ),
      );
    }
    // A `null` without failure means the image changed while reading; the
    // user is editing again, so stay on the screen.
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
}
