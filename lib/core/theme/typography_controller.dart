import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported font families for journal entry text in SreerajP Journal Vault.
enum EntryFontFamily {
  sans,
  serif,
  monospace;

  /// Dart / Flutter font family identifier.
  ///
  /// `null` defaults to the standard platform sans-serif (e.g. Roboto on Android).
  /// Built-in system fonts require zero network requests (strictly offline).
  String? get fontName => switch (this) {
    EntryFontFamily.sans => null,
    EntryFontFamily.serif => 'serif',
    EntryFontFamily.monospace => 'monospace',
  };
}

/// Reading typography preferences for journal entries.
@immutable
class TypographySettings {
  final EntryFontFamily fontFamily;
  final double fontSize;

  const TypographySettings({
    this.fontFamily = EntryFontFamily.sans,
    this.fontSize = defaultFontSize,
  });

  static const double minFontSize = 12.0;
  static const double maxFontSize = 24.0;
  static const double defaultFontSize = 16.0;

  static const double presetSmall = 14.0;
  static const double presetDefault = 16.0;
  static const double presetMedium = 18.0;
  static const double presetLarge = 20.0;
  static const double presetExtraLarge = 22.0;

  TypographySettings copyWith({EntryFontFamily? fontFamily, double? fontSize}) {
    return TypographySettings(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  /// Returns a configured [TextStyle] using the selected typography rules.
  TextStyle toTextStyle({
    Color? color,
    FontWeight? fontWeight,
    double? height,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: fontFamily.fontName,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height ?? 1.5,
      fontStyle: fontStyle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypographySettings &&
          runtimeType == other.runtimeType &&
          fontFamily == other.fontFamily &&
          fontSize == other.fontSize;

  @override
  int get hashCode => Object.hash(fontFamily, fontSize);
}

/// Storage interface for typography preferences.
abstract class TypographyStore {
  TypographySettings read();
  Future<void> save(TypographySettings settings);
}

/// [TypographyStore] implementation backed by [SharedPreferences].
class SharedPreferencesTypographyStore implements TypographyStore {
  SharedPreferencesTypographyStore(this._prefs);

  final SharedPreferences _prefs;
  static const _fontFamilyKey = 'entry_font_family_v1';
  static const _fontSizeKey = 'entry_font_size_v1';

  @override
  TypographySettings read() {
    final rawFamily = _prefs.getString(_fontFamilyKey);
    final family = switch (rawFamily) {
      'serif' => EntryFontFamily.serif,
      'monospace' => EntryFontFamily.monospace,
      _ => EntryFontFamily.sans,
    };

    final rawSize = _prefs.getDouble(_fontSizeKey);
    final size =
        rawSize != null &&
            rawSize >= TypographySettings.minFontSize &&
            rawSize <= TypographySettings.maxFontSize
        ? rawSize
        : TypographySettings.defaultFontSize;

    return TypographySettings(fontFamily: family, fontSize: size);
  }

  @override
  Future<void> save(TypographySettings settings) async {
    final familyStr = switch (settings.fontFamily) {
      EntryFontFamily.serif => 'serif',
      EntryFontFamily.monospace => 'monospace',
      EntryFontFamily.sans => 'sans',
    };
    await _prefs.setString(_fontFamilyKey, familyStr);
    await _prefs.setDouble(_fontSizeKey, settings.fontSize);
  }
}

/// In-memory store for tests and default mock environments.
class InMemoryTypographyStore implements TypographyStore {
  TypographySettings _settings = const TypographySettings();

  @override
  TypographySettings read() => _settings;

  @override
  Future<void> save(TypographySettings settings) async {
    _settings = settings;
  }
}

/// Provider for the active [TypographyStore].
final typographyStoreProvider = Provider<TypographyStore>((ref) {
  return InMemoryTypographyStore();
});

/// Reactive notifier managing entry typography settings.
class TypographyNotifier extends Notifier<TypographySettings> {
  @override
  TypographySettings build() {
    try {
      final store = ref.watch(typographyStoreProvider);
      return store.read();
    } catch (_) {
      return const TypographySettings();
    }
  }

  Future<void> updateFontFamily(EntryFontFamily family) async {
    final updated = state.copyWith(fontFamily: family);
    await _save(updated);
  }

  Future<void> updateFontSize(double size) async {
    final clamped = size.clamp(
      TypographySettings.minFontSize,
      TypographySettings.maxFontSize,
    );
    final updated = state.copyWith(fontSize: clamped);
    await _save(updated);
  }

  Future<void> resetToDefault() async {
    const defaultSettings = TypographySettings();
    await _save(defaultSettings);
  }

  Future<void> _save(TypographySettings settings) async {
    final prev = state;
    state = settings;
    try {
      final store = ref.read(typographyStoreProvider);
      await store.save(settings);
    } catch (_) {
      state = prev;
      rethrow;
    }
  }
}

final typographyProvider =
    NotifierProvider<TypographyNotifier, TypographySettings>(
      TypographyNotifier.new,
    );
