part of 'ritual_screen.dart';

extension _RitualScreenStatePart1 on _RitualScreenState {
  Widget _buildStepDot(int stepIndex, String label, ColorScheme colorScheme) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _rebuild(() => _currentStep = stepIndex),
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
        _rebuild(() => _selectedRating = rating);
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

  Future<void> _openJournalEditor(BuildContext context, RitualCard card) async {
    final l10n = AppLocalizations.of(context);
    final db = ref.read(appDatabaseProvider);
    final journals = await db.journalsDao.getAllJournals();
    if (!mounted) return;

    if (journals.isEmpty) {
      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorRitualNoJournal)));
      return;
    }

    final title = card.titleIn(l10n);
    final prompt = card.promptIn(l10n);
    final quote = card.quoteIn(l10n);
    final quoteAuthor = card.sourceIn(l10n);
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
      _rebuild(() => _currentStep = 1);
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
            title: Text(l10n.titleRitualSettings),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.titleRitualLaunchOnStartup),
                    subtitle: Text(l10n.descRitualLaunchOnStartup),
                    value: curState.launchOnStartup,
                    onChanged: (v) {
                      notifier.setLaunchOnStartup(v);
                      setDialogState(() {});
                    },
                  ),
                  const Divider(),
                  Text(
                    l10n.labelRitualBreathTechnique,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...BreathTechnique.values.map((t) {
                    // ignore: deprecated_member_use
                    return RadioListTile<BreathTechnique>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.nameIn(l10n)),
                      subtitle: Text(t.rhythm),
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
                    l10n.labelRitualBreathCycles(curState.breathCycles),
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
                child: Text(l10n.actionCommonClose),
              ),
            ],
          );
        },
      ),
    );
  }
}
