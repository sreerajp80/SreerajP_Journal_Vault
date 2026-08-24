import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preset accent colors available in SreerajP Journal Vault.
class AppAccentColors {
  const AppAccentColors._();

  static const Color defaultSeed = Color(0xFF9C5F2B); // Leather Amber

  static const List<Color> presets = [
    Color(0xFF9C5F2B), // Leather Amber (Default)
    Color(0xFFC04B37), // Terracotta Rust
    Color(0xFF2E6B4F), // Forest Emerald
    Color(0xFF23558A), // Deep Sapphire
    Color(0xFF6B4596), // Regal Violet
    Color(0xFF9E3A5F), // Velvet Rose
    Color(0xFF1E6F77), // Ocean Teal
    Color(0xFF4A5568), // Classic Slate
  ];

  /// Computes a contrasting foreground color (white or black) for a given background [color].
  static Color contrastOn(Color color) {
    return color.computeLuminance() > 0.45 ? Colors.black87 : Colors.white;
  }
}

abstract class AccentColorStore {
  Color read();
  Future<void> save(Color color);
}

class SharedPreferencesAccentColorStore implements AccentColorStore {
  SharedPreferencesAccentColorStore(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'accent_color_seed_v1';

  @override
  Color read() {
    final raw = _prefs.getInt(_key);
    if (raw == null) return AppAccentColors.defaultSeed;
    return Color(raw);
  }

  @override
  Future<void> save(Color color) async {
    await _prefs.setInt(_key, color.toARGB32());
  }
}

final accentColorStoreProvider = Provider<AccentColorStore>((ref) {
  return _InMemoryAccentColorStore();
});

class _InMemoryAccentColorStore implements AccentColorStore {
  Color _color = AppAccentColors.defaultSeed;

  @override
  Color read() => _color;

  @override
  Future<void> save(Color color) async {
    _color = color;
  }
}

class AccentColorNotifier extends Notifier<Color> {
  @override
  Color build() {
    try {
      final store = ref.read(accentColorStoreProvider);
      return store.read();
    } catch (_) {
      return AppAccentColors.defaultSeed;
    }
  }

  Future<void> set(Color color) async {
    state = color;
    try {
      final store = ref.read(accentColorStoreProvider);
      await store.save(color);
    } catch (_) {
      // InMemory or test fallback
    }
  }
}

final accentColorProvider = NotifierProvider<AccentColorNotifier, Color>(
  AccentColorNotifier.new,
);
