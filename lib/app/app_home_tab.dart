part of 'app.dart';

class _HomeTab extends ConsumerStatefulWidget {
  const _HomeTab();

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> {
  List<JournalSummary>? _journals;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final items = await ref.read(journalServiceProvider).journalSummaries();
    if (mounted) setState(() => _journals = items);
  }

  Future<void> _openForm({
    Journal? journal,
    List<Tag> initialTags = const [],
  }) async {
    final result =
        await showDialog<
          ({
            String title,
            String desc,
            String tags,
            bool locked,
            String? password,
          })
        >(
          context: context,
          builder: (_) =>
              _JournalFormDialog(journal: journal, initialTags: initialTags),
        );
    if (result == null || !mounted) return;

    final journals = ref.read(journalServiceProvider);

    if (journal == null) {
      final journalId = await journals.createJournal(
        title: result.title,
        description: result.desc,
        tagsText: result.tags,
      );
      // Lock if requested
      if (result.locked &&
          result.password != null &&
          result.password!.isNotEmpty) {
        final svc = ref.read(_journalPasswordServiceProvider);
        final cred = await svc.createCredential(
          journalId: journalId,
          password: result.password!,
        );
        await journals.lockJournal(journalId, cred);
      }
    } else {
      await journals.updateJournal(
        journal.id,
        title: result.title,
        description: result.desc,
        tagsText: result.tags,
      );
    }
    await _load();
  }

  Future<void> _deleteJournal(Journal journal) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(l10n.bodyJournalDelete),
          content: Text(l10n.bodyJournalDeleteBody(journal.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.actionCommonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.actionCommonDelete),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    // One transaction: the journal, its tags, its entries and their files all
    // go, or nothing does.
    try {
      await ref.read(entryDeletionServiceProvider).deleteJournal(journal.id);
    } catch (e, stackTrace) {
      AppLogger.error(
        'HomeTab: journal delete failed',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorJournalDelete),
          ),
        );
      }
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final journals = _journals;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navHome),
        actions: [
          if (AppFlavorConfig.instance.enableSyncUi) ...[
            SyncStatusWidget(
              showLabel: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const ConflictResolutionScreen(),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            tooltip: l10n.tooltipJournalManageTags,
            icon: const Icon(Icons.sell_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const TagManagerScreen()),
            ).then((_) => _load()),
          ),
          IconButton(
            key: const Key('home-ritual-mode-button'),
            tooltip: l10n.titleRitual,
            icon: const Icon(Icons.self_improvement_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const RitualScreen()),
            ).then((_) => _load()),
          ),
          IconButton(
            key: const Key('home-manage-templates-button'),
            tooltip: l10n.actionJournalManageTemplates,
            icon: const Icon(Icons.dashboard_customize_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const TemplateManagerScreen(),
              ),
            ),
          ),
          IconButton(
            key: const Key('home-time-capsules-button'),
            tooltip: l10n.titleTimeCapsule,
            icon: const Icon(Icons.hourglass_bottom_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const TimeCapsulesListScreen(),
              ),
            ).then((_) => _load()),
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer(
            builder: (context, ref, _) {
              final readyAsync = ref.watch(readyToOpenCapsulesProvider);
              final readyCount = readyAsync.asData?.value.length ?? 0;
              if (readyCount == 0) return const SizedBox.shrink();
              final theme = Theme.of(context);
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.bodyTimeCapsuleBanner,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            readyCount == 1
                                ? l10n.bodyTimeCapsuleBannerBody(readyCount)
                                : l10n.descTimeCapsuleBannerBodyPlural(
                                    readyCount,
                                  ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      key: const Key('home-ready-capsule-open-button'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const TimeCapsulesListScreen(),
                        ),
                      ).then((_) => _load()),
                      child: Text(l10n.actionTimeCapsuleReadyToOpen),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: journals == null
                ? const Center(child: CircularProgressIndicator())
                : journals.isEmpty
                ? const _HomeEmptyState()
                : RefreshIndicator(
                    onRefresh: _load,
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.82,
                          ),
                      itemCount: journals.length,
                      itemBuilder: (_, i) {
                        final summary = journals[i];
                        return _JournalCard(
                          summary: summary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => _JournalDetailScreen(
                                journal: summary.journal,
                              ),
                            ),
                          ).then((_) => _load()),
                          onEdit: () => _openForm(
                            journal: summary.journal,
                            initialTags: summary.tags,
                          ),
                          onDelete: () => _deleteJournal(summary.journal),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: l10n.tooltipJournalNew,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: Text(l10n.tooltipJournalNew),
      ),
    );
  }
}

// ─── Home empty state ──────────────────────────────────────────────────────

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 40,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).emptyJournal,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).emptyJournalEmptyBody,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Journal card ──────────────────────────────────────────────────────────

const List<Color> _kJournalCoverPalette = [
  Color(0xFFB39DDB), // soft purple
  Color(0xFF90CAF9), // soft blue
  Color(0xFFA5D6A7), // mint
  Color(0xFFFFCC80), // peach
  Color(0xFFF48FB1), // pink
  Color(0xFF80CBC4), // teal
  Color(0xFFFFAB91), // coral
  Color(0xFFCE93D8), // lilac
];

Color _coverColorForJournal(int journalId) =>
    _kJournalCoverPalette[journalId.abs() % _kJournalCoverPalette.length];

String _formatRelativeDate(AppLocalizations l10n, DateTime when) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final whenDay = DateTime(when.year, when.month, when.day);
  final diffDays = today.difference(whenDay).inDays;
  if (diffDays <= 0) return l10n.labelDateToday;
  if (diffDays == 1) return l10n.labelDateYesterday;
  if (diffDays < 7) return l10n.labelDateDaysAgo(diffDays);
  if (diffDays < 30) return l10n.labelDateWeeksAgo((diffDays / 7).floor());
  if (diffDays < 365) return l10n.labelDateMonthsAgo((diffDays / 30).floor());
  return l10n.labelDateYearsAgo((diffDays / 365).floor());
}
