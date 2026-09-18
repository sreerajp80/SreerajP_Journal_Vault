part of 'app.dart';

class _JournalDetailScreen extends ConsumerStatefulWidget {
  const _JournalDetailScreen({required this.journal});

  final Journal journal;

  @override
  ConsumerState<_JournalDetailScreen> createState() =>
      _JournalDetailScreenState();
}

class _JournalDetailScreenState extends ConsumerState<_JournalDetailScreen> {
  List<Entry>? _entries;
  Map<int, TimeCapsule> _capsules = {};
  String? _unlockError;
  final _passwordController = TextEditingController();

  bool get _isSessionUnlocked {
    final ids = ref.read(unlockedJournalIdsProvider);
    return ids.contains(widget.journal.id);
  }

  bool get _isAccessible => !widget.journal.isLocked || _isSessionUnlocked;

  @override
  void initState() {
    super.initState();
    if (_isAccessible) _loadEntries();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    if (!mounted) return;
    final db = ref.read(appDatabaseProvider);
    final entries = await db.entriesDao.getEntriesForJournal(widget.journal.id);
    final allCapsules = await db.timeCapsulesDao.getAllCapsules();
    final capsulesMap = {for (final c in allCapsules) c.entryId: c};
    if (mounted) {
      setState(() {
        _entries = entries;
        _capsules = capsulesMap;
      });
    }
  }

  Future<void> _tryUnlock() async {
    final password = _passwordController.text;
    final svc = ref.read(_journalPasswordServiceProvider);
    final ok = await svc.verifyPassword(
      journal: widget.journal,
      password: password,
    );
    if (!mounted) return;
    if (ok) {
      final current = ref.read(unlockedJournalIdsProvider);
      ref.read(unlockedJournalIdsProvider.notifier).set({
        ...current,
        widget.journal.id,
      });
      setState(() => _unlockError = null);
      await _loadEntries();
    } else {
      setState(
        () => _unlockError = AppLocalizations.of(
          context,
        ).bodyJournalIncorrectPassword,
      );
    }
  }

  Future<void> _openEntryScreen({Entry? entry}) async {
    EntryTemplate? template;
    if (entry == null) {
      // For new entries, ask the user to pick a starter template first.
      final selected = await showDialog<EntryTemplate>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const EntryTemplateChooserDialog(),
      );
      if (!mounted) return;
      if (selected == null) return; // User dismissed somehow.
      template = selected;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => EntryEditorScreen(
          journalId: widget.journal.id,
          entryId: entry?.id,
          initialTemplateId: template?.id,
          initialTemplate: template,
        ),
      ),
    );
    if (mounted) await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(unlockedJournalIdsProvider); // Rebuild on unlock change
    final accessible = _isAccessible;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.journal.title),
        actions: [
          // Only once the journal is open. A locked journal must be unlocked
          // before any of it can be written out.
          if (accessible)
            IconButton(
              key: const Key('journal-export-button'),
              icon: const Icon(Icons.ios_share),
              tooltip: AppLocalizations.of(context).tooltipExportJournal,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ExportScreen(
                    journalId: widget.journal.id,
                    journalTitle: widget.journal.title,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: accessible
          ? FloatingActionButton.extended(
              onPressed: () => _openEntryScreen(),
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context).actionJournalAddEntry),
            )
          : null,
      body: accessible ? _buildEntries() : _buildLocked(),
    );
  }

  Widget _buildLocked() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.labelJournalIsLocked),
          const SizedBox(height: 16),
          TextField(
            key: const Key('journal-unlock-password-field'),
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.labelCommonPassword),
          ),
          if (_unlockError != null) ...[
            const SizedBox(height: 8),
            Text(_unlockError!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('journal-unlock-button'),
            onPressed: _tryUnlock,
            child: Text(l10n.actionCommonUnlock),
          ),
        ],
      ),
    );
  }

  Widget _buildEntries() {
    final l10n = AppLocalizations.of(context);
    final entries = _entries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.labelJournalUnlocked),
        ),
        Expanded(
          child: entries == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (_, i) {
                    final entry = entries[i];
                    final date = entry.entryDate ?? entry.createdAt;
                    final capsule = _capsules[entry.id];
                    final isCapsule = capsule != null;
                    final isSealed = isCapsule && !capsule.isOpened;
                    final isReady =
                        isSealed &&
                        !DateTime.now().isBefore(capsule.unlockDate);

                    Widget? leading;
                    Widget subtitle;
                    if (isSealed) {
                      leading = Icon(
                        isReady
                            ? Icons.lock_open_rounded
                            : Icons.hourglass_bottom_rounded,
                        color: isReady
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      );
                      subtitle = Text(
                        isReady
                            ? l10n.actionTimeCapsuleReadyToOpen
                            : l10n.labelTimeCapsuleSealedUntil(
                                _fmtDate(capsule.unlockDate),
                              ),
                        style: TextStyle(
                          color: isReady
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          fontWeight: isReady
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    } else {
                      subtitle = Text(_fmtDate(date));
                    }

                    return ListTile(
                      leading: leading,
                      title: Text(entry.title ?? l10n.descCommonUntitled),
                      subtitle: subtitle,
                      onTap: () {
                        if (isSealed) {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => TimeCapsuleSealedScreen(
                                entryId: entry.id,
                                journalId: widget.journal.id,
                              ),
                            ),
                          ).then((_) => _loadEntries());
                        } else {
                          _openEntryScreen(entry: entry);
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SEARCH TAB
// ═══════════════════════════════════════════════════════════════════════════
