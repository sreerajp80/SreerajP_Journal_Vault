import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/l10n/quill_localizations_fallback.dart';

void main() {
  const delegate = quillLocalizationsFallbackDelegate;

  group('QuillLocalizationsFallbackDelegate', () {
    test('reports support for a locale flutter_quill does not translate', () {
      // The bug this guards: without the wrapper Flutter drops the Quill
      // delegate on a Malayalam device and the editor throws while building.
      expect(
        FlutterQuillLocalizations.delegate.isSupported(const Locale('ml')),
        isFalse,
      );
      expect(delegate.isSupported(const Locale('ml')), isTrue);
    });

    test('loads English strings for an untranslated locale', () async {
      final loaded = await delegate.load(const Locale('ml'));
      final english = await delegate.load(const Locale('en'));
      expect(loaded.localeName, 'en');
      expect(loaded.bold, english.bold);
    });

    test('keeps the real locale when flutter_quill translates it', () async {
      final loaded = await delegate.load(const Locale('fr'));
      expect(loaded.localeName, 'fr');
    });

    test('never asks to reload', () {
      expect(
        delegate.shouldReload(const QuillLocalizationsFallbackDelegate()),
        isFalse,
      );
    });
  });
}
