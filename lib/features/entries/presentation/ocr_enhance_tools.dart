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
    final OcrTempFileSweeper sweeper =
        widget.tempFileSweeper ?? ref.read(ocrTempFileSweeperProvider);

    // Every working file goes into the app's cache folder, where a later sweep
    // can find it even if this screen never gets to delete it.
    _tempDir = await sweeper.tempDirectory();
    if (!mounted) return;

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
    unawaited(_warnIfBlurry(master));
  }

  /// Suggests a retake when the photo is too blurry to read well. Advice only:
  /// the user can still carry on with the photo they have.
  Future<void> _warnIfBlurry(String path) async {
    final OcrBlurDetector detector =
        widget.blurDetector ?? ref.read(ocrBlurDetectorProvider);
    final blurry = await detector.isBlurry(path);
    if (!blurry || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).errorOcrPhotoBlurry)),
    );
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
    _ocrRequestCounter = ++_lastOcrRequestId;
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

    // An edit made before the working copy is ready must not start on the
    // full-size capture, which is far too large to decode here.
    await _masterReady;
    if (!mounted) return;

    try {
      final OcrEnhancer enhancer =
          widget.ocrEnhancer ?? ref.read(ocrEnhancerProvider);
      final targetPath = _newTempPath('ocr_enh_');
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
          enlargeFactor: _enlargeFactor,
          sharpen: _sharpen,
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
      if (!mounted) return;
      _rebuild(() => _isEnhancing = false);
      // Say so. A silent failure leaves the old picture on screen and the user
      // believes the change was applied.
      final l10n = AppLocalizations.of(context);
      final unreadable =
          e is OcrImageTooLargeException ||
          e is FormatException ||
          e is FileSystemException;
      _showError(
        unreadable ? l10n.errorOcrPhotoUnreadable : l10n.errorOcrEnhanceFailed,
      );
    }
  }

  /// A new file path in this screen's temp folder, starting with [prefix].
  String _newTempPath(String prefix) => p.join(
    _tempDir.path,
    '$prefix${DateTime.now().microsecondsSinceEpoch}.png',
  );

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
    final requestId = _ocrRequestCounter = ++_lastOcrRequestId;
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
    _keptText = null;
    _rebuild(() => _selectedLanguage = newLang);
    final OcrLanguageStore store =
        widget.languageStore ?? ref.read(ocrLanguageStoreProvider);
    unawaited(store.save(newLang));
  }

  Widget _buildAppBarLanguageSelector(AppLocalizations l10n) {
    String label(String code) => switch (code) {
      'mal' => l10n.labelOcrLanguageMalayalam,
      'eng' => l10n.labelOcrLanguageEnglish,
      _ => l10n.labelOcrLanguageAll,
    };

    String shortBadge(String code) => switch (code) {
      'mal' => 'മല',
      'eng' => 'EN',
      _ => 'ALL',
    };

    return PopupMenuButton<String>(
      key: const Key('ocr-appbar-language-selector'),
      tooltip: l10n.tooltipOcrLanguageSelect,
      initialValue: _selectedLanguage,
      onSelected: _onLanguageChanged,
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 14, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              shortBadge(_selectedLanguage),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
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
            label('eng+mal'),
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
            label('mal'),
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
            label('eng'),
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

    try {
      // Crop the unfiltered image, turned the way the user sees it. After the
      // crop every filter and slider is applied once, to the cropped image.
      // Cropping the filtered output instead applied them all a second time.
      final cropInputPath = await _rotatedSourceForCrop();
      if (cropInputPath == null || !mounted) return;

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
          // The rotation is already in the cropped image.
          _rotationAngle = 0;
        });
        _scheduleEnhancement(immediate: true);
      }
    } catch (e, st) {
      AppLogger.error(
        'OcrEnhanceScreen: crop failed',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        _showError(AppLocalizations.of(context).errorEntryEditorCropImage);
      }
    }
  }

  /// The image to crop: the working source with only the current rotation
  /// applied — no filter, no slider, no resize. Returns the source itself when
  /// there is no rotation, and `null` when the rotated copy could not be made
  /// (the failure is then already shown to the user).
  Future<String?> _rotatedSourceForCrop() async {
    await _waitForImage();
    if (!mounted) return null;
    if (_rotationAngle == 0) return _currentSourcePath;

    final OcrEnhancer enhancer =
        widget.ocrEnhancer ?? ref.read(ocrEnhancerProvider);
    final targetPath = _newTempPath('ocr_rot_');
    _tempFilesToDelete.add(targetPath);
    _rebuild(() => _isEnhancing = true);
    try {
      final result = await enhancer.enhance(
        OcrEnhanceParams(
          sourcePath: _currentSourcePath,
          targetPath: targetPath,
          rotationAngle: _rotationAngle,
          generatePreview: false,
          fitToOcrSize: false,
        ),
      );
      return result.targetPath;
    } catch (e, st) {
      AppLogger.error(
        'OcrEnhanceScreen: rotation before crop failed',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        _showError(AppLocalizations.of(context).errorOcrEnhanceFailed);
      }
      return null;
    } finally {
      if (mounted) _rebuild(() => _isEnhancing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetAdjustments() {
    HapticFeedback.selectionClick();
    _rebuild(() {
      _brightness = 0;
      _contrast = 0;
      _enlargeFactor = 1;
      _sharpen = 0;
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
    String? error;
    final l10n = AppLocalizations.of(context);
    try {
      text = await _readText(_selectedLanguage);
    } on OcrTimeoutException {
      error = l10n.errorOcrTimedOut;
    } catch (_) {
      // Already logged by _readText.
      error = l10n.errorEntryEditorOcr;
    }

    if (!mounted) return;
    _rebuild(() => _isInserting = false);

    if (text != null) {
      Navigator.of(context).pop(text);
    } else if (error != null) {
      _showError(error);
    }
    // A `null` without failure means the image changed while reading; the
    // user is editing again, so stay on the screen.
  }

  /// Double-tap zooms in on the tapped spot; a second double-tap zooms out.
  void _toggleDoubleTapZoom() {
    if (_zoomController.value.getMaxScaleOnAxis() > 1.01) {
      _zoomController.value = Matrix4.identity();
      return;
    }
    final Offset at = _doubleTapPosition ?? Offset.zero;
    const zoom = _kDoubleTapZoom;
    _zoomController.value = Matrix4.identity()
      ..translateByDouble(-at.dx * (zoom - 1), -at.dy * (zoom - 1), 0, 1)
      ..scaleByDouble(zoom, zoom, 1, 1);
  }

  Widget _buildZoomablePreview(Widget image) {
    return Semantics(
      label: AppLocalizations.of(context).descOcrEnhancePreviewZoom,
      image: true,
      child: GestureDetector(
        key: const Key('ocr-preview-zoom'),
        onDoubleTapDown: (details) =>
            _doubleTapPosition = details.localPosition,
        onDoubleTap: _toggleDoubleTapZoom,
        child: InteractiveViewer(
          transformationController: _zoomController,
          maxScale: _kPreviewMaxZoom,
          child: Center(child: image),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_previewBytes != null) {
      return _buildZoomablePreview(
        Image.memory(
          _previewBytes!,
          key: const Key('ocr-enhanced-preview-image'),
          fit: BoxFit.contain,
        ),
      );
    }

    final initialFile = File(_currentSourcePath);
    if (initialFile.existsSync()) {
      return _buildZoomablePreview(
        Image.file(
          initialFile,
          key: const Key('ocr-initial-preview-image'),
          fit: BoxFit.contain,
          cacheWidth: _kInitialPreviewDecodeWidth,
        ),
      );
    }

    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}
