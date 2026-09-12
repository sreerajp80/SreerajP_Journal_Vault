import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/ocr_enhance_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// In-app camera screen designed specifically for OCR document scanning.
///
/// Provides manual camera controls:
/// - Exposure compensation / brightness adjustment slider with EV readout
/// - Continuous zoom slider and quick-zoom buttons (1x, 2x, etc.)
/// - Auto vs Locked Focus and Exposure modes
/// - Flash & Torch modes (`FlashMode.off`, `FlashMode.auto`, `FlashMode.always`, `FlashMode.torch`)
/// - Tap to focus and exposure metering with an animated reticle
/// - Document framing alignment grid
/// - Camera switching (back/front)
/// - Shortcut to device photo gallery
class OcrCameraScreen extends StatefulWidget {
  const OcrCameraScreen({
    super.key,
    this.cameras,
    this.initialController,
    this.imagePicker,
    this.controllerFactory,
  });

  /// Injected camera list (used for testing or pre-enumerated cameras).
  final List<CameraDescription>? cameras;

  /// Injected camera controller (used for testing).
  final CameraController? initialController;

  /// Injected image picker (used for testing gallery fallback).
  final ImagePicker? imagePicker;

  /// Builds the camera controller (used for testing). Defaults to a real
  /// [CameraController] on the chosen camera.
  final CameraController Function(CameraDescription camera)? controllerFactory;

  @override
  State<OcrCameraScreen> createState() => _OcrCameraScreenState();
}

class _OcrCameraScreenState extends State<OcrCameraScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  List<CameraDescription> _availableCameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;

  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _permissionDenied = false;
  String? _errorMessage;

  FlashMode _flashMode = FlashMode.auto;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _baseZoom = 1.0;
  bool _showGrid = true;

  double _minExposureOffset = -2.0;
  double _maxExposureOffset = 2.0;
  double _exposureStepSize = 0.25;
  double _currentExposureOffset = 0.0;
  bool _showControlsPanel = false;
  FocusMode _focusMode = FocusMode.auto;
  ExposureMode _exposureMode = ExposureMode.auto;

  /// True while a screen pushed by this one (the enhance screen or the gallery
  /// picker) is on top, so this screen is not the one the user is looking at.
  bool _childRouteOpen = false;

  /// Set when the camera was released while this screen was hidden. The camera
  /// is then rebuilt only once this screen is visible again, which keeps the
  /// slow start-up out of the way of the work the visible screen is doing.
  bool _needsReinit = false;

  /// Incremented on every [_initCamera] call so a slow or timed-out attempt can
  /// never overwrite the state of a newer one.
  int _initGeneration = 0;

  Offset? _focusScreenPosition;
  Timer? _focusResetTimer;
  late final AnimationController _focusAnimController;
  late final Animation<double> _focusScaleAnim;
  late final Animation<double> _focusFadeAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _focusScaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.4,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 70),
    ]).animate(_focusAnimController);

    _focusFadeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 55),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_focusAnimController);

    if (widget.initialController != null) {
      _controller = widget.initialController;
      _availableCameras = widget.cameras ?? const [];
      _isInitializing = false;
      _initZoomLevels();
      _initExposureLevels();
    } else {
      _requestPermissionAndInit();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusResetTimer?.cancel();
    _focusAnimController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final CameraController? cameraController = _controller;
      if (cameraController == null || !cameraController.value.isInitialized) {
        return;
      }
      // Release the camera whenever the app leaves the foreground, including
      // when a separate screen such as the crop tool takes over.
      _initGeneration++;
      cameraController.dispose();
      _controller = null;
      _needsReinit = true;
      if (mounted && _isScreenVisible) setState(() {});
    } else if (state == AppLifecycleState.resumed) {
      if (!_needsReinit) return;
      // While another screen sits on top of this one, rebuilding the camera
      // would only steal time from the screen the user is actually using. The
      // rebuild waits until this screen is visible again.
      if (!_isScreenVisible) return;
      _needsReinit = false;
      _initCamera(_selectedCameraIndex);
    }
  }

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
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
      _permissionDenied = false;
    });

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        setState(() {
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
          setState(() {
            _isInitializing = false;
            _errorMessage = 'No cameras available';
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
        setState(() {
          _isInitializing = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// How long to wait for the camera to start before giving up on one attempt.
  static const Duration _initTimeout = Duration(seconds: 8);

  /// Resolution asked for on each start-up attempt, in order.
  ///
  /// `max` is the full size the camera reports, which is what OCR wants — a
  /// page photographed at 1080p leaves body text with too few pixels per
  /// character for the recogniser. It is not supported everywhere, so the last
  /// attempt falls back to a preset every device can start.
  static const List<ResolutionPreset> _resolutionAttempts = <ResolutionPreset>[
    ResolutionPreset.max,
    ResolutionPreset.max,
    ResolutionPreset.veryHigh,
  ];

  Future<void> _initCamera(int cameraIndex) async {
    if (_availableCameras.isEmpty) return;

    final generation = ++_initGeneration;

    if (mounted && !_isInitializing) {
      setState(() {
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
    for (var attempt = 0; attempt < _resolutionAttempts.length; attempt++) {
      final camera = _availableCameras[cameraIndex];
      final preset = _resolutionAttempts[attempt];
      final controller =
          widget.controllerFactory?.call(camera) ??
          CameraController(
            camera,
            preset,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.jpeg,
          );

      try {
        await controller.initialize().timeout(_initTimeout);
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
        setState(() {});
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
      setState(() {
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
      setState(() {});
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
      setState(() {});
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
      setState(() => _flashMode = nextMode);
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
    setState(() => _isInitializing = true);
    await _initCamera(nextIndex);
  }

  Future<void> _setZoomLevel(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final maxAllowed = math.min<double>(_maxZoom, 8.0);
    final clamped = zoom.clamp(_minZoom, maxAllowed);
    try {
      await _controller!.setZoomLevel(clamped);
      setState(() => _currentZoom = clamped);
    } catch (_) {}
  }

  Future<void> _setExposureOffset(double offset) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final clamped = offset.clamp(_minExposureOffset, _maxExposureOffset);
    try {
      await _controller!.setExposureOffset(clamped);
      setState(() => _currentExposureOffset = clamped);
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
      setState(() => _focusMode = nextMode);
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
      setState(() => _exposureMode = nextMode);
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

    HapticFeedback.selectionClick();
    setState(() {
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
        setState(() => _focusScreenPosition = null);
      }
    });
  }

  Future<void> _capturePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    try {
      setState(() => _isCapturing = true);
      HapticFeedback.mediumImpact();

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
      setState(() => _isCapturing = false);

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
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).entryEditorOcrError),
          ),
        );
      }
    }
  }

  /// Starts the camera again after a failed start-up.
  Future<void> _retryInit() async {
    setState(() {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // The camera is released whenever this screen is hidden or the app leaves
    // the foreground. Once it is on top again, bring the camera back.
    if (_needsReinit && _isScreenVisible && !_permissionDenied) {
      _needsReinit = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _initCamera(_selectedCameraIndex);
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: _buildBody(l10n)),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_permissionDenied) {
      return _buildPermissionDeniedView(l10n);
    }

    if (_errorMessage != null) {
      return _buildErrorView(l10n);
    }

    if (_isInitializing ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      children: [
        // Camera Viewfinder & Gestures
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => _handleTapToFocus(details, constraints),
                onScaleStart: (_) => _baseZoom = _currentZoom,
                onScaleUpdate: (details) {
                  if (details.scale != 1.0) {
                    final target = _baseZoom * details.scale;
                    _setZoomLevel(target);
                  }
                },
                child: ClipRect(
                  child: Center(
                    child: CameraPreview(
                      _controller!,
                      child: _showGrid ? const _DocumentFramingGrid() : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Animated Tap-to-Focus Reticle
        if (_focusScreenPosition != null)
          Positioned(
            left: _focusScreenPosition!.dx - 36,
            top: _focusScreenPosition!.dy - 36,
            child: AnimatedBuilder(
              animation: _focusAnimController,
              builder: (context, child) {
                return Opacity(
                  opacity: _focusFadeAnim.value,
                  child: Transform.scale(
                    scale: _focusScaleAnim.value,
                    child: child,
                  ),
                );
              },
              child: const _FocusReticle(),
            ),
          ),

        // Top Toolbar
        Positioned(top: 0, left: 0, right: 0, child: _buildTopToolbar(l10n)),

        // Expandable Camera Controls Panel (Exposure, Zoom, Focus Mode, Exposure Mode)
        if (_showControlsPanel)
          Positioned(
            left: 16,
            right: 16,
            bottom: 180,
            child: _buildControlsPanel(l10n),
          ),

        // Bottom Capture Bar (includes zoom controls, hint, and shutter)
        Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomBar(l10n)),

        // Capturing loading overlay
        if (_isCapturing)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildTopToolbar(AppLocalizations l10n) {
    final (flashIcon, flashTooltip, flashColor) = switch (_flashMode) {
      FlashMode.off => (
        Icons.flash_off,
        l10n.ocrCameraFlashOff,
        Colors.white70,
      ),
      FlashMode.auto => (
        Icons.flash_auto,
        l10n.ocrCameraFlashAuto,
        Colors.amber,
      ),
      FlashMode.always => (Icons.flash_on, l10n.ocrCameraFlashOn, Colors.amber),
      FlashMode.torch => (
        Icons.flashlight_on,
        l10n.ocrCameraFlashTorch,
        Colors.amberAccent,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flash / Torch toggle
              IconButton(
                key: const Key('ocr-camera-flash-btn'),
                icon: Icon(flashIcon, color: flashColor),
                tooltip: flashTooltip,
                onPressed: _cycleFlashMode,
              ),
              // Document Grid overlay toggle
              IconButton(
                key: const Key('ocr-camera-grid-btn'),
                icon: Icon(
                  _showGrid ? Icons.grid_on : Icons.grid_off,
                  color: _showGrid ? Colors.amber : Colors.white70,
                ),
                tooltip: l10n.ocrCameraGridToggle,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showGrid = !_showGrid);
                },
              ),
              // Camera switch (if multiple cameras available)
              if (_availableCameras.length > 1)
                IconButton(
                  key: const Key('ocr-camera-switch-btn'),
                  icon: const Icon(
                    Icons.flip_camera_android_outlined,
                    color: Colors.white,
                  ),
                  tooltip: l10n.ocrCameraSwitch,
                  onPressed: _switchCamera,
                ),
              // Advanced camera adjustments toggle
              IconButton(
                key: const Key('ocr-camera-controls-btn'),
                icon: Icon(
                  Icons.tune,
                  color: _showControlsPanel ? Colors.amber : Colors.white70,
                ),
                tooltip: l10n.ocrCameraControls,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showControlsPanel = !_showControlsPanel);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlsPanel(AppLocalizations l10n) {
    final effectiveMinZoom = _minZoom;
    final effectiveMaxZoom = math.max(
      _minZoom + 0.1,
      math.min<double>(_maxZoom, 8.0),
    );
    final effectiveMinExposure = _minExposureOffset;
    final effectiveMaxExposure = _maxExposureOffset > _minExposureOffset
        ? _maxExposureOffset
        : _minExposureOffset + 1.0;
    final step = _exposureStepSize > 0 ? _exposureStepSize : 0.25;
    final exposureDivisions = math.max(
      1,
      ((effectiveMaxExposure - effectiveMinExposure) / step).round(),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Exposure Row
          Row(
            children: [
              const Icon(Icons.brightness_6, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  l10n.ocrCameraExposure,
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
                    trackHeight: 2.5,
                  ),
                  child: Slider(
                    key: const Key('ocr-camera-exposure-slider'),
                    value: _currentExposureOffset.clamp(
                      effectiveMinExposure,
                      effectiveMaxExposure,
                    ),
                    min: effectiveMinExposure,
                    max: effectiveMaxExposure,
                    divisions: exposureDivisions,
                    onChanged: (val) => _setExposureOffset(val),
                  ),
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '${_currentExposureOffset >= 0 ? '+' : ''}${_currentExposureOffset.toStringAsFixed(1)} EV',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.restart_alt,
                  size: 16,
                  color: Colors.white70,
                ),
                tooltip: l10n.ocrCameraReset,
                onPressed: _currentExposureOffset != 0.0
                    ? () => _setExposureOffset(0.0)
                    : null,
              ),
            ],
          ),

          // Zoom Slider Row
          Row(
            children: [
              const Icon(Icons.zoom_in, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  l10n.ocrCameraZoom,
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
                    trackHeight: 2.5,
                  ),
                  child: Slider(
                    key: const Key('ocr-camera-zoom-slider'),
                    value: _currentZoom.clamp(
                      effectiveMinZoom,
                      effectiveMaxZoom,
                    ),
                    min: effectiveMinZoom,
                    max: effectiveMaxZoom,
                    divisions: 70,
                    onChanged: (val) => _setZoomLevel(val),
                  ),
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '${_currentZoom.toStringAsFixed(1)}×',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 40), // Spacer matching reset button
            ],
          ),

          const Divider(color: Colors.white12, height: 16),

          // Focus & Exposure Mode Toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionChip(
                key: const Key('ocr-camera-focus-mode-chip'),
                avatar: Icon(
                  _focusMode == FocusMode.auto
                      ? Icons.center_focus_strong
                      : Icons.lock_outline,
                  size: 16,
                  color: _focusMode == FocusMode.locked
                      ? Colors.amber
                      : Colors.white70,
                ),
                label: Text(
                  _focusMode == FocusMode.auto
                      ? l10n.ocrCameraFocusAuto
                      : l10n.ocrCameraFocusLocked,
                  style: TextStyle(
                    color: _focusMode == FocusMode.locked
                        ? Colors.amber
                        : Colors.white,
                    fontSize: 11,
                  ),
                ),
                backgroundColor: const Color(0xFF262626),
                onPressed: _toggleFocusMode,
              ),
              ActionChip(
                key: const Key('ocr-camera-exposure-mode-chip'),
                avatar: Icon(
                  _exposureMode == ExposureMode.auto
                      ? Icons.wb_auto
                      : Icons.lock_outline,
                  size: 16,
                  color: _exposureMode == ExposureMode.locked
                      ? Colors.amber
                      : Colors.white70,
                ),
                label: Text(
                  _exposureMode == ExposureMode.auto
                      ? l10n.ocrCameraExposureAuto
                      : l10n.ocrCameraExposureLocked,
                  style: TextStyle(
                    color: _exposureMode == ExposureMode.locked
                        ? Colors.amber
                        : Colors.white,
                    fontSize: 11,
                  ),
                ),
                backgroundColor: const Color(0xFF262626),
                onPressed: _toggleExposureMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoomControls() {
    final supports2x = _maxZoom >= 2.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick Zoom pills
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildZoomPill(1.0, '1×'),
              if (supports2x) ...[
                const SizedBox(width: 8),
                _buildZoomPill(2.0, '2×'),
              ],
              if (_currentZoom > 1.05 && (_currentZoom - 2.0).abs() > 0.1) ...[
                const SizedBox(width: 8),
                Text(
                  '${_currentZoom.toStringAsFixed(1)}×',
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildZoomPill(double targetZoom, String label) {
    final isSelected = (_currentZoom - targetZoom).abs() < 0.15;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        _setZoomLevel(targetZoom);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick Zoom Presets
          _buildZoomControls(),
          const SizedBox(height: 12),

          // Hint text
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              l10n.ocrCameraCaptureHint,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Gallery Picker Shortcut
              IconButton(
                key: const Key('ocr-camera-gallery-btn'),
                icon: const Icon(Icons.photo_library_outlined, size: 28),
                color: Colors.white,
                tooltip: l10n.ocrCameraGallery,
                onPressed: _pickFromGallery,
              ),

              // Large Shutter Button
              Semantics(
                label: l10n.ocrCameraCapture,
                button: true,
                child: GestureDetector(
                  key: const Key('ocr-camera-shutter-btn'),
                  onTap: _isCapturing ? null : _capturePhoto,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Placeholder icon for symmetry and tap-to-focus reset
              IconButton(
                icon: const Icon(Icons.center_focus_strong, size: 28),
                color: Colors.white54,
                tooltip: l10n.ocrCameraCaptureHint,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _setZoomLevel(1.0);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.ocrCameraPermissionDenied,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: Text(l10n.ocrCameraOpenSettings),
              onPressed: () async {
                await openAppSettings();
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.ocrCameraGallery),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
              onPressed: _pickFromGallery,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              l10n.ocrCameraNoCameras,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
              onPressed: _retryInit,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.ocrCameraGallery),
              onPressed: _pickFromGallery,
            ),
          ],
        ),
      ),
    );
  }
}

/// Visual animated reticle shown at the tap-to-focus point.
class _FocusReticle extends StatelessWidget {
  const _FocusReticle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Semi-transparent document framing grid overlay.
class _DocumentFramingGrid extends StatelessWidget {
  const _DocumentFramingGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DocumentGridPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _DocumentGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Rule of thirds lines
    final thirdW = size.width / 3.0;
    final thirdH = size.height / 3.0;

    canvas.drawLine(Offset(thirdW, 0), Offset(thirdW, size.height), gridPaint);
    canvas.drawLine(
      Offset(thirdW * 2, 0),
      Offset(thirdW * 2, size.height),
      gridPaint,
    );
    canvas.drawLine(Offset(0, thirdH), Offset(size.width, thirdH), gridPaint);
    canvas.drawLine(
      Offset(0, thirdH * 2),
      Offset(size.width, thirdH * 2),
      gridPaint,
    );

    // Central document framing box with corner brackets
    final docRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.82,
      height: size.height * 0.65,
    );

    final cornerPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 22.0;

    // Top-left corner
    canvas.drawLine(
      docRect.topLeft,
      docRect.topLeft + const Offset(cornerLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      docRect.topLeft,
      docRect.topLeft + const Offset(0, cornerLen),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      docRect.topRight,
      docRect.topRight - const Offset(cornerLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      docRect.topRight,
      docRect.topRight + const Offset(0, cornerLen),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      docRect.bottomLeft,
      docRect.bottomLeft + const Offset(cornerLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      docRect.bottomLeft,
      docRect.bottomLeft - const Offset(0, cornerLen),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      docRect.bottomRight,
      docRect.bottomRight - const Offset(cornerLen, 0),
      cornerPaint,
    );
    canvas.drawLine(
      docRect.bottomRight,
      docRect.bottomRight - const Offset(0, cornerLen),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
