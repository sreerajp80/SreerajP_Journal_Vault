import 'dart:convert';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';

/// Identifiers for the V2 entry templates listed in the plan, plus the
/// expanded V3 set covering reflection, thoughts, projects, relationships,
/// health, learning, creativity, planning and specialty journaling.
enum EntryTemplateId {
  // V2 (must remain — referenced by tests and existing entries):
  blank,
  daily,
  travel,
  meeting,
  gratitude,
  mood,

  // Reflective:
  todayForMe,
  eveningWindDown,
  morningPages,
  dayHighlight,
  energyCheck,

  // Thoughts & ideas:
  thoughts,
  ideaCapture,
  openQuestion,
  opinion,
  lessonsLearned,

  // Projects & work:
  projects,
  projectUpdate,
  weeklyReview,
  goalTracker,
  decisionLog,
  stuckPoint,

  // People & relationships:
  conversationRecap,
  gratefulPeople,
  unsentLetter,
  relationshipCheckin,

  // Health & wellbeing:
  bodyCheckin,
  mentalHealth,
  habitTracker,
  sleepLog,

  // Learning & growth:
  taughtToday,
  bookNotes,
  skillPractice,
  mistakeLog,
  topicDeepDive,

  // Creative:
  dreamJournal,
  observation,
  quoteOfDay,
  storySeed,

  // Planning:
  tomorrowFocus,
  weeklyIntentions,
  monthlyReview,

  // Specialty & domain-specific:
  workoutLog,
  readingLog,
  foodJournal,
  spendingLog,
  prayerMeditation,
  sysadminRunbook,
  sanathanaDharmaStudy,
  diyProject,
  homeMaintenance,
  kitchenRecipe,
}

/// Coarse grouping used by the chooser dialog so the (now long) list is
/// scannable. Order here is the order shown in the chooser. The visible name
/// is localized in `presentation/entry_template_text.dart`.
enum EntryTemplateCategory {
  custom,
  general,
  reflective,
  thoughts,
  projects,
  people,
  health,
  learning,
  creative,
  planning,
  specialty,
}

/// A starter scaffold for a new entry.
///
/// Two kinds share this type:
///
/// * **Built-in templates** carry only an [id] and a [category]. Their label,
///   description, entry title and body are user-visible text in all three app
///   languages, so they live in `lib/l10n/*.arb` and are resolved per language
///   by `presentation/entry_template_text.dart`.
/// * **Custom templates** carry the text the user saved in the database.
class EntryTemplate {
  const EntryTemplate.builtIn({required this.id, required this.category})
    : customId = null,
      label = '',
      description = '',
      defaultTitle = '',
      contentJson = '[]';

  const EntryTemplate.custom({
    required this.customId,
    required this.label,
    required this.description,
    required this.defaultTitle,
    required this.contentJson,
  }) : id = EntryTemplateId.blank,
       category = EntryTemplateCategory.custom;

  final EntryTemplateId id;
  final int? customId;
  final EntryTemplateCategory category;

  /// The user's own text for a custom template. Empty for built-in templates.
  final String label;
  final String description;
  final String defaultTitle;
  final String contentJson;

  bool get isCustom => customId != null;

  factory EntryTemplate.fromUserTemplate(UserTemplate ut) {
    return EntryTemplate.custom(
      customId: ut.id,
      label: ut.name,
      description: ut.description ?? '',
      defaultTitle: ut.defaultTitle ?? '',
      contentJson: ut.contentJson,
    );
  }
}

/// Built-in template registry. Order is the order shown in the chooser
/// (within each category).
const List<EntryTemplate> _templates = <EntryTemplate>[
  // General
  EntryTemplate.builtIn(
    id: EntryTemplateId.blank,
    category: EntryTemplateCategory.general,
  ),

  // Reflective
  EntryTemplate.builtIn(
    id: EntryTemplateId.daily,
    category: EntryTemplateCategory.reflective,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.todayForMe,
    category: EntryTemplateCategory.reflective,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.eveningWindDown,
    category: EntryTemplateCategory.reflective,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.morningPages,
    category: EntryTemplateCategory.reflective,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.dayHighlight,
    category: EntryTemplateCategory.reflective,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.energyCheck,
    category: EntryTemplateCategory.reflective,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.mood,
    category: EntryTemplateCategory.reflective,
  ),

  // Thoughts & ideas
  EntryTemplate.builtIn(
    id: EntryTemplateId.thoughts,
    category: EntryTemplateCategory.thoughts,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.ideaCapture,
    category: EntryTemplateCategory.thoughts,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.openQuestion,
    category: EntryTemplateCategory.thoughts,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.opinion,
    category: EntryTemplateCategory.thoughts,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.lessonsLearned,
    category: EntryTemplateCategory.thoughts,
  ),

  // Projects & work
  EntryTemplate.builtIn(
    id: EntryTemplateId.projects,
    category: EntryTemplateCategory.projects,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.projectUpdate,
    category: EntryTemplateCategory.projects,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.weeklyReview,
    category: EntryTemplateCategory.projects,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.goalTracker,
    category: EntryTemplateCategory.projects,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.decisionLog,
    category: EntryTemplateCategory.projects,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.stuckPoint,
    category: EntryTemplateCategory.projects,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.meeting,
    category: EntryTemplateCategory.projects,
  ),

  // People & relationships
  EntryTemplate.builtIn(
    id: EntryTemplateId.conversationRecap,
    category: EntryTemplateCategory.people,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.gratefulPeople,
    category: EntryTemplateCategory.people,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.unsentLetter,
    category: EntryTemplateCategory.people,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.relationshipCheckin,
    category: EntryTemplateCategory.people,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.gratitude,
    category: EntryTemplateCategory.people,
  ),

  // Health & wellbeing
  EntryTemplate.builtIn(
    id: EntryTemplateId.bodyCheckin,
    category: EntryTemplateCategory.health,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.mentalHealth,
    category: EntryTemplateCategory.health,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.habitTracker,
    category: EntryTemplateCategory.health,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.sleepLog,
    category: EntryTemplateCategory.health,
  ),

  // Learning & growth
  EntryTemplate.builtIn(
    id: EntryTemplateId.taughtToday,
    category: EntryTemplateCategory.learning,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.bookNotes,
    category: EntryTemplateCategory.learning,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.skillPractice,
    category: EntryTemplateCategory.learning,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.mistakeLog,
    category: EntryTemplateCategory.learning,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.topicDeepDive,
    category: EntryTemplateCategory.learning,
  ),

  // Creative
  EntryTemplate.builtIn(
    id: EntryTemplateId.dreamJournal,
    category: EntryTemplateCategory.creative,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.observation,
    category: EntryTemplateCategory.creative,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.quoteOfDay,
    category: EntryTemplateCategory.creative,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.storySeed,
    category: EntryTemplateCategory.creative,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.travel,
    category: EntryTemplateCategory.creative,
  ),

  // Planning
  EntryTemplate.builtIn(
    id: EntryTemplateId.tomorrowFocus,
    category: EntryTemplateCategory.planning,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.weeklyIntentions,
    category: EntryTemplateCategory.planning,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.monthlyReview,
    category: EntryTemplateCategory.planning,
  ),

  // Specialty & domain-specific
  EntryTemplate.builtIn(
    id: EntryTemplateId.workoutLog,
    category: EntryTemplateCategory.specialty,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.readingLog,
    category: EntryTemplateCategory.specialty,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.foodJournal,
    category: EntryTemplateCategory.specialty,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.spendingLog,
    category: EntryTemplateCategory.specialty,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.prayerMeditation,
    category: EntryTemplateCategory.specialty,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.sysadminRunbook,
    category: EntryTemplateCategory.specialty,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.sanathanaDharmaStudy,
    category: EntryTemplateCategory.specialty,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.diyProject,
    category: EntryTemplateCategory.specialty,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.homeMaintenance,
    category: EntryTemplateCategory.specialty,
  ),
  EntryTemplate.builtIn(
    id: EntryTemplateId.kitchenRecipe,
    category: EntryTemplateCategory.specialty,
  ),
];

/// Returns all built-in templates in display order.
List<EntryTemplate> get entryTemplates => List.unmodifiable(_templates);

/// Returns templates grouped by [EntryTemplateCategory], preserving the
/// declaration order of templates within each group. Categories with no
/// templates are omitted.
Map<EntryTemplateCategory, List<EntryTemplate>> get entryTemplatesByCategory {
  final map = <EntryTemplateCategory, List<EntryTemplate>>{};
  for (final t in _templates) {
    map.putIfAbsent(t.category, () => <EntryTemplate>[]).add(t);
  }
  return Map.unmodifiable(map);
}

/// Looks a template up by [id]. Returns the blank template if [id] is null.
EntryTemplate templateFor(EntryTemplateId? id) {
  if (id == null) return _templates.first;
  return _templates.firstWhere(
    (t) => t.id == id,
    orElse: () => _templates.first,
  );
}

/// Lightweight sanity check that [contentJson] is a parseable Quill delta.
bool validateTemplateJson(String contentJson) {
  try {
    final decoded = jsonDecode(contentJson);
    return decoded is List;
  } catch (_) {
    return false;
  }
}
