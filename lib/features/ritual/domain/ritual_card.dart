import 'package:flutter/material.dart';

/// Categories for reflection cards in the ritual deck, based on
/// core principles of Sanathana Dharma.
enum RitualTheme {
  dharma,
  karma,
  bhakti,
  jnana,
  yoga,
  ahimsa,
  sathya,
  vairagya,
  seva,
  shanti,
}

extension RitualThemeExt on RitualTheme {
  String get displayName {
    switch (this) {
      case RitualTheme.dharma:
        return 'Dharma';
      case RitualTheme.karma:
        return 'Karma';
      case RitualTheme.bhakti:
        return 'Bhakti';
      case RitualTheme.jnana:
        return 'Jnana';
      case RitualTheme.yoga:
        return 'Yoga';
      case RitualTheme.ahimsa:
        return 'Ahimsa';
      case RitualTheme.sathya:
        return 'Sathya';
      case RitualTheme.vairagya:
        return 'Vairagya';
      case RitualTheme.seva:
        return 'Seva';
      case RitualTheme.shanti:
        return 'Shanti';
    }
  }

  String localizedName(String languageCode) {
    if (languageCode == 'ml') {
      switch (this) {
        case RitualTheme.dharma:
          return 'ധർമ്മം';
        case RitualTheme.karma:
          return 'കർമ്മം';
        case RitualTheme.bhakti:
          return 'ഭക്തി';
        case RitualTheme.jnana:
          return 'ജ്ഞാനം';
        case RitualTheme.yoga:
          return 'യോഗം';
        case RitualTheme.ahimsa:
          return 'അഹിംസ';
        case RitualTheme.sathya:
          return 'സത്യം';
        case RitualTheme.vairagya:
          return 'വൈരാഗ്യം';
        case RitualTheme.seva:
          return 'സേവനം';
        case RitualTheme.shanti:
          return 'ശാന്തി';
      }
    }
    return displayName;
  }

  IconData get icon {
    switch (this) {
      case RitualTheme.dharma:
        return Icons.balance_rounded;
      case RitualTheme.karma:
        return Icons.autorenew_rounded;
      case RitualTheme.bhakti:
        return Icons.favorite_outline_rounded;
      case RitualTheme.jnana:
        return Icons.auto_stories_outlined;
      case RitualTheme.yoga:
        return Icons.self_improvement_rounded;
      case RitualTheme.ahimsa:
        return Icons.spa_outlined;
      case RitualTheme.sathya:
        return Icons.lightbulb_outline_rounded;
      case RitualTheme.vairagya:
        return Icons.eco_outlined;
      case RitualTheme.seva:
        return Icons.volunteer_activism_outlined;
      case RitualTheme.shanti:
        return Icons.water_drop_outlined;
    }
  }

  Color get accentColor {
    switch (this) {
      case RitualTheme.dharma:
        return const Color(0xFFF59E0B); // Amber — cosmic order
      case RitualTheme.karma:
        return const Color(0xFFEF4444); // Red — fire of action
      case RitualTheme.bhakti:
        return const Color(0xFFEC4899); // Pink — love and devotion
      case RitualTheme.jnana:
        return const Color(0xFF3B82F6); // Blue — ocean of knowledge
      case RitualTheme.yoga:
        return const Color(0xFF06B6D4); // Cyan — union and calm
      case RitualTheme.ahimsa:
        return const Color(0xFF10B981); // Emerald — compassion
      case RitualTheme.sathya:
        return const Color(0xFFD97706); // Deep amber — truth
      case RitualTheme.vairagya:
        return const Color(0xFF8B5CF6); // Violet — detachment
      case RitualTheme.seva:
        return const Color(0xFF14B8A6); // Teal — service
      case RitualTheme.shanti:
        return const Color(0xFF6366F1); // Indigo — peace
    }
  }
}

/// A curated reflection card from the Ritual Deck, carrying
/// Sanathana Dharma teachings with English and Malayalam localization.
class RitualCard {
  final String id;
  final int number;
  final RitualTheme theme;
  final String title;
  final String prompt;
  final String quote;
  final String? quoteAuthor;
  final String? titleMl;
  final String? promptMl;
  final String? quoteMl;
  final String? quoteAuthorMl;

  /// True if this card was created by the user (not part of the curated deck).
  final bool isUserCreated;

  /// Database row ID for user-created cards, null for curated cards.
  final int? dbId;

  const RitualCard({
    required this.id,
    required this.number,
    required this.theme,
    required this.title,
    required this.prompt,
    required this.quote,
    this.quoteAuthor,
    this.titleMl,
    this.promptMl,
    this.quoteMl,
    this.quoteAuthorMl,
    this.isUserCreated = false,
    this.dbId,
  });

  String localizedTitle(String languageCode) {
    if (languageCode == 'ml' && titleMl != null && titleMl!.isNotEmpty) {
      return titleMl!;
    }
    return title;
  }

  String localizedPrompt(String languageCode) {
    if (languageCode == 'ml' && promptMl != null && promptMl!.isNotEmpty) {
      return promptMl!;
    }
    return prompt;
  }

  String localizedQuote(String languageCode) {
    if (languageCode == 'ml' && quoteMl != null && quoteMl!.isNotEmpty) {
      return quoteMl!;
    }
    return quote;
  }

  String? localizedQuoteAuthor(String languageCode) {
    if (languageCode == 'ml' &&
        quoteAuthorMl != null &&
        quoteAuthorMl!.isNotEmpty) {
      return quoteAuthorMl!;
    }
    return quoteAuthor;
  }

  /// The complete 50-card Sanathana Dharma reflection deck.
  static const List<RitualCard> curatedDeck = [
    // ────────────────────── DHARMA (1–5) ──────────────────────
    RitualCard(
      id: 'sd_01',
      number: 1,
      theme: RitualTheme.dharma,
      title: 'Your Swadharma',
      prompt:
          'What is the unique duty or calling that only you can fulfil in this season of your life? How are you honouring it today?',
      quote:
          'It is better to perform one\'s own duty imperfectly than to perform another\'s duty perfectly.',
      quoteAuthor: 'Bhagavad Gita 3.35',
      titleMl: 'സ്വധർമ്മം',
      promptMl:
          'നിങ്ങളുടെ ജീവിതത്തിന്റെ ഈ ഘട്ടത്തിൽ നിങ്ങൾക്ക് മാത്രം നിറവേറ്റാൻ കഴിയുന്ന സവിശേഷമായ കടമ എന്താണ്? ഇന്ന് നിങ്ങളത് എങ്ങനെ നിർവഹിക്കുന്നു?',
      quoteMl:
          'മറ്റൊരാളുടെ ധർമ്മം ഭംഗിയായി ചെയ്യുന്നതിനേക്കാൾ ശ്രേഷ്ഠമാണ് സ്വന്തം ധർമ്മം അപൂർണ്ണമായെങ്കിലും അനുഷ്ഠിക്കുന്നത്.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 3.35',
    ),
    RitualCard(
      id: 'sd_02',
      number: 2,
      theme: RitualTheme.dharma,
      title: 'Righteousness in the Small',
      prompt:
          'In what small, everyday action today can you choose what is right over what is easy or popular?',
      quote:
          'Dharma exists for the welfare of all beings. Hence, that by which the welfare of all living beings is sustained, that is Dharma.',
      quoteAuthor: 'Mahabharata, Shanti Parva 109.10',
      titleMl: 'ചെറിയ കാര്യങ്ങളിലെ ധർമ്മം',
      promptMl:
          'ഇന്നത്തെ നിങ്ങളുടെ നിത്യജീവിതത്തിലെ ഏത് ചെറിയ കാര്യത്തിലാണ് എളുപ്പമുള്ളതിനേക്കാൾ ശരിയായ വഴി തിരഞ്ഞെടുക്കാൻ സാധിക്കുക?',
      quoteMl:
          'സർവ്വ ജീവികളുടെയും ക്ഷേമത്തിനായാണ് ധർമ്മം നിലകൊള്ളുന്നത്. എന്തിലൂടെയാണോ സർവ്വ ജീവജാലങ്ങളും നിലനിൽക്കുന്നത്, അതാണ് ധർമ്മം.',
      quoteAuthorMl: 'മഹാഭാരതം, ശാന്തിപർവ്വം 109.10',
    ),
    RitualCard(
      id: 'sd_03',
      number: 3,
      theme: RitualTheme.dharma,
      title: 'The Wheel of Dharma',
      prompt:
          'Reflect on one relationship or responsibility you hold. Are you nurturing it with integrity, or have you been neglecting its call?',
      quote: 'When Dharma is protected, Dharma protects.',
      quoteAuthor: 'Manusmriti 8.15',
      titleMl: 'ധർമ്മചക്രം',
      promptMl:
          'നിങ്ങൾക്കുള്ള ഒരു ബന്ധത്തെയോ ഉത്തരവാദിത്തത്തെയോ കുറിച്ച് ചിന്തിക്കുക. സത്യസന്ധതയോടെയാണോ നിങ്ങൾ അതിനെ പരിപാലിക്കുന്നത്, അതോ അവഗണിക്കുകയാണോ?',
      quoteMl:
          'ധർമ്മോ രക്ഷതി രക്ഷിതഃ — സംരക്ഷിക്കപ്പെടുന്ന ധർമ്മം നമ്മെ സംരക്ഷിക്കുന്നു.',
      quoteAuthorMl: 'മനുസ്മൃതി 8.15',
    ),
    RitualCard(
      id: 'sd_04',
      number: 4,
      theme: RitualTheme.dharma,
      title: 'The Eternal Order',
      prompt:
          'Where in nature — the rising sun, the changing seasons, the flowing river — do you see the rhythm of Rta (cosmic order), and how does it mirror your own life?',
      quote:
          'The rivers flow into the ocean but the ocean never overflows. Likewise, desires flow into the wise one, who remains ever at peace.',
      quoteAuthor: 'Bhagavad Gita 2.70',
      titleMl: 'ശാശ്വത ക്രമം',
      promptMl:
          'പ്രകൃതിയിൽ — ഉദയസൂര്യനിലും ഋതുഭേദങ്ങളിലും ഒഴുകുന്ന നദിയിലും — ഋതത്തിന്റെ (പ്രപഞ്ച ക്രമം) താളം എവിടെയാണ് കാണുന്നത്? അത് നിങ്ങളുടെ ജീവിതത്തെ എങ്ങനെ പ്രതിഫലിപ്പിക്കുന്നു?',
      quoteMl:
          'സമുദ്രത്തിലേക്ക് നദികൾ ഒഴുകിയെത്തിയാലും സമുദ്രം കരകവിയാത്തതുപോലെ, ആഗ്രഹങ്ങൾ ഉള്ളിലൊഴുകിയെത്തുമ്പോഴും ജ്ഞാനി സദാ ശാന്തനായിരിക്കുന്നു.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 2.70',
    ),
    RitualCard(
      id: 'sd_05',
      number: 5,
      theme: RitualTheme.dharma,
      title: 'Dharma in Adversity',
      prompt:
          'When life tests you, what principle or value do you refuse to compromise? Why does it matter to you?',
      quote:
          'Even in the most difficult of times, one should not abandon Dharma.',
      quoteAuthor: 'Ramayana, Ayodhya Kanda',
      titleMl: 'പ്രതിസന്ധിയിലെ ധർമ്മം',
      promptMl:
          'ജീവിതം പരീക്ഷണങ്ങൾ നേരിടുമ്പോൾ, വിട്ടുവീഴ്ച ചെയ്യാൻ നിങ്ങൾ വിസമ്മതിക്കുന്ന മൂല്യം ഏതാണ്? എന്തുകൊണ്ടാണ് അത് നിങ്ങൾക്ക് അത്ര പ്രധാനമാകുന്നത്?',
      quoteMl:
          'ഏറ്റവും കഠിനമായ പ്രതിസന്ധികളിലും ഒരാൾ ധർമ്മം ഉപേക്ഷിക്കാൻ പാടില്ല.',
      quoteAuthorMl: 'രാമായണം, അയോദ്ധ്യാകാണ്ഡം',
    ),

    // ────────────────────── KARMA (6–10) ──────────────────────
    RitualCard(
      id: 'sd_06',
      number: 6,
      theme: RitualTheme.karma,
      title: 'Action Without Attachment',
      prompt:
          'What is one task or effort you are doing today where you can let go of the result and focus purely on the quality of your action?',
      quote:
          'You have the right to perform your duty, but you are not entitled to the fruits of your actions.',
      quoteAuthor: 'Bhagavad Gita 2.47',
      titleMl: 'നിഷ്കാമ കർമ്മം',
      promptMl:
          'ഫലത്തെക്കുറിച്ചുള്ള ആശങ്ക ഉപേക്ഷിച്ച്, പ്രവൃത്തിയുടെ ഗുണമേന്മയിൽ മാത്രം ശ്രദ്ധ കേന്ദ്രീകരിക്കാൻ നിങ്ങൾക്ക് കഴിയുന്ന ഒരു കാര്യം എന്താണ്?',
      quoteMl:
          'കർമ്മണ്യേവാധികാരസ്തേ മാ ഫലേഷു കദാചന — കർമ്മം ചെയ്യാൻ മാത്രമേ നിങ്ങൾക്ക് അധികാരമുള്ളൂ, ഫലങ്ങളിൽ ഒരിക്കലുമില്ല.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 2.47',
    ),
    RitualCard(
      id: 'sd_07',
      number: 7,
      theme: RitualTheme.karma,
      title: 'The Seed You Plant Today',
      prompt:
          'Every action is a seed. What kind of seed — patience, kindness, discipline, or something else — are you planting today?',
      quote:
          'As a man sows, so shall he reap. There is no escape from the fruits of one\'s actions.',
      quoteAuthor: 'Mahabharata, Vana Parva',
      titleMl: 'ഇന്ന് നടുന്ന വിത്ത്',
      promptMl:
          'ഓരോ പ്രവൃത്തിയും ഒരു വിത്താണ്. ക്ഷമ, ദയ, അച്ചടക്കം — ഇതിൽ ഏതുതരം വിത്താണ് നിങ്ങൾ ഇന്ന് നടുന്നത്?',
      quoteMl:
          'ഒരുവൻ എന്താണോ വിതയ്ക്കുന്നത്, അത് അവൻ കൊയ്യും. സ്വന്തം കർമ്മഫലങ്ങളിൽ നിന്ന് ആർക്കും ഒഴിഞ്ഞുമാറാനാവില്ല.',
      quoteAuthorMl: 'മഹാഭാരതം, വനപർവ്വം',
    ),
    RitualCard(
      id: 'sd_08',
      number: 8,
      theme: RitualTheme.karma,
      title: 'Nishkama Karma',
      prompt:
          'Think of something you did purely for its own sake, without wanting praise or reward. How did that feel? Can you bring that spirit to more of your day?',
      quote:
          'The wise, engaged in selfless action, surrender all attachment to results and attain supreme peace.',
      quoteAuthor: 'Bhagavad Gita 5.12',
      titleMl: 'നിസ്വാർത്ഥ സേവനം',
      promptMl:
          'പ്രശംസയോ പ്രതിഫലമോ ആഗ്രഹിക്കാതെ ചെയ്ത ഒരു കാര്യത്തെക്കുറിച്ച് ചിന്തിക്കുക. അപ്പോൾ എന്ത് തോന്നി? ആ മനോഭാവം ഇന്നത്തെ കൂടുതൽ കാര്യങ്ങളിലേക്ക് കൊണ്ടുവരാനാകുമോ?',
      quoteMl:
          'നിസ്വാർത്ഥ കർമ്മങ്ങളിൽ മുഴുകുന്ന ജ്ഞാനികൾ ഫലത്തിലുള്ള ആസക്തി വെടിഞ്ഞ് പരമശാന്തി പ്രാപിക്കുന്നു.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 5.12',
    ),
    RitualCard(
      id: 'sd_09',
      number: 9,
      theme: RitualTheme.karma,
      title: 'Breaking the Chain',
      prompt:
          'Is there a pattern of reaction — anger, avoidance, blame — that you keep repeating? What would it look like to consciously choose a different response today?',
      quote:
          'One who restrains the senses and organs of action, but whose mind dwells on sense objects, is deluded and called a hypocrite.',
      quoteAuthor: 'Bhagavad Gita 3.6',
      titleMl: 'ശീലങ്ങളുടെ ചങ്ങല പൊട്ടിക്കുക',
      promptMl:
          'ദേഷ്യം, ഒളിച്ചോട്ടം, പഴിചാരൽ തുടങ്ങി നിങ്ങൾ ആവർത്തിക്കുന്ന എന്തെങ്കിലും പ്രതികരണ രീതിയുണ്ടോ? ഇന്ന് ബോധപൂർവ്വം മറ്റൊരു പ്രതികരണം തിരഞ്ഞെടുത്താൽ എങ്ങനെയിരിക്കും?',
      quoteMl:
          'കർമ്മേന്ദ്രിയങ്ങളെ അടക്കി നിർത്തുമ്പോഴും മനസ്സ് വിഷയങ്ങളിൽ വ്യാപരിക്കുന്നവൻ വ്യാജനാണ്.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 3.6',
    ),
    RitualCard(
      id: 'sd_10',
      number: 10,
      theme: RitualTheme.karma,
      title: 'Karma Yoga in Daily Life',
      prompt:
          'How can you transform an ordinary task today — cooking, cleaning, working — into an offering, performing it with full attention and devotion?',
      quote:
          'Whatever you do, whatever you eat, whatever you offer in sacrifice, whatever you give, whatever austerity you practise — do it as an offering to Me.',
      quoteAuthor: 'Bhagavad Gita 9.27',
      titleMl: 'നിത്യജീവിതത്തിലെ കർമ്മയോഗം',
      promptMl:
          'പാചകം, ജോലി തുടങ്ങിയ ദൈനംദിന കാര്യങ്ങളെ പൂർണ്ണ ശ്രദ്ധയോടും സമർപ്പണത്തോടും കൂടി ഒരു വഴിപാടായി മാറ്റാൻ എങ്ങനെ സാധിക്കും?',
      quoteMl:
          'നീ എന്തു ചെയ്യുന്നുവോ, എന്ത് ഭക്ഷിക്കുന്നുവോ, എന്ത് ഹോമിക്കുന്നുവോ, എന്ത് ദാനം ചെയ്യുന്നുവോ, അതെല്ലാം എനിക്കുള്ള സമർപ്പണമായി ചെയ്യുക.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 9.27',
    ),

    // ────────────────────── BHAKTI (11–15) ──────────────────────
    RitualCard(
      id: 'sd_11',
      number: 11,
      theme: RitualTheme.bhakti,
      title: 'The Heart of Devotion',
      prompt:
          'What fills your heart with reverence and love — a prayer, a memory, a place, the thought of the Divine? Dwell on it now.',
      quote:
          'Whoever offers Me with devotion a leaf, a flower, a fruit, or water — that offering of love I accept from the pure-hearted.',
      quoteAuthor: 'Bhagavad Gita 9.26',
      titleMl: 'ഭക്തിയുടെ ഹൃദയം',
      promptMl:
          'ഒരു പ്രാർത്ഥന, ഒരു ഓർമ്മ, ഒരു പുണ്യസ്ഥലം, ദൈവചിന്ത — നിങ്ങളുടെ ഹൃദയത്തിൽ ആദരവും സ്നേഹവും നിറയ്ക്കുന്നത് എന്താണ്? അതിൽ മനസ്സ് ഏകാഗ്രമാക്കുക.',
      quoteMl:
          'ഭക്തിയോടെ ഒരു ഇലയോ പൂവോ ഫലമോ ജലമോ എനിക്ക് സമർപ്പിച്ചാൽ, ശുദ്ധമനസ്സോടെയുള്ള ആ സ്നേഹസമർപ്പണം ഞാൻ സ്വീകരിക്കുന്നു.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 9.26',
    ),
    RitualCard(
      id: 'sd_12',
      number: 12,
      theme: RitualTheme.bhakti,
      title: 'Surrender and Trust',
      prompt:
          'What worry or burden can you mentally place at the feet of the Divine today, trusting that grace will carry you through?',
      quote:
          'Abandon all varieties of Dharma and simply surrender unto Me. I shall deliver you from all sinful reactions; do not fear.',
      quoteAuthor: 'Bhagavad Gita 18.66',
      titleMl: 'ആത്മസമർപ്പണവും വിശ്വാസവും',
      promptMl:
          'ഈശ്വരകൃപ നിങ്ങളെ നയിക്കുമെന്ന പൂർണ്ണവിശ്വാസത്തോടെ ഇന്ന് ഏത് ഭാരമാണ് ഈശ്വരപാദങ്ങളിൽ സമർപ്പിക്കാൻ കഴിയുക?',
      quoteMl:
          'സർവ്വധർമ്മാൻ പരിത്യജ്യ മാമേകം ശരണം വ്രജ — സർവ്വ ധർമ്മങ്ങളും ഉപേക്ഷിച്ച് എന്നെ മാത്രം ശരണം പ്രാപിക്കുക. ഞാൻ നിന്നെ സർവ്വ പാപങ്ങളിൽ നിന്നും മോചിപ്പിക്കാം; ഭയപ്പെടേണ്ട.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 18.66',
    ),
    RitualCard(
      id: 'sd_13',
      number: 13,
      theme: RitualTheme.bhakti,
      title: 'Seeing God in All',
      prompt:
          'Can you look at every person you meet today as a form of the Divine? How would that change the way you speak and listen?',
      quote:
          'The wise see the same Divine Self equally in a learned Brahmin, a cow, an elephant, a dog, and an outcaste.',
      quoteAuthor: 'Bhagavad Gita 5.18',
      titleMl: 'സർവ്വത്തിലും ഈശ്വരദർശനം',
      promptMl:
          'ഇന്ന് നിങ്ങൾ കണ്ടുമുട്ടുന്ന ഓരോ വ്യക്തിയെയും ഈശ്വരസ്വരൂപമായി കാണാൻ കഴിയുമോ? അത് നിങ്ങളുടെ സംസാരത്തെയും കേൾവിയെയും എങ്ങനെ മാറ്റും?',
      quoteMl:
          'വിദ്യാസമ്പന്നനായ ബ്രാഹ്മണനിലും പശുവിലും ആനയിലും നായയിലും ചണ്ഡാളനിലും ജ്ഞാനികൾ ഒരേ ആത്മാവിനെ തുല്യമായി ദർശിക്കുന്നു.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 5.18',
    ),
    RitualCard(
      id: 'sd_14',
      number: 14,
      theme: RitualTheme.bhakti,
      title: 'The Name that Purifies',
      prompt:
          'When was the last time you sat quietly and repeated a sacred name or mantra? What feelings arose when you did?',
      quote:
          'The name of the Lord is the boat that will take you across the ocean of worldly existence.',
      quoteAuthor: 'Tulsidas, Ramcharitmanas',
      titleMl: 'വിശുദ്ധമാക്കുന്ന നാമം',
      promptMl:
          'ശാന്തമായിരുന്ന് ഒരു പുണ്യനാമമോ മന്ത്രമോ ഉരുവിട്ടത് എപ്പോഴായിരുന്നു? അത് നിങ്ങളുടെ മനസ്സിൽ എന്ത് മാറ്റമാണുണ്ടാക്കിയത്?',
      quoteMl:
          'ഭവസമുദ്രം കടക്കാൻ ഭഗവാന്റെ നാമമെന്ന തോണിയല്ലാതെ മറ്റൊന്നുമില്ല.',
      quoteAuthorMl: 'തുളസീദാസ്, രാമചരിതമാനസം',
    ),
    RitualCard(
      id: 'sd_15',
      number: 15,
      theme: RitualTheme.bhakti,
      title: 'Grace in Gratitude',
      prompt:
          'What unexpected blessing or moment of grace have you received recently that you have not yet paused to acknowledge?',
      quote:
          'I am the origin of all. Everything emanates from Me. The wise who know this worship Me with loving devotion.',
      quoteAuthor: 'Bhagavad Gita 10.8',
      titleMl: 'കൃതജ്ഞതയിലെ കൃപ',
      promptMl:
          'നിങ്ങൾക്ക് ലഭിച്ച അപ്രതീക്ഷിതമായ അനുഗ്രഹങ്ങളിൽ ഇതുവരെ കൃതജ്ഞതയോടെ ഓർക്കാത്ത ഒന്ന് ഏതാണ്?',
      quoteMl:
          'ഞാൻ സർവ്വത്തിന്റെയും ഉത്ഭവസ്ഥാനമാണ്. എല്ലാം എന്നിൽ നിന്നാണ് ഉണ്ടാകുന്നത്. ഇതറിയുന്ന ജ്ഞാനികൾ ഭക്തിയോടെ എന്നെ ഭജിക്കുന്നു.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 10.8',
    ),

    // ────────────────────── JNANA (16–22) ──────────────────────
    RitualCard(
      id: 'sd_16',
      number: 16,
      theme: RitualTheme.jnana,
      title: 'Who Am I?',
      prompt:
          'Strip away your name, your job, your roles, your body. What remains? Sit with this question: Who am I beyond all labels?',
      quote: 'Tat Tvam Asi — Thou art That.',
      quoteAuthor: 'Chandogya Upanishad 6.8.7',
      titleMl: 'ഞാൻ ആര്?',
      promptMl:
          'പേര്, ജോലി, സ്ഥാനമാനങ്ങൾ, ശരീരം എന്നിവയെല്ലാം മാറ്റിവെച്ചാൽ എന്താണ് ബാക്കിയുള്ളത്? ഈ ചോദ്യവുമായി അല്പനേരം ഇരിക്കുക: എല്ലാ ലേബലുകൾക്കും അപ്പുറം ഞാൻ ആരാണ്?',
      quoteMl: 'തത്ത്വമസി — അത് നീയാകുന്നു.',
      quoteAuthorMl: 'ഛാന്ദോഗ്യോപനിഷത്ത് 6.8.7',
    ),
    RitualCard(
      id: 'sd_17',
      number: 17,
      theme: RitualTheme.jnana,
      title: 'The Eternal Witness',
      prompt:
          'Observe your thoughts passing by without grasping any of them. Who is the one watching? Can that awareness itself ever be harmed?',
      quote:
          'The Self is never born, nor does it die. It is eternal, ever-existing, and primeval. It is not slain when the body is slain.',
      quoteAuthor: 'Bhagavad Gita 2.20',
      titleMl: 'സാക്ഷിചൈതന്യം',
      promptMl:
          'ചിന്തകളെ പിടിച്ചുവെക്കാതെ കടന്നുപോകുന്നത് നിരീക്ഷിക്കുക. അതിനെ വീക്ഷിക്കുന്ന സാക്ഷി ആരാണ്? ആ ബോധത്തിന് എപ്പോഴെങ്കിലും മുറിവേൽക്കാൻ കഴിയുമോ?',
      quoteMl:
          'ആത്മാവ് ജനിക്കുന്നില്ല, മരിക്കുന്നതുമില്ല. അത് നിത്യവും ശാശ്വതവുമാണ്. ശരീരം നശിക്കുമ്പോഴും അത് നശിക്കുന്നില്ല.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 2.20',
    ),
    RitualCard(
      id: 'sd_18',
      number: 18,
      theme: RitualTheme.jnana,
      title: 'Knowledge That Frees',
      prompt:
          'What is one truth about yourself or about life that, once you truly accepted it, freed you from suffering?',
      quote:
          'There is nothing as purifying in this world as knowledge. One who has attained purity of mind through prolonged Yoga discovers this knowledge within, in due course of time.',
      quoteAuthor: 'Bhagavad Gita 4.38',
      titleMl: 'മുക്തിയേകുന്ന ജ്ഞാനം',
      promptMl:
          'ജീവിതത്തെക്കുറിച്ചോ നിങ്ങളെക്കുറിച്ചോ ഉള്ള ഏത് സത്യമാണ് പൂർണ്ണമായി ഉൾക്കൊണ്ടപ്പോൾ നിങ്ങളെ ദുഃഖങ്ങളിൽ നിന്ന് മോചിപ്പിച്ചത്?',
      quoteMl:
          'ജ്ഞാനത്തിന് തുല്യമായി പവിത്രമായത് ഈ ലോകത്തിൽ മറ്റൊന്നുമില്ല. യോഗനിഷ്ഠയിലൂടെ മനസ്സ് ശുദ്ധമായവൻ ഈ ജ്ഞാനം തന്നിൽത്തന്നെ കണ്ടെത്തുന്നു.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 4.38',
    ),
    RitualCard(
      id: 'sd_19',
      number: 19,
      theme: RitualTheme.jnana,
      title: 'Beyond the Senses',
      prompt:
          'Your senses show you the surface of things. What deeper truth lies beneath the situation you are facing right now?',
      quote:
          'Beyond the senses are the objects; beyond the objects is the mind; beyond the mind is the intellect; beyond the intellect is the Great Self.',
      quoteAuthor: 'Katha Upanishad 1.3.10',
      titleMl: 'ഇന്ദ്രിയങ്ങൾക്കപ്പുറം',
      promptMl:
          'ഇന്ദ്രിയങ്ങൾ ബാഹ്യമായ കാഴ്ചകൾ മാത്രമാണ് കാണിക്കുന്നത്. നിങ്ങൾ ഇപ്പോൾ അഭിമുഖീകരിക്കുന്ന സാഹചര്യത്തിന് പിന്നിലുള്ള ആഴമേറിയ സത്യം എന്താണ്?',
      quoteMl:
          'ഇന്ദ്രിയങ്ങൾക്ക് അപ്പുറം വിഷയങ്ങളും, വിഷയങ്ങൾക്ക് അപ്പുറം മനസ്സും, മനസ്സിന് അപ്പുറം ബുദ്ധിയും, ബുദ്ധിക്ക് അപ്പുറം ആത്മാവും സ്ഥിതിചെയ്യുന്നു.',
      quoteAuthorMl: 'കഠോപനിഷത്ത് 1.3.10',
    ),
    RitualCard(
      id: 'sd_20',
      number: 20,
      theme: RitualTheme.jnana,
      title: 'The Light Within',
      prompt:
          'Close your eyes. Imagine a steady flame burning in your heart that no wind can extinguish. What does this light illuminate for you?',
      quote:
          'Asato ma sadgamaya, tamaso ma jyotirgamaya, mrityorma amritam gamaya. Lead me from the unreal to the Real, from darkness to Light, from death to Immortality.',
      quoteAuthor: 'Brihadaranyaka Upanishad 1.3.28',
      titleMl: 'ഉള്ളിലെ പ്രകാശം',
      promptMl:
          'കണ്ണുകളടച്ച് ഹൃദയത്തിൽ കെടാതെ കത്തുന്ന ഒരു തിരിനാളം സങ്കൽപ്പിക്കുക. ആ പ്രകാശം നിങ്ങളുടെ ഉള്ളിൽ എന്തിനെയാണ് വെളിച്ചത്തു കൊണ്ടുവരുന്നത്?',
      quoteMl:
          'അസതോ മാ സദ്ഗമയ, തമസോ മാ ജ്യോതിർഗമയ, മൃത്യോർ മാ അമൃതം ഗമയ — അസത്യത്തിൽ നിന്ന് സത്യത്തിലേക്കും, ഇരുളിൽ നിന്ന് വെളിച്ചത്തിലേക്കും, മരണത്തിൽ നിന്ന് അമരത്വത്തിലേക്കും നയിച്ചാലും.',
      quoteAuthorMl: 'ബൃഹദാരണ്യകോപനിഷത്ത് 1.3.28',
    ),
    RitualCard(
      id: 'sd_21',
      number: 21,
      theme: RitualTheme.jnana,
      title: 'The Fullness of Being',
      prompt:
          'If you lack nothing at the deepest level, why do you feel incomplete? Reflect on what it means to be already whole.',
      quote:
          'Om Purnamadah Purnamidam — That is Whole, this is Whole. From the Whole, the Whole arises. When the Whole is taken from the Whole, the Whole still remains.',
      quoteAuthor: 'Isha Upanishad, Invocation',
      titleMl: 'പൂർണ്ണത',
      promptMl:
          'ആന്തരിക തലത്തിൽ നിങ്ങൾക്ക് ഒന്നിനും കുറവില്ലെങ്കിൽ, എന്തുകൊണ്ടാണ് അപൂർണ്ണത തോന്നുന്നത്? നിങ്ങൾ ഇതിനകം പൂർണ്ണനാണെന്ന സത്യത്തെക്കുറിച്ച് ചിന്തിക്കുക.',
      quoteMl:
          'ഓം പൂർണ്ണമദഃ പൂർണ്ണമിദം — അതും പൂർണ്ണം, ഇതും പൂർണ്ണം. പൂർണ്ണത്തിൽ നിന്ന് പൂർണ്ണമുണ്ടാകുന്നു. പൂർണ്ണത്തിൽ നിന്ന് പൂർണ്ണമെടുത്താലും പൂർണ്ണം അവശേഷിക്കുന്നു.',
      quoteAuthorMl: 'ഈശാവാസ്യോപനിഷത്ത്, ശാന്തിപാഠം',
    ),
    RitualCard(
      id: 'sd_22',
      number: 22,
      theme: RitualTheme.jnana,
      title: 'Brahman in Everything',
      prompt:
          'The same consciousness that shines through you shines through every living being. How does this awareness change the way you see the world today?',
      quote: 'Aham Brahmasmi — I am Brahman.',
      quoteAuthor: 'Brihadaranyaka Upanishad 1.4.10',
      titleMl: 'സർവ്വവ്യാപിയായ ബ്രഹ്മം',
      promptMl:
          'നിങ്ങളിൽ പ്രകാശിക്കുന്ന അതേ ചൈതന്യമാണ് സർവ്വ ജീവജാലങ്ങളിലും പ്രകാശിക്കുന്നത്. ഈ അറിവ് ഇന്ന് ലോകത്തെ നോക്കിക്കാണുന്ന രീതിയെ എങ്ങനെ മാറ്റുന്നു?',
      quoteMl: 'അഹം ബ്രഹ്മാസ്മി — ഞാൻ ബ്രഹ്മമാകുന്നു.',
      quoteAuthorMl: 'ബൃഹദാരണ്യകോപനിഷത്ത് 1.4.10',
    ),

    // ────────────────────── YOGA (23–27) ──────────────────────
    RitualCard(
      id: 'sd_23',
      number: 23,
      theme: RitualTheme.yoga,
      title: 'Stilling the Mind',
      prompt:
          'Right now, observe the fluctuations of your mind — planning, worrying, remembering. Can you gently bring all of them to stillness, even for a few breaths?',
      quote:
          'Yogas chitta vritti nirodhah — Yoga is the cessation of the fluctuations of the mind.',
      quoteAuthor: 'Yoga Sutras of Patanjali 1.2',
      titleMl: 'മനസ്സിനെ അടക്കൽ',
      promptMl:
          'ചിന്തകൾ, ആകുലതകൾ, ഓർമ്മകൾ — മനസ്സിന്റെ ചാഞ്ചാട്ടങ്ങൾ ഇപ്പോൾ നിരീക്ഷിക്കുക. ഏതാനും ശ്വാസനേരത്തേക്ക് അവയെ ശാന്തമാക്കാൻ കഴിയുമോ?',
      quoteMl:
          'യോഗശ്ചിത്തവൃത്തിനിരോധഃ — മനസ്സിന്റെ വൃത്തികളെ അടക്കുന്നതാണ് യോഗം.',
      quoteAuthorMl: 'പതഞ്ജലി യോഗസൂത്രം 1.2',
    ),
    RitualCard(
      id: 'sd_24',
      number: 24,
      theme: RitualTheme.yoga,
      title: 'Steady Practice',
      prompt:
          'What is one positive habit or practice you can commit to with patience and devotion, knowing that consistency matters more than intensity?',
      quote:
          'Abhyasa — practice becomes firmly grounded when it is pursued for a long time, without interruption, and with sincere devotion.',
      quoteAuthor: 'Yoga Sutras of Patanjali 1.14',
      titleMl: 'നിരന്തര അഭ്യാസം',
      promptMl:
          'തീവ്രതയേക്കാൾ പ്രധാനം സ്ഥിരതയാണെന്നറിഞ്ഞ്, ക്ഷമയോടും ഭക്തിയോടും കൂടി നിങ്ങൾക്ക് തുടരാൻ കഴിയുന്ന നല്ലൊരു ശീലം ഏതാണ്?',
      quoteMl:
          'ദീർഘകാലം, ഇടവേളകളില്ലാതെ, ആത്മാർത്ഥതയോടെ ശീലിക്കുമ്പോൾ അഭ്യാസം ദൃഢമായിത്തീരുന്നു.',
      quoteAuthorMl: 'പതഞ്ജലി യോഗസൂത്രം 1.14',
    ),
    RitualCard(
      id: 'sd_25',
      number: 25,
      theme: RitualTheme.yoga,
      title: 'Evenness of Mind',
      prompt:
          'Recall a recent moment of success and a moment of failure. Can you hold both with the same steady awareness, without elation or despair?',
      quote: 'Yoga is equanimity of mind — samatvam yoga uchyate.',
      quoteAuthor: 'Bhagavad Gita 2.48',
      titleMl: 'സമചിത്തത',
      promptMl:
          'അടുത്തിടെയുണ്ടായ ഒരു വിജയവും പരാജയവും ഓർക്കുക. അമിതാഹ്ലാദമോ നിരാശയോ ഇല്ലാതെ രണ്ടിനെയും സമചിത്തതയോടെ കാണാൻ കഴിയുമോ?',
      quoteMl: 'സമത്വം യോഗ ഉച്യതേ — സമചിത്തതയാണ് യോഗം.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 2.48',
    ),
    RitualCard(
      id: 'sd_26',
      number: 26,
      theme: RitualTheme.yoga,
      title: 'The Five Yamas',
      prompt:
          'Non-violence, truthfulness, non-stealing, moderation, non-possessiveness — which of the five Yamas is the hardest for you right now, and why?',
      quote:
          'Ahimsa, Satya, Asteya, Brahmacharya, Aparigraha — these are the great universal vows.',
      quoteAuthor: 'Yoga Sutras of Patanjali 2.30',
      titleMl: 'പഞ്ചയമങ്ങൾ',
      promptMl:
          'അഹിംസ, സത്യം, അസ്തേയം, ബ്രഹ്മచర్യം, അപരിഗ്രഹം — ഈ അഞ്ചിൽ ഇപ്പോൾ നിങ്ങൾക്ക് ഏറ്റവും വെല്ലുവിളിയാകുന്നത് ഏതാണ്, എന്തുകൊണ്ട്?',
      quoteMl:
          'അഹിംസ, സത്യം, അസ്തേയം, ബ്രഹ്മచర్യം, അപരിഗ്രഹം — ഇവ സാർവ്വലൗകികമായ മഹാവ്രതങ്ങളാണ്.',
      quoteAuthorMl: 'പതഞ്ജലി യോഗസൂത്രം 2.30',
    ),
    RitualCard(
      id: 'sd_27',
      number: 27,
      theme: RitualTheme.yoga,
      title: 'Ishvara Pranidhana',
      prompt:
          'What does it feel like to offer your effort completely — not to achieve, but to dedicate? Try offering your next action to something greater than yourself.',
      quote: 'By total surrender to Ishvara, Samadhi is attained.',
      quoteAuthor: 'Yoga Sutras of Patanjali 2.45',
      titleMl: 'ഈശ്വരപ്രണിധാനം',
      promptMl:
          'സ്വന്തം നേട്ടത്തിനല്ലാതെ, പൂർണ്ണ സമർപ്പണമായി പ്രവൃത്തി ചെയ്യുമ്പോൾ എന്ത് അനുഭവപ്പെടുന്നു? നിങ്ങളുടെ അടുത്ത പ്രവൃത്തി മഹത്തായ ഒന്നിനായി സമർപ്പിക്കുക.',
      quoteMl: 'ഈശ്വരനിലുള്ള പൂർണ്ണ സമർപ്പണത്തിലൂടെ സമാധി സിദ്ധിക്കുന്നു.',
      quoteAuthorMl: 'പതഞ്ജലി യോഗസൂത്രം 2.45',
    ),

    // ────────────────────── AHIMSA (28–31) ──────────────────────
    RitualCard(
      id: 'sd_28',
      number: 28,
      theme: RitualTheme.ahimsa,
      title: 'Non-Violence in Thought',
      prompt:
          'Have you directed harsh, violent thoughts towards yourself or someone else today? What would it mean to replace them with understanding?',
      quote: 'Ahimsa Paramo Dharma — Non-violence is the highest Dharma.',
      quoteAuthor: 'Mahabharata, Anushasana Parva 116.38',
      titleMl: 'മനസ്സിലെ അഹിംസ',
      promptMl:
          'ഇന്ന് നിങ്ങളോടോ മറ്റുള്ളവരോടോ പരുഷമായ ചിന്തകൾ പുലർത്തിയിട്ടുണ്ടോ? അവയ്ക്ക് പകരം സ്നേഹവും കാരുണ്യവും പകരുന്നത് എങ്ങനെയുണ്ടാകും?',
      quoteMl: 'അഹിംസാ പരമോ ധർമ്മഃ — അഹിംസയാണ് പരമമായ ധർമ്മം.',
      quoteAuthorMl: 'മഹാഭാരതം, അനുശാസനപർവ്വം 116.38',
    ),
    RitualCard(
      id: 'sd_29',
      number: 29,
      theme: RitualTheme.ahimsa,
      title: 'Compassion for All Beings',
      prompt:
          'Think of a creature — an animal, an insect, a bird — you encountered recently. What would the world be like if you extended the same care to all living beings?',
      quote:
          'One who sees all beings in the Self and the Self in all beings, never turns away from it.',
      quoteAuthor: 'Isha Upanishad, Verse 6',
      titleMl: 'സർവ്വഭൂതദയ',
      promptMl:
          'അടുത്തിടെ കണ്ട ഒരു പക്ഷിയെക്കുറിച്ചോ മൃഗത്തെക്കുറിച്ചോ ചിന്തിക്കുക. സർവ്വ ജീവജാലങ്ങളോടും ആ കാരുണ്യം കാണിച്ചാൽ ഈ ലോകം എത്ര സുന്ദരമാകും?',
      quoteMl:
          'സർവ്വ ജീവികളിലും ആത്മാവിനെയും ആത്മാവിൽ സർവ്വ ജീവികളെയും ദർശിക്കുന്നവൻ ആരെയും വെറുക്കുന്നില്ല.',
      quoteAuthorMl: 'ഈശാവാസ്യോപനിഷത്ത്, മന്ത്രം 6',
    ),
    RitualCard(
      id: 'sd_30',
      number: 30,
      theme: RitualTheme.ahimsa,
      title: 'Gentle Speech',
      prompt:
          'Before you speak today, pause and ask: Is it true? Is it kind? Is it necessary? How does this filter change your conversations?',
      quote:
          'Words that do not cause distress, that are truthful, pleasant, and beneficial — this is called the austerity of speech.',
      quoteAuthor: 'Bhagavad Gita 17.15',
      titleMl: 'മൃദുവായ വാക്ക്',
      promptMl:
          'സംസാരിക്കുന്നതിന് മുൻപ് സ്വയം ചോദിക്കുക: ഇത് സത്യമാണോ? പ്രിയമുള്ളതാണോ? ആവശ്യമാണോ? ഈ ചിന്ത നിങ്ങളുടെ സംഭാഷണങ്ങളെ എങ്ങനെ മാറ്റുന്നു?',
      quoteMl:
          'ഉദ്വേഗമുണ്ടാക്കാത്തതും സത്യവും പ്രിയവും ഹിതവുമായ സംസാരമാണ് വാങ്മയ തപസ്സ്.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 17.15',
    ),
    RitualCard(
      id: 'sd_31',
      number: 31,
      theme: RitualTheme.ahimsa,
      title: 'Forgiving the Hurt',
      prompt:
          'Who has caused you pain that you are still carrying? What would it take to forgive — not for them, but to free your own heart?',
      quote: 'Forgiveness is the ornament of the brave.',
      quoteAuthor: 'Mahabharata, Udyoga Parva 33.48',
      titleMl: 'ക്ഷമയുടെ മഹത്വം',
      promptMl:
          'നിങ്ങളെ വേദനിപ്പിച്ച ആരുടെ ഓർമ്മയാണ് ഇപ്പോഴും ചുമക്കുന്നത്? സ്വന്തം മനസ്സിന്റെ സ്വാതന്ത്ര്യത്തിനായി അവരോട് ക്ഷമിക്കാൻ എന്ത് മാറ്റമാണ് വേണ്ടത്?',
      quoteMl: 'ക്ഷമ വീരന്മാരുടെ ഭൂഷണമാണ്.',
      quoteAuthorMl: 'മഹാഭാരതം, ഉദ്യോഗപർവ്വം 33.48',
    ),

    // ────────────────────── SATHYA (32–35) ──────────────────────
    RitualCard(
      id: 'sd_32',
      number: 32,
      theme: RitualTheme.sathya,
      title: 'Living in Truth',
      prompt:
          'Is there something in your life where you are being less than truthful — with yourself or with others? What would honest alignment look like?',
      quote: 'Satyameva Jayate — Truth alone triumphs.',
      quoteAuthor: 'Mundaka Upanishad 3.1.6',
      titleMl: 'സത്യത്തിൽ ജീവിക്കുക',
      promptMl:
          'നിങ്ങളോടോ മറ്റുള്ളവരോടോ സത്യസന്ധതയില്ലാതെ പെരുമാറുന്ന എന്തെങ്കിലും ഉണ്ടോ? പൂർണ്ണമായ സത്യസന്ധത പുലർത്തിയാൽ അത് എങ്ങനെയുണ്ടാകും?',
      quoteMl: 'സത്യമേവ ജയതേ — സത്യം മാത്രം ജയിക്കുന്നു.',
      quoteAuthorMl: 'മുണ്ഡകോപനിഷത്ത് 3.1.6',
    ),
    RitualCard(
      id: 'sd_33',
      number: 33,
      theme: RitualTheme.sathya,
      title: 'The Courage of Honesty',
      prompt:
          'What is one truth you have been avoiding because it is uncomfortable? What would it take to face it with courage today?',
      quote:
          'Speak the truth. Practise Dharma. Do not neglect the study of the scriptures.',
      quoteAuthor: 'Taittiriya Upanishad 1.11.1',
      titleMl: 'നേരിന്റെ ധൈര്യം',
      promptMl:
          'അസ്വസ്ഥത തോന്നുമെന്നതിനാൽ നിങ്ങൾ അഭിമുഖീകരിക്കാൻ മടിക്കുന്ന ഒരു സത്യം എന്താണ്? ധൈര്യത്തോടെ അതിനെ നേരിടാൻ എന്ത് വേണം?',
      quoteMl: 'സത്യം വദ, ധർമ്മം ചര — സത്യം പറയുക, ധർമ്മം അനുഷ്ഠിക്കുക.',
      quoteAuthorMl: 'തൈത്തിരീയോപനിഷത്ത് 1.11.1',
    ),
    RitualCard(
      id: 'sd_34',
      number: 34,
      theme: RitualTheme.sathya,
      title: 'Truth Beyond Words',
      prompt:
          'Truth is not only in what you say, but in what you do. Are your actions today aligned with the truth you hold in your heart?',
      quote: 'By truthfulness, man reaches the station of God.',
      quoteAuthor: 'Chanakya Niti 14.3',
      titleMl: 'വാക്കുകൾക്കപ്പുറമുള്ള സത്യം',
      promptMl:
          'സത്യം വാക്കുകളിൽ മാത്രമല്ല, പ്രവൃത്തിയിലുമാണ്. നിങ്ങളുടെ ഇന്നത്തെ പ്രവൃത്തികൾ ഹൃദയത്തിലെ സത്യവുമായി പൊരുത്തപ്പെടുന്നുണ്ടോ?',
      quoteMl: 'സത്യനിഷ്ഠയിലൂടെ മനുഷ്യൻ ദൈവികതയെ പ്രാപിക്കുന്നു.',
      quoteAuthorMl: 'ചാണക്യനീതി 14.3',
    ),
    RitualCard(
      id: 'sd_35',
      number: 35,
      theme: RitualTheme.sathya,
      title: 'The Promise You Keep',
      prompt:
          'What is a promise you have made — to yourself, to another, or to the Divine — that you must honour? Recommit to it now.',
      quote:
          'Let your word be your bond. A person who breaks a promise breaks trust, and trust once broken is hard to rebuild.',
      quoteAuthor: 'Vidura Niti, Mahabharata',
      titleMl: 'വാഗ്ദാനപാലനം',
      promptMl:
          'നിങ്ങളോടോ മറ്റുള്ളവരോടോ ഈശ്വരനോടോ ചെയ്ത പാലിക്കേണ്ട ഒരു വാഗ്ദാനം എന്താണ്? അത് വീണ്ടും ഓർമ്മിച്ച് ഉറപ്പിക്കുക.',
      quoteMl:
          'വാക്ക് പാലിക്കുക. വാക്ക് തെറ്റിക്കുന്നവൻ വിശ്വാസം തകർക്കുന്നു; തകർന്ന വിശ്വാസം തിരിച്ചുപിടിക്കാൻ പ്രയാസമാണ്.',
      quoteAuthorMl: 'വിദുരനീതി, മഹാഭാരതം',
    ),

    // ────────────────────── VAIRAGYA (36–39) ──────────────────────
    RitualCard(
      id: 'sd_36',
      number: 36,
      theme: RitualTheme.vairagya,
      title: 'Letting Go',
      prompt:
          'What possession, expectation, or desire are you clinging to that no longer serves your growth? Imagine gently releasing it.',
      quote:
          'Vairagya is the mastery of consciousness in which one is free from craving for sense objects, whether experienced directly or described.',
      quoteAuthor: 'Yoga Sutras of Patanjali 1.15',
      titleMl: 'ത്യജിക്കൽ',
      promptMl:
          'നിങ്ങളുടെ വളർച്ചയെ തടയുന്ന ഏത് ആഗ്രഹത്തെയും വസ്തുവിനെയുമാണ് നിങ്ങൾ മുറുകെ പിടിച്ചിരിക്കുന്നത്? അതിനെ ശാന്തമായി മനസ്സിൽ നിന്ന് വിട്ടൊഴിയുക.',
      quoteMl:
          'കണ്ടതോ കേട്ടതോ ആയ വിഷയങ്ങളിലുള്ള ആഗ്രഹങ്ങളിൽ നിന്നുള്ള പൂർണ്ണമായ വിടുതലാണ് വൈരാഗ്യം.',
      quoteAuthorMl: 'പതഞ്ജലി യോഗസൂത്രം 1.15',
    ),
    RitualCard(
      id: 'sd_37',
      number: 37,
      theme: RitualTheme.vairagya,
      title: 'The Unchanging Self',
      prompt:
          'Everything around you changes — moods, fortunes, relationships. What part of you has remained unchanged through all of life\'s storms?',
      quote:
          'That which is not real never was and never will be. That which is real always was and can never cease to be.',
      quoteAuthor: 'Bhagavad Gita 2.16',
      titleMl: 'മാറ്റമില്ലാത്ത ആത്മാവ്',
      promptMl:
          'വികാരങ്ങൾ, സാഹചര്യങ്ങൾ, ബന്ധങ്ങൾ — ചുറ്റുമുള്ളതെല്ലാം മാറുന്നു. ജീവിതത്തിലെ പ്രതിസന്ധികളിലും നിങ്ങളിൽ മാറ്റമില്ലാതെ തുടരുന്ന ഭാഗം ഏതാണ്?',
      quoteMl: 'അസത്യമായതിന് നിലനിൽപ്പില്ല. സത്യമായതിന് നാശവുമില്ല.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 2.16',
    ),
    RitualCard(
      id: 'sd_38',
      number: 38,
      theme: RitualTheme.vairagya,
      title: 'Contentment',
      prompt:
          'What do you already have that is truly enough? Reflect on the difference between want and need in your life right now.',
      quote: 'From contentment comes unsurpassed happiness.',
      quoteAuthor: 'Yoga Sutras of Patanjali 2.42',
      titleMl: 'സന്തോഷവും സംതൃപ്തിയും',
      promptMl:
          'ജീവിതത്തിൽ ഇപ്പോൾത്തന്നെ മതിയായതായി എന്തെല്ലാമുണ്ട്? ആഗ്രഹങ്ങളും യഥാർത്ഥ ആവശ്യങ്ങളും തമ്മിലുള്ള വ്യത്യാസത്തെക്കുറിച്ച് ചിന്തിക്കുക.',
      quoteMl:
          'സന്തോഷാദനൃത്തമഃ സുഖലാഭഃ — സംതൃപ്തിയിൽ നിന്നാണ് ഉത്തമമായ ആനന്ദമുണ്ടാകുന്നത്.',
      quoteAuthorMl: 'പതഞ്ജലി യോഗസൂത്രം 2.42',
    ),
    RitualCard(
      id: 'sd_39',
      number: 39,
      theme: RitualTheme.vairagya,
      title: 'Beyond Pleasure and Pain',
      prompt:
          'Can you sit with discomfort without fleeing, and with pleasure without grasping? What happens when you simply observe both?',
      quote:
          'One who is not disturbed by happiness and distress and is steady in both is certainly eligible for liberation.',
      quoteAuthor: 'Bhagavad Gita 2.15',
      titleMl: 'സുഖദുഃഖങ്ങൾക്കപ്പുറം',
      promptMl:
          'അസ്വസ്ഥതകളിൽ നിന്ന് ഒളിച്ചോടാതെയും സുഖങ്ങളിൽ ഭ്രമിക്കാതെയും ഇരിക്കാൻ കഴിയുമോ? രണ്ടിനെയും വെറുതെ നിരീക്ഷിക്കുമ്പോൾ എന്താണ് സംഭവിക്കുന്നത്?',
      quoteMl:
          'സുഖത്തിലും ദുഃഖത്തിലും ഇളകാതെ സമചിത്തത പാലിക്കുന്നവൻ മോക്ഷത്തിന് അർഹനായിത്തീരുന്നു.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 2.15',
    ),

    // ────────────────────── SEVA (40–44) ──────────────────────
    RitualCard(
      id: 'sd_40',
      number: 40,
      theme: RitualTheme.seva,
      title: 'The Joy of Giving',
      prompt:
          'What can you give today — time, attention, a kind word, a helping hand — without expecting anything in return?',
      quote: 'The highest form of charity is helping those who are helpless.',
      quoteAuthor: 'Thirukkural 221',
      titleMl: 'ദാനത്തിന്റെ ആനന്ദം',
      promptMl:
          'പ്രതിഫലം ഇച്ഛിക്കാതെ സമയം, ശ്രദ്ധ, നല്ലൊരു വാക്ക്, ഒരു സഹായഹസ്തം — ഇന്ന് നിങ്ങൾക്ക് എന്ത് നൽകാൻ കഴിയും?',
      quoteMl: 'നിസ്സഹായരായവരെ സഹായിക്കുന്നതാണ് ഏറ്റവും ശ്രേഷ്ഠമായ ദാനം.',
      quoteAuthorMl: 'തിരുക്കുറൾ 221',
    ),
    RitualCard(
      id: 'sd_41',
      number: 41,
      theme: RitualTheme.seva,
      title: 'Serving the Divine in Others',
      prompt:
          'If the person standing in front of you were God in disguise, how would you treat them? Try living this for the next hour.',
      quote: 'Service to humanity is service to God.',
      quoteAuthor: 'Swami Vivekananda',
      titleMl: 'മനുഷ്യനിലെ ഈശ്വരനെ സേവിക്കുക',
      promptMl:
          'നിങ്ങളുടെ മുന്നിൽ നിൽക്കുന്ന വ്യക്തി ഈശ്വരനാണെങ്കിൽ നിങ്ങളവരോട് എങ്ങനെ പെരുമാറും? അടുത്ത ഒരു മണിക്കൂർ ഈ ഭാവത്തോടെ ജീവിച്ചുനോക്കൂ.',
      quoteMl: 'മാനവ സേവയാണ് മാധവ സേവ.',
      quoteAuthorMl: 'സ്വാമി വിവേകാനന്ദൻ',
    ),
    RitualCard(
      id: 'sd_42',
      number: 42,
      theme: RitualTheme.seva,
      title: 'Selfless Work',
      prompt:
          'Recall a time when you helped someone and felt a quiet, deep joy that had nothing to do with recognition. What did that teach you?',
      quote: 'Arise, awake, and stop not till the goal is reached.',
      quoteAuthor: 'Katha Upanishad 1.3.14 / Swami Vivekananda',
      titleMl: 'നിസ്വാർത്ഥ പ്രവർത്തനം',
      promptMl:
          'അംഗീകാരങ്ങൾ ആഗ്രഹിക്കാതെ ആരെയെങ്കിലും സഹായിച്ചപ്പോൾ തോന്നിയ ആത്മനിർവൃതി ഓർക്കുക. അത് നിങ്ങളെ എന്ത് പഠിപ്പിച്ചു?',
      quoteMl:
          'ഉത്തിഷ്ഠത ജാഗ്രത പ്രാപ്യ വരാൻ നിബോധത — എഴുന്നേൽക്കുക, ഉണരുക, ലക്ഷ്യത്തിലെത്തും വരെ മുന്നേറുക.',
      quoteAuthorMl: 'കഠോപനിഷത്ത് 1.3.14 / സ്വാമി വിവേകാനന്ദൻ',
    ),
    RitualCard(
      id: 'sd_43',
      number: 43,
      theme: RitualTheme.seva,
      title: 'Vasudhaiva Kutumbakam',
      prompt:
          'The whole world is one family. What is one step you can take today to live as though every person\'s well-being matters to you?',
      quote: 'Vasudhaiva Kutumbakam — the entire world is one family.',
      quoteAuthor: 'Maha Upanishad 6.71',
      titleMl: 'വസുധൈവ കുടുംബകം',
      promptMl:
          'ലോകം മുഴുവൻ ഒരു കുടുംബമാണ്. എല്ലാവരുടെയും ക്ഷേമം പ്രധാനമാണെന്ന ചിന്തയോടെ ഇന്ന് നിങ്ങൾക്ക് ചെയ്യാൻ കഴിയുന്ന ഒരു കാര്യം എന്താണ്?',
      quoteMl: 'വസുധൈവ കുടുംബകം — ഈ ലോകം മുഴുവൻ ഒരു കുടുംബമാകുന്നു.',
      quoteAuthorMl: 'മഹോപനിഷത്ത് 6.71',
    ),
    RitualCard(
      id: 'sd_44',
      number: 44,
      theme: RitualTheme.seva,
      title: 'The Wealth of Kindness',
      prompt:
          'What small act of kindness did someone do for you that you still remember? How can you pass that same kindness forward today?',
      quote:
          'Even the poverty of the poor will depart if they give, with compassion, even what little they have.',
      quoteAuthor: 'Thirukkural 247',
      titleMl: 'കാരുണ്യത്തിന്റെ സമ്പത്ത്',
      promptMl:
          'നിങ്ങളോട് മറ്റൊരാൾ കാട്ടിയ എളിമയുള്ള കാരുണ്യം ഓർക്കുക. അതേ ദയ ഇന്ന് മറ്റൊരാളിലേക്ക് എങ്ങനെ പകരാം?',
      quoteMl:
          'ഉള്ളതിൽ നിന്ന് കാരുണ്യത്തോടെ ദാനം ചെയ്താൽ ദരിദ്രന്റെ ദാരിദ്ര്യം പോലും ഇല്ലാതാകും.',
      quoteAuthorMl: 'തിരുക്കുറൾ 247',
    ),

    // ────────────────────── SHANTI (45–50) ──────────────────────
    RitualCard(
      id: 'sd_45',
      number: 45,
      theme: RitualTheme.shanti,
      title: 'The Peace Within',
      prompt:
          'Close your eyes and take three slow breaths. Feel the silence between each breath. That silence is who you truly are. Can you carry it through the day?',
      quote:
          'For one who has conquered the mind, the mind is the best of friends; but for one who has failed to do so, the mind will remain the greatest enemy.',
      quoteAuthor: 'Bhagavad Gita 6.6',
      titleMl: 'ആന്തരിക ശാന്തി',
      promptMl:
          'കണ്ണുകളടച്ച് പതുക്കെ മൂന്ന് തവണ ശ്വാസമെടുക്കുക. ഓരോ ശ്വാസത്തിനും ഇടയിലുള്ള നിശബ്ദത അറിയുക. ആ നിശബ്ദതയാണ് നിങ്ങളുടെ സത്യം. അത് ദിവസം മുഴുവൻ കൊണ്ടുനടക്കാമോ?',
      quoteMl:
          'മനസ്സിനെ കീഴടക്കിയവന് മനസ്സ് ഉത്തമ മിത്രമാണ്; കീഴടക്കാൻ കഴിയാത്തവന് മനസ്സ് പരമശത്രുവായിത്തീരുന്നു.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 6.6',
    ),
    RitualCard(
      id: 'sd_46',
      number: 46,
      theme: RitualTheme.shanti,
      title: 'Equanimity in Praise and Blame',
      prompt:
          'Recall a recent praise and a recent criticism you received. Can you hold both with the same calm composure, without clinging to one or rejecting the other?',
      quote:
          'One who is the same to friend and foe, in honour and dishonour, in heat and cold, in pleasure and pain, and is free from attachment — such a person is dear to Me.',
      quoteAuthor: 'Bhagavad Gita 12.18–19',
      titleMl: 'സ്തുതിനിന്ദകളിൽ സമഭാവം',
      promptMl:
          'അടുത്തിടെ കേട്ട ഒരു പ്രശംസയും വിമർശനവും ഓർക്കുക. ഒന്നിൽ അഭിരമിക്കാതെയും മറ്റൊന്നിനെ വെറുക്കാതെയും രണ്ടിനെയും ശാന്തതയോടെ കാണാൻ കഴിയുമോ?',
      quoteMl:
          'ശത്രുവിനോടും മിത്രത്തോടും മാനാപമാനങ്ങളിലും ശീതോഷ്ണങ്ങളിലും സുഖദുഃഖങ്ങളിലും സമഭാവം പുലർത്തുന്നവൻ എനിക്ക് പ്രിയപ്പെട്ടവനാണ്.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 12.18–19',
    ),
    RitualCard(
      id: 'sd_47',
      number: 47,
      theme: RitualTheme.shanti,
      title: 'The Lotus in Mud',
      prompt:
          'A lotus blooms in muddy water yet remains unstained. What is the muddy situation in your life right now, and how can you remain untouched by it while still growing?',
      quote:
          'One who performs actions without attachment, surrendering them to Brahman, is untouched by sin, like a lotus leaf by water.',
      quoteAuthor: 'Bhagavad Gita 5.10',
      titleMl: 'ചെളിയിലെ താമര',
      promptMl:
          'ചെളിയിലാണ് വിരിയുന്നതെങ്കിലും താമരപ്പൂവിൽ ചെളി പറ്റുന്നില്ല. നിങ്ങളുടെ ജീവിതത്തിലെ പ്രയാസകരമായ സാഹചര്യം എന്താണ്? അതിൽ കളങ്കപ്പെടാതെ വളരാൻ എങ്ങനെ കഴിയും?',
      quoteMl:
          'ആസക്തികളില്ലാതെ കർമ്മങ്ങളെ ബ്രഹ്മത്തിൽ സമർപ്പിച്ച് പ്രവർത്തിക്കുന്നവനെ പാപങ്ങൾ സ്പർശിക്കുന്നില്ല; താമരയിലയിലെ വെള്ളത്തുള്ളിപോലെ.',
      quoteAuthorMl: 'ഭഗവദ്ഗീത 5.10',
    ),
    RitualCard(
      id: 'sd_48',
      number: 48,
      theme: RitualTheme.shanti,
      title: 'Om Shanti',
      prompt:
          'Sit still and repeat Om Shanti three times — peace in body, peace in mind, peace in spirit. What disturbance melts away as you do this?',
      quote: 'Om Shantih Shantih Shantih — Om, Peace, Peace, Peace.',
      quoteAuthor: 'Upanishadic Shanti Mantra',
      titleMl: 'ഓം ശാന്തി',
      promptMl:
          'നിശ്ചലമായിരുന്ന് മൂന്ന് തവണ "ഓം ശാന്തി" ജപിക്കുക — ശരീരത്തിലും മനസ്സിലും ആത്മാവിലും ശാന്തി. അങ്ങനെ ചെയ്യുമ്പോൾ ഉള്ളിൽ നിന്ന് അലിഞ്ഞുപോകുന്ന അസ്വസ്ഥതകൾ എന്തൊക്കെയാണ്?',
      quoteMl: 'ഓം ശാന്തിഃ ശാന്തിഃ ശാന്തിഃ — ശാന്തി, ശാന്തി, ശാന്തി.',
      quoteAuthorMl: 'ഉപനിഷത് ശാന്തിമന്ത്രം',
    ),
    RitualCard(
      id: 'sd_49',
      number: 49,
      theme: RitualTheme.shanti,
      title: 'May All Be Happy',
      prompt:
          'Silently wish well-being for yourself, then for your loved ones, then for strangers, then for all beings. Notice how your heart expands as the circle widens.',
      quote:
          'Sarve bhavantu sukhinah, sarve santu niramayah. Sarve bhadrani pashyantu, ma kashchit duhkhabhag bhavet. — May all be happy, may all be free from disease, may all see auspiciousness, may none suffer.',
      quoteAuthor: 'Upanishadic Prayer',
      titleMl: 'സർവ്വർക്കും ക്ഷേമം',
      promptMl:
          'നിങ്ങൾക്കും പ്രിയപ്പെട്ടവർക്കും അപരിചിതർക്കും സർവ്വ ജീവജാലങ്ങൾക്കും മനസ്സാൽ മംഗളങ്ങൾ നേരുക. കാരുണ്യത്തിന്റെ വൃത്തം വികസിക്കുമ്പോൾ ഹൃദയം നിറയുന്നത് അനുഭവിക്കുക.',
      quoteMl:
          'സർവേ ഭവന്തു സുഖിനഃ സർവേ സന്തു നിരാമയാഃ, സർവേ ഭദ്രാണി പശ്യന്തു മാ കശ്ചിദ്ദുഃഖഭാഗ് ഭവേത് — എല്ലാവരും സുഖമായിരിക്കട്ടെ, എല്ലാവരും രോഗവിമുക്തരാകട്ടെ, എല്ലാവരും മംഗളങ്ങൾ കാണട്ടെ, ആർക്കും ദുഃഖമുണ്ടാകാതിരിക്കട്ടെ.',
      quoteAuthorMl: 'ഉപനിഷത് പ്രാർത്ഥന',
    ),
    RitualCard(
      id: 'sd_50',
      number: 50,
      theme: RitualTheme.shanti,
      title: 'Strength and Peace Together',
      prompt:
          'True strength does not come from tension; it comes from deep inner peace. Where in your life can you replace force with calm resolve today?',
      quote:
          'Strength is life, weakness is death. Strength is the medicine, strength is the cure. Strength, strength is what the Upanishads preach.',
      quoteAuthor: 'Swami Vivekananda',
      titleMl: 'ശക്തിയും ശാന്തിയും',
      promptMl:
          'യഥാർത്ഥ കരുത്ത് കഠിനമായ സമ്മർദ്ദത്തിൽ നിന്നല്ല, ആഴത്തിലുള്ള ആന്തരിക ശാന്തിയിൽ നിന്നാണ് വരുന്നത്. ശാന്തമായ ദൃഢനിശ്ചയത്തോടെ ചെയ്യാൻ കഴിയുന്ന കാര്യം എന്താണ്?',
      quoteMl:
          'ശക്തിയാണ് ജീവിതം, ബലഹീനതയാണ് മരണം. ശക്തിയാണ് മരുന്ന്, ശക്തിയാണ് പരിഹാരം. ശക്തിയാണ് ഉപനിഷത്തുകൾ പഠിപ്പിക്കുന്നത്.',
      quoteAuthorMl: 'സ്വാമി വിവേകാനന്ദൻ',
    ),
  ];
}
