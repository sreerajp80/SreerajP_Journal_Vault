part of 'ocr_camera_screen.dart';

extension _OcrCameraScreenStatePart1 on _OcrCameraScreenState {
  /// True when this screen is the one on top, so it is worth holding a camera.
  bool get _isScreenVisible {
    if (_childRouteOpen) return false;
    if (!mounted) return false;
    return ModalRoute.of(context)?.isCurrent ?? true;
  }

  /// Rebuilds the camera after returning from a screen pushed by this one.
  Future<void> _resumeCameraAfterChildRoute() async {
    if (!mounted) return;
    if (_permissionDenied) return;
    final controller = _controller;
    if (!_needsReinit && controller != null && controller.value.isInitialized) {
      return;
    }
    _needsReinit = false;
    await _initCamera(_selectedCameraIndex);
  }

  Future<void> _requestPermissionAndInit() async {
    _rebuild(() {
      _isInitializing = true;
      _errorMessage = null;
      _permissionDenied = false;
    });

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        _rebuild(() {
          _isInitializing = false;
          _permissionDenied = true;
        });
      }
      return;
    }

    try {
      if (widget.cameras != null) {
        _availableCameras = widget.cameras!;
      } else {
        _availableCameras = await availableCameras();
      }

      if (_availableCameras.isEmpty) {
        if (mounted) {
          _rebuild(() {
            _isInitializing = false;
            _errorMessage = AppLocalizations.of(context).errorOcrNoCameras;
          });
        }
        return;
      }

      // Default to rear camera for document photography.
      final backCameraIndex = _availableCameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _selectedCameraIndex = backCameraIndex >= 0 ? backCameraIndex : 0;

      await _initCamera(_selectedCameraIndex);
    } catch (e, st) {
      AppLogger.error(
        'OcrCameraScreen: camera query failed',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        _rebuild(() {
          _isInitializing = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _initCamera(int cameraIndex) async {
    if (_availableCameras.isEmpty) return;

    final generation = ++_initGeneration;

    if (mounted && !_isInitializing) {
      _rebuild(() {
        _isInitializing = true;
        _errorMessage = null;
      });
    }

    final oldController = _controller;
    _controller = null;
    if (oldController != null) {
      // Releasing the old camera can be slow, and nothing here depends on it
      // finishing, so it is not awaited.
      unawaited(oldController.dispose());
    }

    Object? lastError;
    StackTrace? lastStackTrace;

    // Attempt 0 and 1 both ask for the full sensor: the first try can time out
    // when the camera hardware is still held by the screen the user just came
    // back from, and that is worth one more go before giving up resolution.
    // Attempt 2 drops to veryHigh for the devices where `max` is unsupported
    // or too slow to start.
    for (
      var attempt = 0;
      attempt < _OcrCameraScreenState._resolutionAttempts.length;
      attempt++
    ) {
      final camera = _availableCameras[cameraIndex];
      final preset = _OcrCameraScreenState._resolutionAttempts[attempt];
      final controller =
          widget.controllerFactory?.call(camera) ??
          CameraController(
            camera,
            preset,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.jpeg,
          );

      try {
        await controller.initialize().timeout(
          _OcrCameraScreenState._initTimeout,
        );
        if (!mounted || generation != _initGeneration) {
          unawaited(controller.dispose());
          return;
        }

        _controller = controller;
        _selectedCameraIndex = cameraIndex;
        _isInitializing = false;

        // Set default flash mode to auto or off
        try {
          await controller.setFlashMode(_flashMode);
        } catch (_) {}

        await _initZoomLevels();
        await _initExposureLevels();

        if (!mounted || generation != _initGeneration) return;
        _rebuild(() {});
        return;
      } catch (e, st) {
        lastError = e;
        lastStackTrace = st;
        unawaited(controller.dispose());
        AppLogger.error(
          'OcrCameraScreen: init attempt ${attempt + 1} at $preset failed for '
          'camera $cameraIndex',
          error: e,
          stackTrace: st,
        );
        if (!mounted || generation != _initGeneration) return;
      }
    }

    AppLogger.error(
      'OcrCameraScreen: init failed for camera $cameraIndex',
      error: lastError,
      stackTrace: lastStackTrace,
    );
    if (mounted && generation == _initGeneration) {
      _rebuild(() {
        _isInitializing = false;
        _errorMessage = lastError.toString();
      });
    }
  }

  Future<void> _initExposureLevels() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      _minExposureOffset = await _controller!.getMinExposureOffset();
      _maxExposureOffset = await _controller!.getMaxExposureOffset();
      _exposureStepSize = await _controller!.getExposureOffsetStepSize();
      _currentExposureOffset = 0.0;
    } catch (_) {
      _minExposureOffset = -2.0;
      _maxExposureOffset = 2.0;
      _exposureStepSize = 0.25;
      _currentExposureOffset = 0.0;
    }
    if (mounted) {
      _rebuild(() {});
    }
  }

  Future<void> _initZoomLevels() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      _currentZoom = _minZoom;
    } catch (_) {
      _minZoom = 1.0;
      _maxZoom = 1.0;
      _currentZoom = 1.0;
    }
    if (mounted) {
      _rebuild(() {});
    }
  }

  Future<void> _cycleFlashMode() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final nextMode = switch (_flashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      FlashMode.always => FlashMode.torch,
      FlashMode.torch => FlashMode.off,
    };

    try {
      await _controller!.setFlashMode(nextMode);
      HapticFeedback.selectionClick();
      _rebuild(() => _flashMode = nextMode);
    } catch (e) {
      AppLogger.warning(
        'OcrCameraScreen: failed to set flash mode $nextMode: $e',
      );
    }
  }

  Future<void> _switchCamera() async {
    if (_availableCameras.length < 2) return;
    HapticFeedback.selectionClick();
    final nextIndex = (_selectedCameraIndex + 1) % _availableCameras.length;
    _rebuild(() => _isInitializing = true);
    await _initCamera(nextIndex);
  }

  Future<void> _setZoomLevel(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final maxAllowed = math.min<double>(_maxZoom, 8.0);
    final clamped = zoom.clamp(_minZoom, maxAllowed);
    try {
      await _controller!.setZoomLevel(clamped);
      _rebuild(() => _currentZoom = clamped);
    } catch (_) {}
  }

  Future<void> _setExposureOffset(double offset) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final clamped = offset.clamp(_minExposureOffset, _maxExposureOffset);
    try {
      await _controller!.setExposureOffset(clamped);
      _rebuild(() => _currentExposureOffset = clamped);
    } catch (_) {}
  }

  Future<void> _toggleFocusMode() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final nextMode = _focusMode == FocusMode.auto
        ? FocusMode.locked
        : FocusMode.auto;
    try {
      await _controller!.setFocusMode(nextMode);
      HapticFeedback.selectionClick();
      _rebuild(() => _focusMode = nextMode);
    } catch (_) {}
  }

  Future<void> _toggleExposureMode() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final nextMode = _exposureMode == ExposureMode.auto
        ? ExposureMode.locked
        : ExposureMode.auto;
    try {
      await _controller!.setExposureMode(nextMode);
      HapticFeedback.selectionClick();
      _rebuild(() => _exposureMode = nextMode);
    } catch (_) {}
  }

  Future<void> _handleTapToFocus(
    TapDownDetails details,
    BoxConstraints constraints,
  ) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final local = details.localPosition;
    final double x = (local.dx / constraints.maxWidth).clamp(0.0, 1.0);
    final double y = (local.dy / constraints.maxHeight).clamp(0.0, 1.0);
    final focusPoint = Offset(x, y);
    _lastFocusPoint = focusPoint;

    HapticFeedback.selectionClick();
    _rebuild(() {
      _focusScreenPosition = local;
    });

    _focusAnimController.forward(from: 0.0);

    try {
      if (_controller!.value.focusPointSupported) {
        await _controller!.setFocusPoint(focusPoint);
      }
      if (_controller!.value.exposurePointSupported) {
        await _controller!.setExposurePoint(focusPoint);
      }
    } catch (_) {}

    _focusResetTimer?.cancel();
    _focusResetTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _rebuild(() => _focusScreenPosition = null);
      }
    });
  }

  /// Focuses on the last tap point (or the centre) and gives the lens a
  /// moment to settle, so the shot is not taken while focus is still moving.
  /// Skipped when the user has locked focus themselves, or the camera cannot
  /// focus on a point.
  Future<void> _focusBeforeCapture() async {
    final controller = _controller;
    if (controller == null || !controller.value.focusPointSupported) return;
    if (_focusMode == FocusMode.locked) return;
    try {
      await controller.setFocusPoint(_lastFocusPoint ?? const Offset(0.5, 0.5));
      await Future<void>.delayed(_OcrCameraScreenState._focusSettleDelay);
    } catch (e) {
      AppLogger.warning('OcrCameraScreen: focus before capture failed: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    try {
      _rebuild(() => _isCapturing = true);
      HapticFeedback.mediumImpact();

      await _focusBeforeCapture();
      if (!mounted) return;
      if (_controller == null || !_controller!.value.isInitialized) {
        // The camera was released while focus settled (the app went to the
        // background). Nothing to shoot with; let the user try again.
        _rebuild(() => _isCapturing = false);
        return;
      }

      final XFile photo = await _controller!.takePicture();
      if (!mounted) return;

      if (widget.initialController != null) {
        // Direct return for unit testing of camera screen
        Navigator.of(context).pop(photo.path);
        return;
      }

      _childRouteOpen = true;
      final String? result;
      try {
        result = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (_) => OcrEnhanceScreen(imagePath: photo.path),
          ),
        );
      } finally {
        _childRouteOpen = false;
      }

      if (!mounted) return;
      _rebuild(() => _isCapturing = false);

      if (result != null) {
        Navigator.of(context).pop(result);
        return;
      }

      // The user came back to retake the photo. The camera was released while
      // the enhance screen was on top, so bring it back now.
      await _resumeCameraAfterChildRoute();
    } catch (e, st) {
      AppLogger.error(
        'OcrCameraScreen: capture failed',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        _rebuild(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorEntryEditorOcr),
          ),
        );
      }
    }
  }

  /// Starts the camera again after a failed start-up.
  Future<void> _retryInit() async {
    _rebuild(() {
      _errorMessage = null;
      _isInitializing = true;
    });
    if (_availableCameras.isEmpty) {
      await _requestPermissionAndInit();
    } else {
      await _initCamera(_selectedCameraIndex);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = widget.imagePicker ?? ImagePicker();
    _childRouteOpen = true;
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) {
        if (widget.imagePicker != null) {
          // Direct return for unit testing
          Navigator.of(context).pop(picked.path);
          return;
        }

        final result = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (_) => OcrEnhanceScreen(imagePath: picked.path),
          ),
        );

        if (result != null && mounted) {
          Navigator.of(context).pop(result);
          return;
        }
      }
    } catch (e, st) {
      AppLogger.error(
        'OcrCameraScreen: gallery pick failed',
        error: e,
        stackTrace: st,
      );
    } finally {
      _childRouteOpen = false;
    }

    await _resumeCameraAfterChildRoute();
  }
}
