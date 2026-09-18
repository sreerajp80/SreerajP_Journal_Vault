part of 'app.dart';

class _SearchTab extends ConsumerStatefulWidget {
  const _SearchTab();

  @override
  ConsumerState<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<_SearchTab> {
  final _queryCtrl = TextEditingController();
  String _query = '';
  bool _filterEntries = false;
  List<Journal>? _journalResults;
  List<FtsSearchResult>? _entryResults;
  List<SearchPreset>? _presets;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPresets() async {
    if (!mounted) return;
    final db = ref.read(appDatabaseProvider);
    final presets = await db.searchPresetsDao.getAllPresets();
    if (mounted) setState(() => _presets = presets);
  }

  Future<void> _runSearch(String query) async {
    if (!mounted) return;
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _query = '';
        _journalResults = null;
        _entryResults = null;
      });
      return;
    }
    setState(() => _query = trimmed);

    final db = ref.read(appDatabaseProvider);
    final unlockedIds = ref.read(unlockedJournalIdsProvider);

    final allJournals = await db.journalsDao.getAllJournals();
    final journalMap = {for (final j in allJournals) j.id: j};

    final journalResults = allJournals
        .where((j) => j.title.toLowerCase().contains(trimmed.toLowerCase()))
        .toList();

    final ftsResults = await db.searchEntries(trimmed);
    final entryResults = ftsResults.where((r) {
      final journal = journalMap[r.journalId];
      if (journal == null) return false;
      return !journal.isLocked || unlockedIds.contains(r.journalId);
    }).toList();

    if (mounted) {
      setState(() {
        _journalResults = journalResults;
        _entryResults = entryResults;
      });
    }
  }

  Future<void> _applyPreset(SearchPreset preset) async {
    _queryCtrl.text = preset.query;
    setState(() {
      _query = preset.query;
      _filterEntries = preset.resultType == 'entries';
    });
    await _runSearch(preset.query);
  }

  Future<void> _savePreset() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _SavePresetDialog(),
    );
    if (name == null || name.isEmpty || !mounted) return;
    final db = ref.read(appDatabaseProvider);
    await db.searchPresetsDao.createPreset(
      SearchPresetsCompanion.insert(
        name: name,
        query: _query,
        resultType: Value(_filterEntries ? 'entries' : null),
      ),
    );
    await _loadPresets();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const Key('search-query-field'),
          controller: _queryCtrl,
          decoration: InputDecoration(
            hintText: l10n.descSearch,
            border: InputBorder.none,
          ),
          onChanged: _runSearch,
        ),
        actions: [
          if (_query.isNotEmpty) ...[
            IconButton(
              key: const Key('search-filter-entries'),
              icon: Icon(
                _filterEntries ? Icons.filter_alt : Icons.filter_alt_outlined,
              ),
              tooltip: l10n.tooltipFilterEntries,
              onPressed: () => setState(() => _filterEntries = !_filterEntries),
            ),
            IconButton(
              key: const Key('search-save-preset-button'),
              icon: const Icon(Icons.bookmark_add_outlined),
              tooltip: l10n.tooltipSaveSearch,
              onPressed: _savePreset,
            ),
          ],
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preset chips
          if (_presets != null && _presets!.isNotEmpty)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                children: [
                  for (final preset in _presets!)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        label: Text(preset.name),
                        onPressed: () => _applyPreset(preset),
                      ),
                    ),
                ],
              ),
            ),
          // Results
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final l10n = AppLocalizations.of(context);
    if (_query.isEmpty) {
      return Center(child: Text(l10n.actionSearchTypeToSearch));
    }

    final journals = _journalResults ?? [];
    final entries = _entryResults ?? [];

    if (_filterEntries && entries.isEmpty) {
      return Center(child: Text(l10n.bodySearchNoFilterMatches));
    }
    if (!_filterEntries && journals.isEmpty && entries.isEmpty) {
      return Center(child: Text(l10n.emptySearch));
    }

    // One flat row list, built lazily: results have no upper bound.
    final rows = <Widget Function()>[
      if (!_filterEntries && journals.isNotEmpty) ...[
        () => _sectionHeader(
          const Key('search-section-journals'),
          l10n.titleSearchSectionJournals,
        ),
        for (final j in journals) () => ListTile(title: Text(j.title)),
      ],
      if (entries.isNotEmpty) ...[
        () => _sectionHeader(
          const Key('search-section-entries'),
          l10n.titleSearchSectionEntries,
        ),
        for (final e in entries)
          () => ListTile(title: Text(e.title ?? l10n.descCommonUntitled)),
      ],
    ];

    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) => rows[index](),
    );
  }

  Widget _sectionHeader(Key key, String title) {
    return ListTile(
      key: key,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _SavePresetDialog extends StatefulWidget {
  const _SavePresetDialog();

  @override
  State<_SavePresetDialog> createState() => _SavePresetDialogState();
}

class _SavePresetDialogState extends State<_SavePresetDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.titleSearchSavePreset),
      content: TextField(
        key: const Key('search-preset-name-field'),
        controller: _ctrl,
        decoration: InputDecoration(labelText: l10n.labelSearchPresetName),
      ),
      actions: [
        TextButton(
          key: const Key('search-save-preset-confirm-button'),
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: Text(l10n.actionCommonSave),
        ),
      ],
    );
  }
}
