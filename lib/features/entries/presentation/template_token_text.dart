import 'package:sreerajp_journal_vault/features/entries/templates/template_token_engine.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Explains a template date token in the user's language.
///
/// The token tag itself (`{{today}}`) is code and never translated; only the
/// sentence that says what it does is.
extension TemplateTokenText on TemplateTokenInfo {
  String descriptionIn(AppLocalizations l10n) {
    switch (token) {
      case '{{today}}':
        return l10n.descTemplateTokenToday;
      case '{{weekday}}':
        return l10n.descTemplateTokenWeekday;
      case '{{date}}':
        return l10n.descTemplateTokenDate;
      case '{{time}}':
        return l10n.descTemplateTokenTime;
      case '{{year}}':
        return l10n.descTemplateTokenYear;
      case '{{month}}':
        return l10n.descTemplateTokenMonth;
      default:
        return l10n.descTemplateTokenDay;
    }
  }
}
