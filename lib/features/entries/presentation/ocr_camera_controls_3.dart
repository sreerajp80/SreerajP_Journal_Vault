part of 'ocr_camera_screen.dart';

extension _OcrCameraScreenStatePart3 on _OcrCameraScreenState {
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
              l10n.descOcrCameraCapture,
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
                tooltip: l10n.actionOcrCameraGallery,
                onPressed: _pickFromGallery,
              ),

              // Large Shutter Button
              Semantics(
                label: l10n.actionOcrCameraCapture,
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
                tooltip: l10n.descOcrCameraCapture,
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
              l10n.bodyOcrCameraPermissionDenied,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: Text(l10n.actionOcrCameraOpenSettings),
              onPressed: () async {
                await openAppSettings();
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.actionOcrCameraGallery),
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
              l10n.bodyOcrCameraNoCameras,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(l10n.errorCommonRetry),
              onPressed: _retryInit,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.actionOcrCameraGallery),
              onPressed: _pickFromGallery,
            ),
          ],
        ),
      ),
    );
  }
}
