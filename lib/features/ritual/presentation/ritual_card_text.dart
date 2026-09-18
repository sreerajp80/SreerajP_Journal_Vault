import 'package:sreerajp_journal_vault/features/ritual/domain/ritual_card.dart';
import 'package:sreerajp_journal_vault/features/ritual/services/ritual_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

// Layer: presentation.
//
// Resolves the user-visible text of the ritual deck in the active language.
// Curated card text, theme names and breathing technique names are in
// lib/l10n/*.arb; the domain and service types hold none of it.

typedef _CardText = ({
  String title,
  String prompt,
  String quote,
  String source,
});

extension RitualCardText on RitualCard {
  /// The card title. A user-created card shows the text the user typed.
  String titleIn(AppLocalizations l10n) =>
      isUserCreated ? title : _curatedText(l10n).title;

  String promptIn(AppLocalizations l10n) =>
      isUserCreated ? prompt : _curatedText(l10n).prompt;

  String quoteIn(AppLocalizations l10n) =>
      isUserCreated ? quote : _curatedText(l10n).quote;

  /// Where the quote comes from, or null when a user card has no source.
  String? sourceIn(AppLocalizations l10n) =>
      isUserCreated ? quoteAuthor : _curatedText(l10n).source;

  _CardText _curatedText(AppLocalizations l) {
    return switch (number) {
      1 => (
        title: l.descRitualCard01Title,
        prompt: l.descRitualCard01Prompt,
        quote: l.descRitualCard01Quote,
        source: l.descRitualCard01Source,
      ),
      2 => (
        title: l.descRitualCard02Title,
        prompt: l.descRitualCard02Prompt,
        quote: l.descRitualCard02Quote,
        source: l.descRitualCard02Source,
      ),
      3 => (
        title: l.descRitualCard03Title,
        prompt: l.descRitualCard03Prompt,
        quote: l.descRitualCard03Quote,
        source: l.descRitualCard03Source,
      ),
      4 => (
        title: l.descRitualCard04Title,
        prompt: l.descRitualCard04Prompt,
        quote: l.descRitualCard04Quote,
        source: l.descRitualCard04Source,
      ),
      5 => (
        title: l.descRitualCard05Title,
        prompt: l.descRitualCard05Prompt,
        quote: l.descRitualCard05Quote,
        source: l.descRitualCard05Source,
      ),
      6 => (
        title: l.descRitualCard06Title,
        prompt: l.descRitualCard06Prompt,
        quote: l.descRitualCard06Quote,
        source: l.descRitualCard06Source,
      ),
      7 => (
        title: l.descRitualCard07Title,
        prompt: l.descRitualCard07Prompt,
        quote: l.descRitualCard07Quote,
        source: l.descRitualCard07Source,
      ),
      8 => (
        title: l.descRitualCard08Title,
        prompt: l.descRitualCard08Prompt,
        quote: l.descRitualCard08Quote,
        source: l.descRitualCard08Source,
      ),
      9 => (
        title: l.descRitualCard09Title,
        prompt: l.descRitualCard09Prompt,
        quote: l.descRitualCard09Quote,
        source: l.descRitualCard09Source,
      ),
      10 => (
        title: l.descRitualCard10Title,
        prompt: l.descRitualCard10Prompt,
        quote: l.descRitualCard10Quote,
        source: l.descRitualCard10Source,
      ),
      11 => (
        title: l.descRitualCard11Title,
        prompt: l.descRitualCard11Prompt,
        quote: l.descRitualCard11Quote,
        source: l.descRitualCard11Source,
      ),
      12 => (
        title: l.descRitualCard12Title,
        prompt: l.descRitualCard12Prompt,
        quote: l.descRitualCard12Quote,
        source: l.descRitualCard12Source,
      ),
      13 => (
        title: l.descRitualCard13Title,
        prompt: l.descRitualCard13Prompt,
        quote: l.descRitualCard13Quote,
        source: l.descRitualCard13Source,
      ),
      14 => (
        title: l.descRitualCard14Title,
        prompt: l.descRitualCard14Prompt,
        quote: l.descRitualCard14Quote,
        source: l.descRitualCard14Source,
      ),
      15 => (
        title: l.descRitualCard15Title,
        prompt: l.descRitualCard15Prompt,
        quote: l.descRitualCard15Quote,
        source: l.descRitualCard15Source,
      ),
      16 => (
        title: l.descRitualCard16Title,
        prompt: l.descRitualCard16Prompt,
        quote: l.descRitualCard16Quote,
        source: l.descRitualCard16Source,
      ),
      17 => (
        title: l.descRitualCard17Title,
        prompt: l.descRitualCard17Prompt,
        quote: l.descRitualCard17Quote,
        source: l.descRitualCard17Source,
      ),
      18 => (
        title: l.descRitualCard18Title,
        prompt: l.descRitualCard18Prompt,
        quote: l.descRitualCard18Quote,
        source: l.descRitualCard18Source,
      ),
      19 => (
        title: l.descRitualCard19Title,
        prompt: l.descRitualCard19Prompt,
        quote: l.descRitualCard19Quote,
        source: l.descRitualCard19Source,
      ),
      20 => (
        title: l.descRitualCard20Title,
        prompt: l.descRitualCard20Prompt,
        quote: l.descRitualCard20Quote,
        source: l.descRitualCard20Source,
      ),
      21 => (
        title: l.descRitualCard21Title,
        prompt: l.descRitualCard21Prompt,
        quote: l.descRitualCard21Quote,
        source: l.descRitualCard21Source,
      ),
      22 => (
        title: l.descRitualCard22Title,
        prompt: l.descRitualCard22Prompt,
        quote: l.descRitualCard22Quote,
        source: l.descRitualCard22Source,
      ),
      23 => (
        title: l.descRitualCard23Title,
        prompt: l.descRitualCard23Prompt,
        quote: l.descRitualCard23Quote,
        source: l.descRitualCard23Source,
      ),
      24 => (
        title: l.descRitualCard24Title,
        prompt: l.descRitualCard24Prompt,
        quote: l.descRitualCard24Quote,
        source: l.descRitualCard24Source,
      ),
      25 => (
        title: l.descRitualCard25Title,
        prompt: l.descRitualCard25Prompt,
        quote: l.descRitualCard25Quote,
        source: l.descRitualCard25Source,
      ),
      26 => (
        title: l.descRitualCard26Title,
        prompt: l.descRitualCard26Prompt,
        quote: l.descRitualCard26Quote,
        source: l.descRitualCard26Source,
      ),
      27 => (
        title: l.descRitualCard27Title,
        prompt: l.descRitualCard27Prompt,
        quote: l.descRitualCard27Quote,
        source: l.descRitualCard27Source,
      ),
      28 => (
        title: l.descRitualCard28Title,
        prompt: l.descRitualCard28Prompt,
        quote: l.descRitualCard28Quote,
        source: l.descRitualCard28Source,
      ),
      29 => (
        title: l.descRitualCard29Title,
        prompt: l.descRitualCard29Prompt,
        quote: l.descRitualCard29Quote,
        source: l.descRitualCard29Source,
      ),
      30 => (
        title: l.descRitualCard30Title,
        prompt: l.descRitualCard30Prompt,
        quote: l.descRitualCard30Quote,
        source: l.descRitualCard30Source,
      ),
      31 => (
        title: l.descRitualCard31Title,
        prompt: l.descRitualCard31Prompt,
        quote: l.descRitualCard31Quote,
        source: l.descRitualCard31Source,
      ),
      32 => (
        title: l.descRitualCard32Title,
        prompt: l.descRitualCard32Prompt,
        quote: l.descRitualCard32Quote,
        source: l.descRitualCard32Source,
      ),
      33 => (
        title: l.descRitualCard33Title,
        prompt: l.descRitualCard33Prompt,
        quote: l.descRitualCard33Quote,
        source: l.descRitualCard33Source,
      ),
      34 => (
        title: l.descRitualCard34Title,
        prompt: l.descRitualCard34Prompt,
        quote: l.descRitualCard34Quote,
        source: l.descRitualCard34Source,
      ),
      35 => (
        title: l.descRitualCard35Title,
        prompt: l.descRitualCard35Prompt,
        quote: l.descRitualCard35Quote,
        source: l.descRitualCard35Source,
      ),
      36 => (
        title: l.descRitualCard36Title,
        prompt: l.descRitualCard36Prompt,
        quote: l.descRitualCard36Quote,
        source: l.descRitualCard36Source,
      ),
      37 => (
        title: l.descRitualCard37Title,
        prompt: l.descRitualCard37Prompt,
        quote: l.descRitualCard37Quote,
        source: l.descRitualCard37Source,
      ),
      38 => (
        title: l.descRitualCard38Title,
        prompt: l.descRitualCard38Prompt,
        quote: l.descRitualCard38Quote,
        source: l.descRitualCard38Source,
      ),
      39 => (
        title: l.descRitualCard39Title,
        prompt: l.descRitualCard39Prompt,
        quote: l.descRitualCard39Quote,
        source: l.descRitualCard39Source,
      ),
      40 => (
        title: l.descRitualCard40Title,
        prompt: l.descRitualCard40Prompt,
        quote: l.descRitualCard40Quote,
        source: l.descRitualCard40Source,
      ),
      41 => (
        title: l.descRitualCard41Title,
        prompt: l.descRitualCard41Prompt,
        quote: l.descRitualCard41Quote,
        source: l.descRitualCard41Source,
      ),
      42 => (
        title: l.descRitualCard42Title,
        prompt: l.descRitualCard42Prompt,
        quote: l.descRitualCard42Quote,
        source: l.descRitualCard42Source,
      ),
      43 => (
        title: l.descRitualCard43Title,
        prompt: l.descRitualCard43Prompt,
        quote: l.descRitualCard43Quote,
        source: l.descRitualCard43Source,
      ),
      44 => (
        title: l.descRitualCard44Title,
        prompt: l.descRitualCard44Prompt,
        quote: l.descRitualCard44Quote,
        source: l.descRitualCard44Source,
      ),
      45 => (
        title: l.descRitualCard45Title,
        prompt: l.descRitualCard45Prompt,
        quote: l.descRitualCard45Quote,
        source: l.descRitualCard45Source,
      ),
      46 => (
        title: l.descRitualCard46Title,
        prompt: l.descRitualCard46Prompt,
        quote: l.descRitualCard46Quote,
        source: l.descRitualCard46Source,
      ),
      47 => (
        title: l.descRitualCard47Title,
        prompt: l.descRitualCard47Prompt,
        quote: l.descRitualCard47Quote,
        source: l.descRitualCard47Source,
      ),
      48 => (
        title: l.descRitualCard48Title,
        prompt: l.descRitualCard48Prompt,
        quote: l.descRitualCard48Quote,
        source: l.descRitualCard48Source,
      ),
      49 => (
        title: l.descRitualCard49Title,
        prompt: l.descRitualCard49Prompt,
        quote: l.descRitualCard49Quote,
        source: l.descRitualCard49Source,
      ),
      50 => (
        title: l.descRitualCard50Title,
        prompt: l.descRitualCard50Prompt,
        quote: l.descRitualCard50Quote,
        source: l.descRitualCard50Source,
      ),
      _ => throw StateError('No curated text for ritual card $id'),
    };
  }
}

extension RitualThemeText on RitualTheme {
  String nameIn(AppLocalizations l10n) {
    return switch (this) {
      RitualTheme.dharma => l10n.labelRitualThemeDharma,
      RitualTheme.karma => l10n.labelRitualThemeKarma,
      RitualTheme.bhakti => l10n.labelRitualThemeBhakti,
      RitualTheme.jnana => l10n.labelRitualThemeJnana,
      RitualTheme.yoga => l10n.labelRitualThemeYoga,
      RitualTheme.ahimsa => l10n.labelRitualThemeAhimsa,
      RitualTheme.sathya => l10n.labelRitualThemeSathya,
      RitualTheme.vairagya => l10n.labelRitualThemeVairagya,
      RitualTheme.seva => l10n.labelRitualThemeSeva,
      RitualTheme.shanti => l10n.labelRitualThemeShanti,
    };
  }
}

extension BreathTechniqueText on BreathTechnique {
  String nameIn(AppLocalizations l10n) {
    return switch (this) {
      BreathTechnique.boxBreathing => l10n.labelBreathTechniqueBox,
      BreathTechnique.relaxing478 => l10n.labelBreathTechniqueRelaxing,
      BreathTechnique.simpleCalm => l10n.labelBreathTechniqueCalm,
    };
  }

  /// The rhythm in seconds, e.g. `4-7-8`. Digits only, so it needs no
  /// translation; phases that last zero seconds are left out.
  String get rhythm => [
    inhaleSeconds,
    holdInhaleSeconds,
    exhaleSeconds,
    holdExhaleSeconds,
  ].where((s) => s > 0).join('-');
}
