import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/l10n/locale_controller.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Settings → Appearance → Language (engineering standard §8.4).
///
/// Layer: presentation. System default comes first; each language is shown in
/// its own script (its endonym), not translated. A change applies at once,
/// without a restart and without leaving this screen.
class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleLanguage)),
      body: RadioGroup<AppLanguage>(
        groupValue: current,
        onChanged: (language) {
          if (language == null) return;
          ref.read(localeControllerProvider.notifier).setLanguage(language);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            for (final language in AppLanguage.values)
              RadioListTile<AppLanguage>(
                key: Key('language-option-${language.storageValue}'),
                value: language,
                title: Text(appLanguageLabel(l10n, language)),
                subtitle: language == AppLanguage.system
                    ? Text(l10n.descLanguageSystemDefault)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

/// The name shown for [language]: a localized "System default", or the
/// language's own name in its own script.
String appLanguageLabel(AppLocalizations l10n, AppLanguage language) {
  return switch (language) {
    AppLanguage.system => l10n.labelLanguageSystemDefault,
    AppLanguage.en => l10n.labelLanguageEnglish,
    AppLanguage.ml => l10n.labelLanguageMalayalam,
    AppLanguage.sa => l10n.labelLanguageSanskrit,
  };
}
