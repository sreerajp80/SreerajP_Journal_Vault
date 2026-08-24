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
/// scannable. Order here is the order shown in the chooser.
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

extension EntryTemplateCategoryX on EntryTemplateCategory {
  String get label {
    switch (this) {
      case EntryTemplateCategory.custom:
        return 'My templates';
      case EntryTemplateCategory.general:
        return 'Start fresh';
      case EntryTemplateCategory.reflective:
        return 'Daily & reflective';
      case EntryTemplateCategory.thoughts:
        return 'Thoughts & ideas';
      case EntryTemplateCategory.projects:
        return 'Projects & work';
      case EntryTemplateCategory.people:
        return 'People & relationships';
      case EntryTemplateCategory.health:
        return 'Health & wellbeing';
      case EntryTemplateCategory.learning:
        return 'Learning & growth';
      case EntryTemplateCategory.creative:
        return 'Creative';
      case EntryTemplateCategory.planning:
        return 'Planning';
      case EntryTemplateCategory.specialty:
        return 'Specialty';
    }
  }
}

/// A starter scaffold for a new entry. Only [contentJson] is required by the
/// editor; [defaultTitle] becomes the title field's initial value.
class EntryTemplate {
  const EntryTemplate({
    required this.id,
    required this.category,
    required this.label,
    required this.description,
    required this.defaultTitle,
    required this.contentJson,
    this.customId,
  });

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
  // ---------------- General ----------------
  EntryTemplate(
    id: EntryTemplateId.blank,
    category: EntryTemplateCategory.general,
    label: 'Blank',
    description: 'Start with an empty entry.',
    defaultTitle: '',
    contentJson: '[]',
  ),

  // ---------------- Reflective ----------------
  EntryTemplate(
    id: EntryTemplateId.daily,
    category: EntryTemplateCategory.reflective,
    label: 'Daily Reflection',
    description: 'Highlights, gratitudes, and tomorrow\'s focus.',
    defaultTitle: 'Daily Reflection',
    contentJson:
        '[{"insert":"Highlights\\n\\n"},'
        '{"insert":"Lowlights\\n\\n"},'
        '{"insert":"Tomorrow\'s focus\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.todayForMe,
    category: EntryTemplateCategory.reflective,
    label: 'Today for Me',
    description: 'Did, thought, saw, encountered, felt, and learned today.',
    defaultTitle: 'Today for Me',
    contentJson:
        '[{"insert":"What I did today\\n\\n"},'
        '{"insert":"What I thought today\\n\\n"},'
        '{"insert":"What I saw today\\n\\n"},'
        '{"insert":"What I encountered today\\n\\n"},'
        '{"insert":"What I felt today\\n\\n"},'
        '{"insert":"What was taught to me today\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.eveningWindDown,
    category: EntryTemplateCategory.reflective,
    label: 'Evening Wind-down',
    description: 'Wins, struggles, one thing to let go of.',
    defaultTitle: 'Evening Wind-down',
    contentJson:
        '[{"insert":"Wins\\n\\n"},'
        '{"insert":"Struggles\\n\\n"},'
        '{"insert":"One thing to let go of\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.morningPages,
    category: EntryTemplateCategory.reflective,
    label: 'Morning Pages',
    description: 'Stream-of-consciousness brain dump to start the day.',
    defaultTitle: 'Morning Pages',
    contentJson: '[]',
  ),
  EntryTemplate(
    id: EntryTemplateId.dayHighlight,
    category: EntryTemplateCategory.reflective,
    label: 'Highlight of the Day',
    description: 'Single most memorable moment and why.',
    defaultTitle: 'Highlight of the Day',
    contentJson:
        '[{"insert":"The moment\\n\\n"},'
        '{"insert":"Why it stood out\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.energyCheck,
    category: EntryTemplateCategory.reflective,
    label: 'Energy Check',
    description: 'Energy level, what drained it, what restored it.',
    defaultTitle: 'Energy Check',
    contentJson:
        '[{"insert":"Energy level (1-10): \\n\\n"},'
        '{"insert":"What drained it\\n\\n"},'
        '{"insert":"What restored it\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.mood,
    category: EntryTemplateCategory.reflective,
    label: 'Mood Check-in',
    description: 'Note your current mood and what is shaping it.',
    defaultTitle: 'Mood Check-in',
    contentJson:
        '[{"insert":"How I feel right now\\n\\n"},'
        '{"insert":"What is shaping it\\n\\n"}]',
  ),

  // ---------------- Thoughts & ideas ----------------
  EntryTemplate(
    id: EntryTemplateId.thoughts,
    category: EntryTemplateCategory.thoughts,
    label: 'My Thoughts',
    description: 'Free-form reflection on a topic.',
    defaultTitle: 'My Thoughts',
    contentJson:
        '[{"insert":"Topic\\n\\n"},'
        '{"insert":"My thoughts\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.ideaCapture,
    category: EntryTemplateCategory.thoughts,
    label: 'Idea Capture',
    description: 'Idea, why it matters, next step.',
    defaultTitle: 'Idea Capture',
    contentJson:
        '[{"insert":"The idea\\n\\n"},'
        '{"insert":"Why it matters\\n\\n"},'
        '{"insert":"Next step\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.openQuestion,
    category: EntryTemplateCategory.thoughts,
    label: 'Open Question',
    description: 'A question I am sitting with and current thinking.',
    defaultTitle: 'Open Question',
    contentJson:
        '[{"insert":"The question\\n\\n"},'
        '{"insert":"What I think so far\\n\\n"},'
        '{"insert":"What I still don\'t know\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.opinion,
    category: EntryTemplateCategory.thoughts,
    label: 'Opinion / Hot Take',
    description: 'Belief, evidence for, evidence against.',
    defaultTitle: 'Opinion / Hot Take',
    contentJson:
        '[{"insert":"My belief\\n\\n"},'
        '{"insert":"Evidence for\\n\\n"},'
        '{"insert":"Evidence against\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.lessonsLearned,
    category: EntryTemplateCategory.thoughts,
    label: 'Lessons Learned',
    description: 'What happened, what I learned, how I\'ll apply it.',
    defaultTitle: 'Lessons Learned',
    contentJson:
        '[{"insert":"What happened\\n\\n"},'
        '{"insert":"What I learned\\n\\n"},'
        '{"insert":"How I\'ll apply it\\n\\n"}]',
  ),

  // ---------------- Projects & work ----------------
  EntryTemplate(
    id: EntryTemplateId.projects,
    category: EntryTemplateCategory.projects,
    label: 'My Projects',
    description: 'Project, status, blockers, next action.',
    defaultTitle: 'My Projects',
    contentJson:
        '[{"insert":"Project\\n\\n"},'
        '{"insert":"Status\\n\\n"},'
        '{"insert":"Blockers\\n\\n"},'
        '{"insert":"Next action\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.projectUpdate,
    category: EntryTemplateCategory.projects,
    label: 'Project Update',
    description: 'Progress, risks, decisions made.',
    defaultTitle: 'Project Update',
    contentJson:
        '[{"insert":"Progress\\n\\n"},'
        '{"insert":"Risks\\n\\n"},'
        '{"insert":"Decisions made\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.weeklyReview,
    category: EntryTemplateCategory.projects,
    label: 'Weekly Review',
    description: 'Wins, misses, focus for next week.',
    defaultTitle: 'Weekly Review',
    contentJson:
        '[{"insert":"Wins\\n\\n"},'
        '{"insert":"Misses\\n\\n"},'
        '{"insert":"Focus for next week\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.goalTracker,
    category: EntryTemplateCategory.projects,
    label: 'Goal Tracker',
    description: 'Goal, progress, obstacles, adjustments.',
    defaultTitle: 'Goal Tracker',
    contentJson:
        '[{"insert":"Goal\\n\\n"},'
        '{"insert":"Progress\\n\\n"},'
        '{"insert":"Obstacles\\n\\n"},'
        '{"insert":"Adjustments\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.decisionLog,
    category: EntryTemplateCategory.projects,
    label: 'Decision Log',
    description: 'Decision, options considered, why I chose this.',
    defaultTitle: 'Decision Log',
    contentJson:
        '[{"insert":"The decision\\n\\n"},'
        '{"insert":"Options considered\\n\\n"},'
        '{"insert":"Why I chose this\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.stuckPoint,
    category: EntryTemplateCategory.projects,
    label: 'Stuck Point',
    description: 'Where I\'m stuck, what I\'ve tried, what to try next.',
    defaultTitle: 'Stuck Point',
    contentJson:
        '[{"insert":"Where I\'m stuck\\n\\n"},'
        '{"insert":"What I\'ve tried\\n\\n"},'
        '{"insert":"What to try next\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.meeting,
    category: EntryTemplateCategory.projects,
    label: 'Meeting Notes',
    description: 'Attendees, agenda, decisions, action items.',
    defaultTitle: 'Meeting Notes',
    contentJson:
        '[{"insert":"Attendees: \\n"},'
        '{"insert":"Agenda\\n\\n"},'
        '{"insert":"Decisions\\n\\n"},'
        '{"insert":"Action items\\n\\n"}]',
  ),

  // ---------------- People & relationships ----------------
  EntryTemplate(
    id: EntryTemplateId.conversationRecap,
    category: EntryTemplateCategory.people,
    label: 'Conversation Recap',
    description: 'Who, what we discussed, follow-ups.',
    defaultTitle: 'Conversation Recap',
    contentJson:
        '[{"insert":"Who\\n\\n"},'
        '{"insert":"What we discussed\\n\\n"},'
        '{"insert":"Follow-ups\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.gratefulPeople,
    category: EntryTemplateCategory.people,
    label: 'People I\'m Grateful For',
    description: 'Person and a specific reason.',
    defaultTitle: 'People I\'m Grateful For',
    contentJson:
        '[{"insert":"Person\\n\\n"},'
        '{"insert":"Specific reason\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.unsentLetter,
    category: EntryTemplateCategory.people,
    label: 'Letter I Won\'t Send',
    description: 'Unsent letter to process feelings.',
    defaultTitle: 'Unsent Letter',
    contentJson:
        '[{"insert":"Dear ...,\\n\\n"},'
        '{"insert":"\\n\\n"},'
        '{"insert":"— Me\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.relationshipCheckin,
    category: EntryTemplateCategory.people,
    label: 'Relationship Check-in',
    description: 'How a key relationship is going.',
    defaultTitle: 'Relationship Check-in',
    contentJson:
        '[{"insert":"Person\\n\\n"},'
        '{"insert":"How it\'s going\\n\\n"},'
        '{"insert":"What needs attention\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.gratitude,
    category: EntryTemplateCategory.people,
    label: 'Gratitude',
    description: 'Three things I am grateful for today.',
    defaultTitle: 'Gratitude',
    contentJson:
        '[{"insert":"Three things I\'m grateful for\\n\\n"},'
        '{"insert":"1. \\n"},{"insert":"2. \\n"},{"insert":"3. \\n"}]',
  ),

  // ---------------- Health & wellbeing ----------------
  EntryTemplate(
    id: EntryTemplateId.bodyCheckin,
    category: EntryTemplateCategory.health,
    label: 'Body Check-in',
    description: 'Sleep, food, movement, pain or tension.',
    defaultTitle: 'Body Check-in',
    contentJson:
        '[{"insert":"Sleep\\n\\n"},'
        '{"insert":"Food\\n\\n"},'
        '{"insert":"Movement\\n\\n"},'
        '{"insert":"Pain or tension\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.mentalHealth,
    category: EntryTemplateCategory.health,
    label: 'Mental Health Log',
    description: 'Mood, triggers, coping used.',
    defaultTitle: 'Mental Health Log',
    contentJson:
        '[{"insert":"Mood\\n\\n"},'
        '{"insert":"Triggers\\n\\n"},'
        '{"insert":"Coping used\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.habitTracker,
    category: EntryTemplateCategory.health,
    label: 'Habit Tracker',
    description: 'Habits done today and streak notes.',
    defaultTitle: 'Habit Tracker',
    contentJson:
        '[{"insert":"Habits done today\\n\\n"},'
        '{"insert":"Missed today\\n\\n"},'
        '{"insert":"Streak notes\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.sleepLog,
    category: EntryTemplateCategory.health,
    label: 'Sleep Log',
    description: 'Hours, quality, dreams.',
    defaultTitle: 'Sleep Log',
    contentJson:
        '[{"insert":"Hours\\n\\n"},'
        '{"insert":"Quality\\n\\n"},'
        '{"insert":"Dreams\\n\\n"}]',
  ),

  // ---------------- Learning & growth ----------------
  EntryTemplate(
    id: EntryTemplateId.taughtToday,
    category: EntryTemplateCategory.learning,
    label: 'Taught to Me Today',
    description: 'Lesson, source, takeaway.',
    defaultTitle: 'Taught to Me Today',
    contentJson:
        '[{"insert":"Lesson\\n\\n"},'
        '{"insert":"Source\\n\\n"},'
        '{"insert":"Takeaway\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.bookNotes,
    category: EntryTemplateCategory.learning,
    label: 'Book / Article Notes',
    description: 'Title, key ideas, my reaction.',
    defaultTitle: 'Book / Article Notes',
    contentJson:
        '[{"insert":"Title: \\n"},'
        '{"insert":"Author: \\n\\n"},'
        '{"insert":"Key ideas\\n\\n"},'
        '{"insert":"My reaction\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.skillPractice,
    category: EntryTemplateCategory.learning,
    label: 'Skill Practice',
    description: 'What I practiced, what improved, next focus.',
    defaultTitle: 'Skill Practice',
    contentJson:
        '[{"insert":"Skill\\n\\n"},'
        '{"insert":"What I practiced\\n\\n"},'
        '{"insert":"What improved\\n\\n"},'
        '{"insert":"Next focus\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.mistakeLog,
    category: EntryTemplateCategory.learning,
    label: 'Mistake Log',
    description: 'What went wrong, root cause, prevention.',
    defaultTitle: 'Mistake Log',
    contentJson:
        '[{"insert":"What went wrong\\n\\n"},'
        '{"insert":"Root cause\\n\\n"},'
        '{"insert":"Prevention\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.topicDeepDive,
    category: EntryTemplateCategory.learning,
    label: 'Topic Deep Dive',
    description: 'Detailed study note on a concept, subject, or domain.',
    defaultTitle: 'Topic Deep Dive',
    contentJson:
        '[{"insert":"Topic / Core Concept\\n\\n"},'
        '{"insert":"Key Principles & Overview\\n\\n"},'
        '{"insert":"Detailed Analysis & Notes\\n\\n"},'
        '{"insert":"Key Takeaways & References\\n\\n"},'
        '{"insert":"Open Questions / Further Exploration\\n\\n"}]',
  ),

  // ---------------- Creative ----------------
  EntryTemplate(
    id: EntryTemplateId.dreamJournal,
    category: EntryTemplateCategory.creative,
    label: 'Dream Journal',
    description: 'Dream details, emotions, possible meaning.',
    defaultTitle: 'Dream Journal',
    contentJson:
        '[{"insert":"Dream details\\n\\n"},'
        '{"insert":"Emotions\\n\\n"},'
        '{"insert":"Possible meaning\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.observation,
    category: EntryTemplateCategory.creative,
    label: 'Observation Sketch',
    description: 'Something I noticed in detail.',
    defaultTitle: 'Observation Sketch',
    contentJson:
        '[{"insert":"What I noticed\\n\\n"},'
        '{"insert":"Details\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.quoteOfDay,
    category: EntryTemplateCategory.creative,
    label: 'Quote of the Day',
    description: 'Quote and why it resonates.',
    defaultTitle: 'Quote of the Day',
    contentJson:
        '[{"insert":"Quote\\n\\n"},'
        '{"insert":"Source\\n\\n"},'
        '{"insert":"Why it resonates\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.storySeed,
    category: EntryTemplateCategory.creative,
    label: 'Story Seed',
    description: 'A tiny story idea or scene.',
    defaultTitle: 'Story Seed',
    contentJson:
        '[{"insert":"The seed\\n\\n"},'
        '{"insert":"Possible direction\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.travel,
    category: EntryTemplateCategory.creative,
    label: 'Travel Log',
    description: 'Place, weather, what happened, who you met.',
    defaultTitle: 'Travel Log',
    contentJson:
        '[{"insert":"Place: \\n"},'
        '{"insert":"Weather: \\n"},'
        '{"insert":"What happened\\n\\n"},'
        '{"insert":"People I met\\n\\n"}]',
  ),

  // ---------------- Planning ----------------
  EntryTemplate(
    id: EntryTemplateId.tomorrowFocus,
    category: EntryTemplateCategory.planning,
    label: 'Tomorrow\'s Focus',
    description: 'Top 3 priorities and the first step.',
    defaultTitle: 'Tomorrow\'s Focus',
    contentJson:
        '[{"insert":"Top 3 priorities\\n\\n"},'
        '{"insert":"1. \\n"},{"insert":"2. \\n"},{"insert":"3. \\n\\n"},'
        '{"insert":"First step\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.weeklyIntentions,
    category: EntryTemplateCategory.planning,
    label: 'Weekly Intentions',
    description: 'Theme, priorities, what to avoid.',
    defaultTitle: 'Weekly Intentions',
    contentJson:
        '[{"insert":"Theme\\n\\n"},'
        '{"insert":"Priorities\\n\\n"},'
        '{"insert":"What to avoid\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.monthlyReview,
    category: EntryTemplateCategory.planning,
    label: 'Monthly Review',
    description: 'Wins, lessons, what changes next month.',
    defaultTitle: 'Monthly Review',
    contentJson:
        '[{"insert":"Wins\\n\\n"},'
        '{"insert":"Lessons\\n\\n"},'
        '{"insert":"What changes next month\\n\\n"}]',
  ),

  // ---------------- Specialty ----------------
  EntryTemplate(
    id: EntryTemplateId.workoutLog,
    category: EntryTemplateCategory.specialty,
    label: 'Workout Log',
    description: 'Exercises, sets, reps, how it felt.',
    defaultTitle: 'Workout Log',
    contentJson:
        '[{"insert":"Workout\\n\\n"},'
        '{"insert":"Sets / reps\\n\\n"},'
        '{"insert":"How it felt\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.readingLog,
    category: EntryTemplateCategory.specialty,
    label: 'Reading Log',
    description: 'Book, pages read, favorite passage.',
    defaultTitle: 'Reading Log',
    contentJson:
        '[{"insert":"Book\\n\\n"},'
        '{"insert":"Pages read\\n\\n"},'
        '{"insert":"Favorite passage\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.foodJournal,
    category: EntryTemplateCategory.specialty,
    label: 'Food Journal',
    description: 'Meals and how I felt after.',
    defaultTitle: 'Food Journal',
    contentJson:
        '[{"insert":"Meals\\n\\n"},'
        '{"insert":"How I felt after\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.spendingLog,
    category: EntryTemplateCategory.specialty,
    label: 'Spending Log',
    description: 'Purchases — was it worth it?',
    defaultTitle: 'Spending Log',
    contentJson:
        '[{"insert":"Purchase\\n\\n"},'
        '{"insert":"Cost\\n\\n"},'
        '{"insert":"Was it worth it?\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.prayerMeditation,
    category: EntryTemplateCategory.specialty,
    label: 'Prayer / Meditation',
    description: 'Practice, duration, reflections.',
    defaultTitle: 'Prayer / Meditation',
    contentJson:
        '[{"insert":"Practice\\n\\n"},'
        '{"insert":"Duration\\n\\n"},'
        '{"insert":"Reflections\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.sysadminRunbook,
    category: EntryTemplateCategory.specialty,
    label: 'System Administration',
    description: 'Server / system runbook, commands, and maintenance log.',
    defaultTitle: 'Sysadmin / Tech Note',
    contentJson:
        '[{"insert":"System / Service: \\n"},'
        '{"insert":"Objective & Architecture\\n\\n"},'
        '{"insert":"Configuration & Commands\\n\\n"},'
        '{"insert":"Verification & Health Checks\\n\\n"},'
        '{"insert":"Troubleshooting & Rollback Notes\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.sanathanaDharmaStudy,
    category: EntryTemplateCategory.specialty,
    label: 'Sanathana Dharma Study',
    description: 'Scripture, shloka, tatva/meaning, and sadhana reflection.',
    defaultTitle: 'Sanathana Dharma Study',
    contentJson:
        '[{"insert":"Topic / Scripture: \\n"},'
        '{"insert":"Shloka / Mantra / Reference\\n\\n"},'
        '{"insert":"Word Breakdown & Meaning\\n\\n"},'
        '{"insert":"Philosophical Insights (Tatva)\\n\\n"},'
        '{"insert":"Daily Sadhana & Practical Application\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.diyProject,
    category: EntryTemplateCategory.specialty,
    label: 'DIY & Maker Project',
    description: 'Materials, tools, step-by-step build, and safety.',
    defaultTitle: 'DIY Project',
    contentJson:
        '[{"insert":"Project Goal & Scope\\n\\n"},'
        '{"insert":"Tools & Materials Required\\n\\n"},'
        '{"insert":"Step-by-Step Procedure\\n\\n"},'
        '{"insert":"Safety & Precautions\\n\\n"},'
        '{"insert":"Testing & Lessons Learned\\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.homeMaintenance,
    category: EntryTemplateCategory.specialty,
    label: 'Home & Maintenance',
    description: 'Appliance care, repairs, warranties, and vendor logs.',
    defaultTitle: 'Home Maintenance Note',
    contentJson:
        '[{"insert":"Area / Item / Appliance: \\n"},'
        '{"insert":"Issue / Maintenance Task\\n\\n"},'
        '{"insert":"Service History & Costs\\n\\n"},'
        '{"insert":"Warranty & Vendor Contacts\\n\\n"},'
        '{"insert":"Next Scheduled Check: \\n\\n"}]',
  ),
  EntryTemplate(
    id: EntryTemplateId.kitchenRecipe,
    category: EntryTemplateCategory.specialty,
    label: 'Kitchen & Recipe',
    description: 'Dish, ingredients, step-by-step method, and tips.',
    defaultTitle: 'Recipe & Kitchen Note',
    contentJson:
        '[{"insert":"Dish Name: \\n"},'
        '{"insert":"Cuisine / Prep & Cook Time: \\n\\n"},'
        '{"insert":"Ingredients & Quantities\\n\\n"},'
        '{"insert":"Step-by-Step Method\\n\\n"},'
        '{"insert":"Chef Notes & Variations\\n\\n"}]',
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

/// Lightweight sanity check that every template has a parseable Quill delta.
bool validateTemplateJson(EntryTemplate t) {
  try {
    final decoded = jsonDecode(t.contentJson);
    return decoded is List;
  } catch (_) {
    return false;
  }
}
