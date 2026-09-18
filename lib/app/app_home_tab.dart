part of 'app.dart';

class _HomeTab extends ConsumerStatefulWidget {
  const _HomeTab();

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _JournalSummary {
  const _JournalSummary({
    required this.journal,
    required this.tags,
    required this.entryCount,
    required this.lastUpdatedAt,
  });

  final Journal journal;
  final List<Tag> tags;
  final int entryCount;
  final DateTime? lastUpdatedAt;
}

class _HomeTabState extends ConsumerState<_HomeTab> {
  List<_JournalSummary>? _journals;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final db = ref.read(appDatabaseProvider);
    final journals = await db.journalsDao.getAllJournals();
    final items = <_JournalSummary>[];
    for (final j in journals) {
      final tags = await db.journalTagsDao.getTagsForJournal(j.id);
      final entries = await db.entriesDao.getEntriesForJournal(j.id);
      DateTime? lastUpdated;
      for (final e in entries) {
        if (lastUpdated == null || e.updatedAt.isAfter(lastUpdated)) {
          lastUpdated = e.updatedAt;
        }
      }
      lastUpdated ??= j.updatedAt;
      items.add(
        _JournalSummary(
          journal: j,
          tags: tags,
          entryCount: entries.length,
          lastUpdatedAt: lastUpdated,
        ),
      );
    }
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

    final db = ref.read(appDatabaseProvider);
    int journalId;

    if (journal == null) {
      journalId = await db.journalsDao.createJournal(
        JournalsCompanion.insert(
          title: result.title,
          description: Value(result.desc.isEmpty ? null : result.desc),
        ),
      );
      await _applyJournalTags(db, journalId, result.tags);
      // Lock if requested
      if (result.locked &&
          result.password != null &&
          result.password!.isNotEmpty) {
        final svc = ref.read(_journalPasswordServiceProvider);
        final cred = await svc.createCredential(
          journalId: journalId,
          password: result.password!,
        );
        await db.journalsDao.updateJournalById(
          journalId,
          JournalsCompanion(
            isLocked: const Value(true),
            credentialReference: Value(cred.credentialReference),
            passwordSaltBase64: Value(cred.passwordSaltBase64),
            passwordVerifierBase64: Value(cred.passwordVerifierBase64),
            passwordIterations: Value(cred.passwordIterations),
          ),
        );
      }
    } else {
      journalId = journal.id;
      await db.journalsDao.updateJournalById(
        journalId,
        JournalsCompanion(
          title: Value(result.title),
          description: Value(result.desc.isEmpty ? null : result.desc),
        ),
      );
      await _applyJournalTags(db, journalId, result.tags);
    }
    await _load();
  }

  /// Makes the journal's tags match [tagsText], a comma separated list.
  ///
  /// Only the difference is written: tags already on the journal are left
  /// alone, names that were removed from the text are unlinked, and new names
  /// are created if they do not exist yet. Unlinking never deletes the tag
  /// itself — tags are global and may be in use elsewhere.
  Future<void> _applyJournalTags(
    AppDatabase db,
    int journalId,
    String tagsText,
  ) async {
    final wanted = tagsText
        .split(',')
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toSet();

    final current = await db.journalTagsDao.getTagsForJournal(journalId);
    final currentNames = {for (final tag in current) tag.name: tag};

    for (final tag in current) {
      if (!wanted.contains(tag.name)) {
        await db.journalTagsDao.removeTagFromJournal(journalId, tag.id);
      }
    }
    for (final name in wanted) {
      if (currentNames.containsKey(name)) continue;
      final tagId = await db.tagsDao.getOrCreateTag(name);
      await db.journalTagsDao.addTagToJournal(journalId, tagId);
    }
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
    final db = ref.read(appDatabaseProvider);
    // Remove journal_tags (no cascade on journalId FK)
    final tags = await db.journalTagsDao.getTagsForJournal(journal.id);
    for (final tag in tags) {
      await db.journalTagsDao.removeTagFromJournal(journal.id, tag.id);
    }
    // Remove entries (no cascade on journalId FK)
    final entries = await db.entriesDao.getEntriesForJournal(journal.id);
    for (final entry in entries) {
      await db.entriesDao.deleteEntryById(entry.id);
    }
    await db.journalsDao.deleteJournalById(journal.id);
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
