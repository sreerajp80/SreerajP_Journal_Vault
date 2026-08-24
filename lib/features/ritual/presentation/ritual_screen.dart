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
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// The guided daily practice screen combining breath grounding, reflection prompts, and journaling.
class RitualScreen extends ConsumerStatefulWidget {
  const RitualScreen({super.key, this.initialStep = 0});

  /// 0 = Breathing, 1 = Prompt Card, 2 = Reflection & Journal
  final int initialStep;

  @override
  ConsumerState<RitualScreen> createState() => _RitualScreenState();
}

class _RitualScreenState extends ConsumerState<RitualScreen> {
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
        title: Text(l10n.ritualScreenTitle),
        actions: [
          IconButton(
            tooltip: l10n.ritualDeckBrowserTitle,
            icon: const Icon(Icons.style_outlined),
            onPressed: () => _openDeckBrowser(context),
          ),
          IconButton(
            tooltip: l10n.ritualSettingsTitle,
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
                  _buildStepDot(0, l10n.ritualStepBreathe, colorScheme),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep > 0
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  ),
                  _buildStepDot(1, l10n.ritualStepReflect, colorScheme),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep > 1
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  ),
                  _buildStepDot(2, l10n.ritualStepWrite, colorScheme),
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

  Widget _buildStepDot(int stepIndex, String label, ColorScheme colorScheme) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _currentStep = stepIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? colorScheme.primary
                    : isActive
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: isActive || isDone
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isDone
                    ? Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: colorScheme.onPrimary,
                      )
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? colorScheme.primary : colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    RitualState state,
    AppLocalizations l10n,
  ) {
    switch (_currentStep) {
      case 0:
        return _buildBreathingStep(context, state, l10n);
      case 1:
        return _buildPromptStep(context, state, l10n);
      case 2:
      default:
        return _buildJournalStep(context, state, l10n);
    }
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
            l10n.ritualBreatheHeading,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            state.breathTechnique.displayName,
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
                child: Text(l10n.ritualSkipToPrompt),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(l10n.ritualContinueToCard),
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
    final langCode = Localizations.localeOf(context).languageCode;
    final card = state.currentCard;
    final title = card.localizedTitle(langCode);
    final prompt = card.localizedPrompt(langCode);
    final quote = card.localizedQuote(langCode);
    final quoteAuthor = card.localizedQuoteAuthor(langCode);
    final themeName = card.theme.localizedName(langCode);

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
                label: Text(l10n.ritualShuffleCard),
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
            l10n.ritualSrsRatePrompt,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildRatingButton(
                  label: l10n.ritualSrsHard,
                  subtitle: l10n.ritualSrsHardSubtitle,
                  rating: RepetitionRating.hard,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRatingButton(
                  label: l10n.ritualSrsRevision,
                  subtitle: l10n.ritualSrsRevisionSubtitle,
                  rating: RepetitionRating.revision,
                  color: Colors.amber.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRatingButton(
                  label: l10n.ritualSrsEasy,
                  subtitle: l10n.ritualSrsEasySubtitle,
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
            label: Text(l10n.ritualProceedToJournal),
            onPressed: () => setState(() => _currentStep = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingButton({
    required String label,
    required String subtitle,
    required RepetitionRating rating,
    required Color color,
  }) {
    final isSelected = _selectedRating == rating;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        side: BorderSide(
          color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
        backgroundColor: isSelected ? color.withValues(alpha: 0.12) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        setState(() => _selectedRating = rating);
        ref.read(ritualNotifierProvider.notifier).rateCurrentCard(rating);
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
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
    final langCode = Localizations.localeOf(context).languageCode;
    final title = card.localizedTitle(langCode);

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
            l10n.ritualReadyToWriteTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.ritualReadyToWriteDesc(title),
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
            label: Text(l10n.ritualBeginWritingButton),
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
            child: Text(l10n.ritualCompletePracticeOnly),
          ),
        ],
      ),
    );
  }

  Future<void> _openJournalEditor(BuildContext context, RitualCard card) async {
    final l10n = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final db = ref.read(appDatabaseProvider);
    final journals = await db.journalsDao.getAllJournals();
    if (!mounted) return;

    if (journals.isEmpty) {
      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(SnackBar(content: Text(l10n.ritualNoJournalError)));
      return;
    }

    final title = card.localizedTitle(langCode);
    final prompt = card.localizedPrompt(langCode);
    final quote = card.localizedQuote(langCode);
    final quoteAuthor = card.localizedQuoteAuthor(langCode);
    final quoteLine = quoteAuthor != null
        ? '"$quote" — $quoteAuthor'
        : '"$quote"';
    final journalId = journals.first.id;
    final initialPlainText = '$prompt\n\n$quoteLine\n\n';

    await Navigator.of(this.context).push(
      MaterialPageRoute<void>(
        builder: (_) => EntryEditorScreen(
          journalId: journalId,
          initialTitle: title,
          initialPlainText: initialPlainText,
        ),
      ),
    );

    if (mounted) {
      Navigator.of(this.context).pop();
    }
  }

  Future<void> _openDeckBrowser(BuildContext context) async {
    final card = await Navigator.of(this.context).push<RitualCard>(
      MaterialPageRoute<RitualCard>(builder: (_) => const RitualDeckScreen()),
    );
    if (card != null && mounted) {
      setState(() => _currentStep = 1);
    }
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(ritualNotifierProvider.notifier);

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final curState = ref.watch(ritualNotifierProvider);

          return AlertDialog(
            title: Text(l10n.ritualSettingsTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.ritualLaunchOnStartupTitle),
                    subtitle: Text(l10n.ritualLaunchOnStartupSubtitle),
                    value: curState.launchOnStartup,
                    onChanged: (v) {
                      notifier.setLaunchOnStartup(v);
                      setDialogState(() {});
                    },
                  ),
                  const Divider(),
                  Text(
                    l10n.ritualBreathTechniqueLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...BreathTechnique.values.map((t) {
                    // ignore: deprecated_member_use
                    return RadioListTile<BreathTechnique>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.displayName),
                      value: t,
                      // ignore: deprecated_member_use
                      groupValue: curState.breathTechnique,
                      // ignore: deprecated_member_use
                      onChanged: (val) {
                        if (val != null) {
                          notifier.setBreathTechnique(val);
                          setDialogState(() {});
                        }
                      },
                    );
                  }),
                  const Divider(),
                  Text(
                    l10n.ritualBreathCyclesLabel(curState.breathCycles),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: curState.breathCycles.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '${curState.breathCycles}',
                    onChanged: (v) {
                      notifier.setBreathCycles(v.toInt());
                      setDialogState(() {});
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.commonClose),
              ),
            ],
          );
        },
      ),
    );
  }
}
