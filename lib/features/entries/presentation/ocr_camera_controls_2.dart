part of 'ocr_camera_screen.dart';

extension _OcrCameraScreenStatePart2 on _OcrCameraScreenState {
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
        l10n.tooltipOcrCameraFlashOff,
        Colors.white70,
      ),
      FlashMode.auto => (
        Icons.flash_auto,
        l10n.tooltipOcrCameraFlashAuto,
        Colors.amber,
      ),
      FlashMode.always => (
        Icons.flash_on,
        l10n.tooltipOcrCameraFlashOn,
        Colors.amber,
      ),
      FlashMode.torch => (
        Icons.flashlight_on,
        l10n.tooltipOcrCameraFlashTorch,
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
                tooltip: l10n.tooltipOcrCameraGridToggle,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _rebuild(() => _showGrid = !_showGrid);
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
                  tooltip: l10n.tooltipOcrCameraSwitch,
                  onPressed: _switchCamera,
                ),
              // Advanced camera adjustments toggle
              IconButton(
                key: const Key('ocr-camera-controls-btn'),
                icon: Icon(
                  Icons.tune,
                  color: _showControlsPanel ? Colors.amber : Colors.white70,
                ),
                tooltip: l10n.tooltipOcrCameraControls,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _rebuild(() => _showControlsPanel = !_showControlsPanel);
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
                  l10n.labelOcrCameraExposure,
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
                tooltip: l10n.actionOcrCameraReset,
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
                  l10n.labelOcrCameraZoom,
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
                      ? l10n.tooltipOcrCameraFocusAuto
                      : l10n.tooltipOcrCameraFocusLocked,
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
                      ? l10n.tooltipOcrCameraExposureAuto
                      : l10n.tooltipOcrCameraExposureLocked,
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
}
