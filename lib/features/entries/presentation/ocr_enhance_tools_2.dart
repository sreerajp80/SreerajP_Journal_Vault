part of 'ocr_enhance_screen.dart';

extension _OcrEnhanceScreenStatePart2 on _OcrEnhanceScreenState {
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
            label: l10n.labelOcrEnhanceFilterOriginal,
            filter: OcrEnhanceFilter.original,
            icon: Icons.image_outlined,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.labelOcrEnhanceFilterDocument,
            filter: OcrEnhanceFilter.documentBw,
            icon: Icons.article_outlined,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.labelOcrEnhanceFilterGrayscale,
            filter: OcrEnhanceFilter.grayscale,
            icon: Icons.gradient,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.actionOcrEnhanceFilterEnhance,
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
          _rebuild(() => _selectedFilter = filter);
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
                l10n.labelOcrEnhanceBrightness,
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
                    _rebuild(() => _brightness = val.round());
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
                l10n.labelOcrEnhanceContrast,
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
                    _rebuild(() => _contrast = val.round());
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
              l10n.actionOcrCameraReset,
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
            label: l10n.tooltipOcrEnhanceRotateLeft,
            onPressed: _rotateCounterClockwise,
          ),

          // Rotate Right
          _buildToolButton(
            key: const Key('ocr-rotate-right-btn'),
            icon: Icons.rotate_right,
            label: l10n.tooltipOcrEnhanceRotateRight,
            onPressed: _rotateClockwise,
          ),

          // Crop
          _buildToolButton(
            key: const Key('ocr-crop-btn'),
            icon: Icons.crop,
            label: l10n.labelOcrEnhanceCrop,
            onPressed: _openCropper,
          ),

          // Invert light and dark, for light text on a dark background
          _buildToolButton(
            key: const Key('ocr-invert-btn'),
            icon: Icons.invert_colors,
            label: l10n.actionOcrEnhanceInvert,
            isActive: _invert,
            onPressed: () {
              _rebuild(() => _invert = !_invert);
              _scheduleEnhancement(immediate: true);
            },
          ),

          // Filter presets tab toggle
          _buildToolButton(
            key: const Key('ocr-filter-tab-btn'),
            icon: Icons.photo_filter,
            label: l10n.tabOcrEnhanceFilter,
            isActive: _activeTab == _EnhanceToolTab.filters,
            onPressed: () {
              _rebuild(() {
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
            label: l10n.tabOcrEnhanceAdjust,
            isActive: _activeTab == _EnhanceToolTab.adjust,
            onPressed: () {
              _rebuild(() {
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
