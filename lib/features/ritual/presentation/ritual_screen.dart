import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_editor_screen.dart';
import 'package:sreerajp_journal_vault/features/ritual/domain/ritual_card.dart';
import 'package:sreerajp_journal_vault/features/ritual/domain/spaced_repetition.dart';
import 'package:sreerajp_journal_vault/features/ritual/presentation/ritual_deck_screen.dart';
import 'package:sreerajp_journal_vault/features/ritual/presentation/widgets/breathing_orb_widget.dart';
import 'package:sreerajp_journal_vault/features/ritual/providers/ritual_providers.dart';
import 'package:sreerajp_journal_vault/features/ritual/services/ritual_service.dart';
import 'package:sreerajp_journal_vault/features/ritual/presentation/ritual_card_text.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

part 'ritual_screen_steps.dart';

/// The guided daily practice screen combining breath grounding, reflection prompts, and journaling.
class RitualScreen extends ConsumerStatefulWidget {
  const RitualScreen({super.key, this.initialStep = 0});

  /// 0 = Breathing, 1 = Prompt Card, 2 = Reflection & Journal
  final int initialStep;

  @override
  ConsumerState<RitualScreen> createState() => _RitualScreenState();
}

class _RitualScreenState extends ConsumerState<RitualScreen> {
  /// Lets the extensions in this library's part files rebuild the
  /// widget: `setState` is protected, so they cannot call it directly.
  void _rebuild(VoidCallback fn) => setState(fn);

  late int _currentStep;
  RepetitionRating? _selectedRating;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ritualState = ref.watch(ritualNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.titleRitual),
        actions: [
          IconButton(
            tooltip: l10n.titleRitualDeckBrowser,
            icon: const Icon(Icons.style_outlined),
            onPressed: () => _openDeckBrowser(context),
          ),
          IconButton(
            tooltip: l10n.titleRitualSettings,
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  _buildStepDot(0, l10n.labelRitualStepBreathe, colorScheme),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep > 0
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  ),
                  _buildStepDot(1, l10n.labelRitualStepReflect, colorScheme),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep > 1
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  ),
                  _buildStepDot(2, l10n.labelRitualStepWrite, colorScheme),
                ],
              ),
            ),
            const Divider(height: 1),
            // Step Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(context, ritualState, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────── STEP 1: BREATHING ────────────────────────────

  Widget _buildBreathingStep(
    BuildContext context,
    RitualState state,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            l10n.titleRitualBreathe,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.breathTechnique.nameIn(l10n)} '
            '(${state.breathTechnique.rhythm})',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          BreathingOrbWidget(
            key: ValueKey('${state.breathTechnique}_${state.breathCycles}'),
            technique: state.breathTechnique,
            cycles: state.breathCycles,
            onComplete: () {
              Future.delayed(const Duration(milliseconds: 1200), () {
                if (mounted && _currentStep == 0) {
                  setState(() => _currentStep = 1);
                }
              });
            },
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: Text(l10n.actionRitualSkipToPrompt),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(l10n.actionRitualContinueToCard),
                onPressed: () => setState(() => _currentStep = 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────── STEP 2: PROMPT CARD ────────────────────────────

  Widget _buildPromptStep(
    BuildContext context,
    RitualState state,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final card = state.currentCard;
    final title = card.titleIn(l10n);
    final prompt = card.promptIn(l10n);
    final quote = card.quoteIn(l10n);
    final quoteAuthor = card.sourceIn(l10n);
    final themeName = card.theme.nameIn(l10n);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header with category badge & shuffle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: card.theme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      card.theme.icon,
                      size: 16,
                      color: card.theme.accentColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      themeName.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: card.theme.accentColor,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.shuffle_rounded, size: 18),
                label: Text(l10n.actionRitualShuffleCard),
                onPressed: () =>
                    ref.read(ritualNotifierProvider.notifier).shuffleCard(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Main Prompt Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: card.theme.accentColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    prompt,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.45,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.6,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 20,
                          color: card.theme.accentColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '"$quote"${quoteAuthor != null ? " — $quoteAuthor" : ""}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Spaced repetition rating bar
          Text(
            l10n.bodyRitualSrsRatePrompt,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildRatingButton(
                  label: l10n.actionRitualSrsHard,
                  subtitle: l10n.descRitualSrsHard,
                  rating: RepetitionRating.hard,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRatingButton(
                  label: l10n.actionRitualSrsRevision,
                  subtitle: l10n.descRitualSrsRevision,
                  rating: RepetitionRating.revision,
                  color: Colors.amber.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRatingButton(
                  label: l10n.actionRitualSrsEasy,
                  subtitle: l10n.descRitualSrsEasy,
                  rating: RepetitionRating.easy,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(l10n.actionRitualProceedToJournal),
            onPressed: () => setState(() => _currentStep = 2),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────── STEP 3: JOURNAL ENTRY ───────────────────────────

  Widget _buildJournalStep(
    BuildContext context,
    RitualState state,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final card = state.currentCard;
    final title = card.titleIn(l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.titleRitualReadyToWrite,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.descRitualReadyToWrite(title),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.edit_rounded),
            label: Text(l10n.actionRitualBeginWriting),
            onPressed: () => _openJournalEditor(context, card),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionRitualCompletePracticeOnly),
          ),
        ],
      ),
    );
  }
}
