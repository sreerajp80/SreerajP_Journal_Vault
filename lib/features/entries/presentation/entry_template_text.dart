import 'dart:convert';

import 'package:sreerajp_journal_vault/features/entries/templates/entry_templates.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

// Layer: presentation.
//
// Resolves the user-visible text of the entry template catalogue in the active
// language. Built-in template text lives in lib/l10n/*.arb (keys
// labelTemplate…, descTemplate…, bodyTemplate…); custom templates keep the text
// the user saved.

typedef _TemplateText = ({
  String label,
  String description,
  String title,
  String body,
});

extension EntryTemplateCategoryText on EntryTemplateCategory {
  String labelIn(AppLocalizations l10n) => switch (this) {
    EntryTemplateCategory.custom => l10n.labelTemplateCategoryCustom,
    EntryTemplateCategory.general => l10n.labelTemplateCategoryGeneral,
    EntryTemplateCategory.reflective => l10n.labelTemplateCategoryReflective,
    EntryTemplateCategory.thoughts => l10n.labelTemplateCategoryThoughts,
    EntryTemplateCategory.projects => l10n.labelTemplateCategoryProjects,
    EntryTemplateCategory.people => l10n.labelTemplateCategoryPeople,
    EntryTemplateCategory.health => l10n.labelTemplateCategoryHealth,
    EntryTemplateCategory.learning => l10n.labelTemplateCategoryLearning,
    EntryTemplateCategory.creative => l10n.labelTemplateCategoryCreative,
    EntryTemplateCategory.planning => l10n.labelTemplateCategoryPlanning,
    EntryTemplateCategory.specialty => l10n.labelTemplateCategorySpecialty,
  };
}

extension EntryTemplateText on EntryTemplate {
  String labelIn(AppLocalizations l10n) => isCustom ? label : _text(l10n).label;

  String descriptionIn(AppLocalizations l10n) =>
      isCustom ? description : _text(l10n).description;

  /// The title the new entry starts with.
  String defaultTitleIn(AppLocalizations l10n) =>
      isCustom ? defaultTitle : _text(l10n).title;

  /// The Quill delta the new entry starts with. A built-in body is plain text,
  /// so it becomes a single insert; no body means an empty document.
  String contentJsonIn(AppLocalizations l10n) {
    if (isCustom) return contentJson;
    final body = _text(l10n).body;
    if (body.isEmpty) return '[]';
    return jsonEncode([
      {'insert': body},
    ]);
  }

  _TemplateText _text(AppLocalizations l) {
    return switch (id) {
      EntryTemplateId.blank => (
        label: l.labelTemplateBlank,
        description: l.descTemplateBlank,
        title: '',
        body: '',
      ),
      EntryTemplateId.daily => (
        label: l.labelTemplateDaily,
        description: l.descTemplateDaily,
        title: l.descTemplateDailyEntryTitle,
        body: l.bodyTemplateDaily,
      ),
      EntryTemplateId.todayForMe => (
        label: l.labelTemplateTodayForMe,
        description: l.descTemplateTodayForMe,
        title: l.descTemplateTodayForMeEntryTitle,
        body: l.bodyTemplateTodayForMe,
      ),
      EntryTemplateId.eveningWindDown => (
        label: l.labelTemplateEveningWindDown,
        description: l.descTemplateEveningWindDown,
        title: l.descTemplateEveningWindDownEntryTitle,
        body: l.bodyTemplateEveningWindDown,
      ),
      EntryTemplateId.morningPages => (
        label: l.labelTemplateMorningPages,
        description: l.descTemplateMorningPages,
        title: l.descTemplateMorningPagesEntryTitle,
        body: '',
      ),
      EntryTemplateId.dayHighlight => (
        label: l.labelTemplateDayHighlight,
        description: l.descTemplateDayHighlight,
        title: l.descTemplateDayHighlightEntryTitle,
        body: l.bodyTemplateDayHighlight,
      ),
      EntryTemplateId.energyCheck => (
        label: l.labelTemplateEnergyCheck,
        description: l.descTemplateEnergyCheck,
        title: l.descTemplateEnergyCheckEntryTitle,
        body: l.bodyTemplateEnergyCheck,
      ),
      EntryTemplateId.mood => (
        label: l.labelTemplateMood,
        description: l.descTemplateMood,
        title: l.descTemplateMoodEntryTitle,
        body: l.bodyTemplateMood,
      ),
      EntryTemplateId.thoughts => (
        label: l.labelTemplateThoughts,
        description: l.descTemplateThoughts,
        title: l.descTemplateThoughtsEntryTitle,
        body: l.bodyTemplateThoughts,
      ),
      EntryTemplateId.ideaCapture => (
        label: l.labelTemplateIdeaCapture,
        description: l.descTemplateIdeaCapture,
        title: l.descTemplateIdeaCaptureEntryTitle,
        body: l.bodyTemplateIdeaCapture,
      ),
      EntryTemplateId.openQuestion => (
        label: l.labelTemplateOpenQuestion,
        description: l.descTemplateOpenQuestion,
        title: l.descTemplateOpenQuestionEntryTitle,
        body: l.bodyTemplateOpenQuestion,
      ),
      EntryTemplateId.opinion => (
        label: l.labelTemplateOpinion,
        description: l.descTemplateOpinion,
        title: l.descTemplateOpinionEntryTitle,
        body: l.bodyTemplateOpinion,
      ),
      EntryTemplateId.lessonsLearned => (
        label: l.labelTemplateLessonsLearned,
        description: l.descTemplateLessonsLearned,
        title: l.descTemplateLessonsLearnedEntryTitle,
        body: l.bodyTemplateLessonsLearned,
      ),
      EntryTemplateId.projects => (
        label: l.labelTemplateProjects,
        description: l.descTemplateProjects,
        title: l.descTemplateProjectsEntryTitle,
        body: l.bodyTemplateProjects,
      ),
      EntryTemplateId.projectUpdate => (
        label: l.labelTemplateProjectUpdate,
        description: l.descTemplateProjectUpdate,
        title: l.descTemplateProjectUpdateEntryTitle,
        body: l.bodyTemplateProjectUpdate,
      ),
      EntryTemplateId.weeklyReview => (
        label: l.labelTemplateWeeklyReview,
        description: l.descTemplateWeeklyReview,
        title: l.descTemplateWeeklyReviewEntryTitle,
        body: l.bodyTemplateWeeklyReview,
      ),
      EntryTemplateId.goalTracker => (
        label: l.labelTemplateGoalTracker,
        description: l.descTemplateGoalTracker,
        title: l.descTemplateGoalTrackerEntryTitle,
        body: l.bodyTemplateGoalTracker,
      ),
      EntryTemplateId.decisionLog => (
        label: l.labelTemplateDecisionLog,
        description: l.descTemplateDecisionLog,
        title: l.descTemplateDecisionLogEntryTitle,
        body: l.bodyTemplateDecisionLog,
      ),
      EntryTemplateId.stuckPoint => (
        label: l.labelTemplateStuckPoint,
        description: l.descTemplateStuckPoint,
        title: l.descTemplateStuckPointEntryTitle,
        body: l.bodyTemplateStuckPoint,
      ),
      EntryTemplateId.meeting => (
        label: l.labelTemplateMeeting,
        description: l.descTemplateMeeting,
        title: l.descTemplateMeetingEntryTitle,
        body: l.bodyTemplateMeeting,
      ),
      EntryTemplateId.conversationRecap => (
        label: l.labelTemplateConversationRecap,
        description: l.descTemplateConversationRecap,
        title: l.descTemplateConversationRecapEntryTitle,
        body: l.bodyTemplateConversationRecap,
      ),
      EntryTemplateId.gratefulPeople => (
        label: l.labelTemplateGratefulPeople,
        description: l.descTemplateGratefulPeople,
        title: l.descTemplateGratefulPeopleEntryTitle,
        body: l.bodyTemplateGratefulPeople,
      ),
      EntryTemplateId.unsentLetter => (
        label: l.labelTemplateUnsentLetter,
        description: l.descTemplateUnsentLetter,
        title: l.descTemplateUnsentLetterEntryTitle,
        body: l.bodyTemplateUnsentLetter,
      ),
      EntryTemplateId.relationshipCheckin => (
        label: l.labelTemplateRelationshipCheckin,
        description: l.descTemplateRelationshipCheckin,
        title: l.descTemplateRelationshipCheckinEntryTitle,
        body: l.bodyTemplateRelationshipCheckin,
      ),
      EntryTemplateId.gratitude => (
        label: l.labelTemplateGratitude,
        description: l.descTemplateGratitude,
        title: l.descTemplateGratitudeEntryTitle,
        body: l.bodyTemplateGratitude,
      ),
      EntryTemplateId.bodyCheckin => (
        label: l.labelTemplateBodyCheckin,
        description: l.descTemplateBodyCheckin,
        title: l.descTemplateBodyCheckinEntryTitle,
        body: l.bodyTemplateBodyCheckin,
      ),
      EntryTemplateId.mentalHealth => (
        label: l.labelTemplateMentalHealth,
        description: l.descTemplateMentalHealth,
        title: l.descTemplateMentalHealthEntryTitle,
        body: l.bodyTemplateMentalHealth,
      ),
      EntryTemplateId.habitTracker => (
        label: l.labelTemplateHabitTracker,
        description: l.descTemplateHabitTracker,
        title: l.descTemplateHabitTrackerEntryTitle,
        body: l.bodyTemplateHabitTracker,
      ),
      EntryTemplateId.sleepLog => (
        label: l.labelTemplateSleepLog,
        description: l.descTemplateSleepLog,
        title: l.descTemplateSleepLogEntryTitle,
        body: l.bodyTemplateSleepLog,
      ),
      EntryTemplateId.taughtToday => (
        label: l.labelTemplateTaughtToday,
        description: l.descTemplateTaughtToday,
        title: l.descTemplateTaughtTodayEntryTitle,
        body: l.bodyTemplateTaughtToday,
      ),
      EntryTemplateId.bookNotes => (
        label: l.labelTemplateBookNotes,
        description: l.descTemplateBookNotes,
        title: l.descTemplateBookNotesEntryTitle,
        body: l.bodyTemplateBookNotes,
      ),
      EntryTemplateId.skillPractice => (
        label: l.labelTemplateSkillPractice,
        description: l.descTemplateSkillPractice,
        title: l.descTemplateSkillPracticeEntryTitle,
        body: l.bodyTemplateSkillPractice,
      ),
      EntryTemplateId.mistakeLog => (
        label: l.labelTemplateMistakeLog,
        description: l.descTemplateMistakeLog,
        title: l.descTemplateMistakeLogEntryTitle,
        body: l.bodyTemplateMistakeLog,
      ),
      EntryTemplateId.topicDeepDive => (
        label: l.labelTemplateTopicDeepDive,
        description: l.descTemplateTopicDeepDive,
        title: l.descTemplateTopicDeepDiveEntryTitle,
        body: l.bodyTemplateTopicDeepDive,
      ),
      EntryTemplateId.dreamJournal => (
        label: l.labelTemplateDreamJournal,
        description: l.descTemplateDreamJournal,
        title: l.descTemplateDreamJournalEntryTitle,
        body: l.bodyTemplateDreamJournal,
      ),
      EntryTemplateId.observation => (
        label: l.labelTemplateObservation,
        description: l.descTemplateObservation,
        title: l.descTemplateObservationEntryTitle,
        body: l.bodyTemplateObservation,
      ),
      EntryTemplateId.quoteOfDay => (
        label: l.labelTemplateQuoteOfDay,
        description: l.descTemplateQuoteOfDay,
        title: l.descTemplateQuoteOfDayEntryTitle,
        body: l.bodyTemplateQuoteOfDay,
      ),
      EntryTemplateId.storySeed => (
        label: l.labelTemplateStorySeed,
        description: l.descTemplateStorySeed,
        title: l.descTemplateStorySeedEntryTitle,
        body: l.bodyTemplateStorySeed,
      ),
      EntryTemplateId.travel => (
        label: l.labelTemplateTravel,
        description: l.descTemplateTravel,
        title: l.descTemplateTravelEntryTitle,
        body: l.bodyTemplateTravel,
      ),
      EntryTemplateId.tomorrowFocus => (
        label: l.labelTemplateTomorrowFocus,
        description: l.descTemplateTomorrowFocus,
        title: l.descTemplateTomorrowFocusEntryTitle,
        body: l.bodyTemplateTomorrowFocus,
      ),
      EntryTemplateId.weeklyIntentions => (
        label: l.labelTemplateWeeklyIntentions,
        description: l.descTemplateWeeklyIntentions,
        title: l.descTemplateWeeklyIntentionsEntryTitle,
        body: l.bodyTemplateWeeklyIntentions,
      ),
      EntryTemplateId.monthlyReview => (
        label: l.labelTemplateMonthlyReview,
        description: l.descTemplateMonthlyReview,
        title: l.descTemplateMonthlyReviewEntryTitle,
        body: l.bodyTemplateMonthlyReview,
      ),
      EntryTemplateId.workoutLog => (
        label: l.labelTemplateWorkoutLog,
        description: l.descTemplateWorkoutLog,
        title: l.descTemplateWorkoutLogEntryTitle,
        body: l.bodyTemplateWorkoutLog,
      ),
      EntryTemplateId.readingLog => (
        label: l.labelTemplateReadingLog,
        description: l.descTemplateReadingLog,
        title: l.descTemplateReadingLogEntryTitle,
        body: l.bodyTemplateReadingLog,
      ),
      EntryTemplateId.foodJournal => (
        label: l.labelTemplateFoodJournal,
        description: l.descTemplateFoodJournal,
        title: l.descTemplateFoodJournalEntryTitle,
        body: l.bodyTemplateFoodJournal,
      ),
      EntryTemplateId.spendingLog => (
        label: l.labelTemplateSpendingLog,
        description: l.descTemplateSpendingLog,
        title: l.descTemplateSpendingLogEntryTitle,
        body: l.bodyTemplateSpendingLog,
      ),
      EntryTemplateId.prayerMeditation => (
        label: l.labelTemplatePrayerMeditation,
        description: l.descTemplatePrayerMeditation,
        title: l.descTemplatePrayerMeditationEntryTitle,
        body: l.bodyTemplatePrayerMeditation,
      ),
      EntryTemplateId.sysadminRunbook => (
        label: l.labelTemplateSysadminRunbook,
        description: l.descTemplateSysadminRunbook,
        title: l.descTemplateSysadminRunbookEntryTitle,
        body: l.bodyTemplateSysadminRunbook,
      ),
      EntryTemplateId.sanathanaDharmaStudy => (
        label: l.labelTemplateSanathanaDharmaStudy,
        description: l.descTemplateSanathanaDharmaStudy,
        title: l.descTemplateSanathanaDharmaStudyEntryTitle,
        body: l.bodyTemplateSanathanaDharmaStudy,
      ),
      EntryTemplateId.diyProject => (
        label: l.labelTemplateDiyProject,
        description: l.descTemplateDiyProject,
        title: l.descTemplateDiyProjectEntryTitle,
        body: l.bodyTemplateDiyProject,
      ),
      EntryTemplateId.homeMaintenance => (
        label: l.labelTemplateHomeMaintenance,
        description: l.descTemplateHomeMaintenance,
        title: l.descTemplateHomeMaintenanceEntryTitle,
        body: l.bodyTemplateHomeMaintenance,
      ),
      EntryTemplateId.kitchenRecipe => (
        label: l.labelTemplateKitchenRecipe,
        description: l.descTemplateKitchenRecipe,
        title: l.descTemplateKitchenRecipeEntryTitle,
        body: l.bodyTemplateKitchenRecipe,
      ),
    };
  }
}
