import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/links/vault_backlink_parser.dart';
import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_models.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/callout_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/editor_toolbar.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/table_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/voice_note_recorder.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/version_history_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/entry_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/voice_note_service.dart';
import 'package:sreerajp_journal_vault/features/entries/templates/entry_templates.dart';
import 'package:sreerajp_journal_vault/features/insights/providers/insights_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';
import 'package:sreerajp_journal_vault/features/permissions/domain/app_permission_models.dart';
import 'package:sreerajp_journal_vault/features/permissions/providers/permissions_providers.dart';
import 'package:sreerajp_journal_vault/features/security/providers/security_providers.dart';

class EntryEditorScreen extends ConsumerStatefulWidget {
  const EntryEditorScreen({
    super.key,
    required this.journalId,
    this.entryId,
    this.initialTemplateId,
  });

  final int journalId;

  /// If provided, opens an existing entry for editing. If null, creates a new one.
  final int? entryId;

  /// When creating a new entry, the template to seed the title and content
  /// with. Null means start blank.
  final EntryTemplateId? initialTemplateId;

  @override
  ConsumerState<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends ConsumerState<EntryEditorScreen> {
  late final QuillController _quillController;
  late final TextEditingController _titleController;
  int? _entryId;

  /// 1–5 mood rating for this entry. Null until the user picks one — saved
  /// (or cleared) on the next save.
  int? _mood;

  /// True when the title, body, or mood has changed since the last successful
  /// save. Drives the save button enabled state, the AppBar dirty marker, and
  /// the "Entry saved" SnackBar so the user can tell whether work is pending.
  bool _isDirty = false;

  /// True after listeners are attached. Initial document/title hydration in
  /// [_loadEntry]/[_createEntry] would otherwise mark the entry dirty before
  /// the user has typed anything.
  bool _trackingChanges = false;

  /// Custom embed builders for tables and callouts.
  final List<EmbedBuilder> _embedBuilders = [
    TableEmbedBuilder(),
    CalloutEmbedBuilder(),
  ];

  /// Subscribes to document delta events. We don't use
  /// [QuillController.addListener] for the dirty flag because that fires on
  /// selection moves too — tapping into the editor without typing would
  /// otherwise mark the entry dirty.
  StreamSubscription<DocChange>? _docChangeSub;

  /// Last title text we've observed. [TextEditingController] notifies on any
  /// value change including selection, so we compare text to filter out
  /// caret-only changes the same way [_docChangeSub] does for the body.
  String _lastTitleText = '';

  /// Used to measure the formatting toolbar's screen position so the selection
  /// popup can flip below the selection when it would otherwise overlap.
  final GlobalKey _toolbarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    _titleController = TextEditingController();
    if (widget.entryId != null) {
      _loadEntry(widget.entryId!);
    } else {
      _createEntry();
    }
  }

  Future<void> _loadEntry(int id) async {
    final database = ref.read(appDatabaseProvider);
    final entry = await database.entriesDao.getEntryById(id);
    if (!mounted) return;
    _titleController.text = entry.title ?? '';
    if (entry.contentJson != null && entry.contentJson!.isNotEmpty && entry.contentJson != '[]') {
      try {
        final doc = Document.fromJson(jsonDecode(entry.contentJson!) as List);
        _quillController.document = doc;
        _quillController.moveCursorToEnd();
      } catch (_) {
        // Ignore parse errors — start with empty doc.
      }
    }
    final existingMood =
        await ref.read(insightsServiceProvider).getMoodForEntry(id);
    if (!mounted) return;
    setState(() {
      _entryId = id;
      _mood = existingMood?.mood;
    });
    _attachChangeListeners();
  }

  Future<void> _createEntry() async {
    final selected = templateFor(widget.initialTemplateId);

    // Pre-fill the editor with the template content if one was provided.
    if (selected.id != EntryTemplateId.blank) {
      _titleController.text = selected.defaultTitle;
      if (selected.contentJson != '[]') {
        try {
          final doc =
              Document.fromJson(jsonDecode(selected.contentJson) as List);
          _quillController.document = doc;
          _quillController.moveCursorToEnd();
        } catch (_) {/* fall through to empty doc */}
      }
    }

    final database = ref.read(appDatabaseProvider);
    final id = await database.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: widget.journalId,
        title: Value(selected.defaultTitle),
        contentJson: Value(selected.contentJson),
      ),
    );
    if (!mounted) return;
    setState(() => _entryId = id);
    _attachChangeListeners();
  }

  /// Wired after initial hydration so the seeded title/body don't immediately
  /// flip the dirty flag. From here on, any user edit marks the entry dirty.
  void _attachChangeListeners() {
    if (_trackingChanges) return;
    _trackingChanges = true;
    _lastTitleText = _titleController.text;
    _titleController.addListener(_handleTitleChange);
    _subscribeToDocChanges();
  }

  /// (Re-)subscribes to the current document's change stream. Must be called
  /// after [_quillController.document] is reassigned (e.g. revision restore),
  /// because the old subscription points at the old document object.
  void _subscribeToDocChanges() {
    _docChangeSub?.cancel();
    _docChangeSub = _quillController.document.changes.listen((_) => _markDirty());
  }

  void _handleTitleChange() {
    if (_titleController.text == _lastTitleText) return;
    _lastTitleText = _titleController.text;
    _markDirty();
  }

  void _markDirty() {
    if (_isDirty || !mounted) return;
    setState(() => _isDirty = true);
  }

  @override
  void dispose() {
    if (_trackingChanges) {
      _titleController.removeListener(_handleTitleChange);
    }
    _docChangeSub?.cancel();
    _quillController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  /// Saves the current content and creates a revision snapshot.
  Future<void> _saveContent() async {
    if (_entryId == null) return;

    final database = ref.read(appDatabaseProvider);
    final json = jsonEncode(_quillController.document.toDelta().toJson());
    final plainText = _quillController.document.toPlainText();

    // Snapshot current state before saving (for version history).
    try {
      final currentEntry = await database.entriesDao.getEntryById(_entryId!);
      if (currentEntry.contentJson != null &&
          currentEntry.contentJson!.isNotEmpty &&
          currentEntry.contentJson != '[]') {
        final revisionService = ref.read(entryRevisionServiceProvider);
        await revisionService.createRevision(currentEntry);
      }
    } catch (_) {
      // Entry may not exist yet on first save — skip revision.
    }

    await database.entriesDao.updateEntryById(
      _entryId!,
      EntriesCompanion(
        title: Value(_titleController.text.trim()),
        contentJson: Value(json),
        plainText: Value(plainText),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Refresh outbound backlinks from the saved plain text.
    final targets = VaultBacklinkParser.parse(plainText);
    await database.backlinksDao
        .replaceBacklinksForEntry(_entryId!, targets);

    // Persist the mood rating if the user picked one. Clear when nulled.
    final mood = _mood;
    if (mood != null) {
      await ref.read(insightsServiceProvider).setMood(
            entryId: _entryId!,
            mood: mood,
          );
    } else {
      await ref.read(insightsServiceProvider).deleteMood(_entryId!);
    }

    if (!mounted) return;
    setState(() => _isDirty = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          key: Key('entry-saved-snackbar'),
          content: Text('Entry saved'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  Future<void> _confirmDelete() async {
    if (_entryId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This will permanently remove the entry.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('entry-delete-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final database = ref.read(appDatabaseProvider);
    await database.entriesDao.deleteEntryById(_entryId!);
    if (mounted) Navigator.of(context).pop();
  }

  void _insertTable() {
    _showTableSizeDialog().then((size) {
      if (size == null) return;
      final embed = TableEmbed.create(
        rowCount: size.rows,
        colCount: size.cols,
      );
      final index = _quillController.selection.baseOffset;
      // Insert the embed, then a trailing newline. Without it, an
      // end-of-document table has no editable line after it and the cursor
      // gets trapped — same fix as for callouts above.
      _quillController.replaceText(index, 0, embed, null);
      _quillController.replaceText(
        index + 1,
        0,
        '\n',
        TextSelection.collapsed(offset: index + 2),
      );
    });
  }

  Future<({int rows, int cols})?> _showTableSizeDialog() async {
    int rows = 3;
    int cols = 3;
    // Bound table dimensions: 0 produces an empty embed and very large
    // values freeze the editor while building the cell controllers.
    int parseDim(String v) {
      final n = int.tryParse(v);
      return n == null ? 3 : n.clamp(1, 20);
    }
    return showDialog<({int rows, int cols})>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert table'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rows',
                helperText: '1–20',
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: '3'),
              onChanged: (v) => rows = parseDim(v),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Columns',
                helperText: '1–20',
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: '3'),
              onChanged: (v) => cols = parseDim(v),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, (rows: rows, cols: cols)),
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }

  void _insertCallout() async {
    final style = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Callout type'),
        children: [
          for (final type in ['info', 'tip', 'warning', 'important'])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, type),
              child: Row(
                children: [
                  Icon(_calloutIcon(type), color: _calloutColor(type)),
                  const SizedBox(width: 12),
                  Text(type[0].toUpperCase() + type.substring(1)),
                ],
              ),
            ),
        ],
      ),
    );
    if (style == null) return;

    final embed = CalloutEmbed.create(style: style);
    final index = _quillController.selection.baseOffset;
    // Insert the embed, then a trailing newline. Without the newline, an
    // end-of-document callout has no editable line after it and the cursor
    // gets trapped — the user can't escape the callout by tapping below.
    _quillController.replaceText(index, 0, embed, null);
    _quillController.replaceText(
      index + 1,
      0,
      '\n',
      TextSelection.collapsed(offset: index + 2),
    );
  }

  IconData _calloutIcon(String type) => switch (type) {
        'warning' => Icons.warning_amber_rounded,
        'tip' => Icons.lightbulb_outline,
        'important' => Icons.priority_high,
        _ => Icons.info_outline,
      };

  Color _calloutColor(String type) => switch (type) {
        'warning' => Colors.orange,
        'tip' => Colors.green,
        'important' => Colors.red,
        _ => Colors.blue,
      };

  void _openVersionHistory() {
    if (_entryId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VersionHistoryScreen(
          entryId: _entryId!,
          onRevisionRestored: _reloadContent,
        ),
      ),
    );
  }

  Future<void> _reloadContent() async {
    if (_entryId == null) return;
    final database = ref.read(appDatabaseProvider);
    final entry = await database.entriesDao.getEntryById(_entryId!);
    _titleController.text = entry.title ?? '';
    final json = entry.contentJson;
    if (json != null && json.isNotEmpty && json != '[]') {
      try {
        final doc = Document.fromJson(jsonDecode(json) as List);
        _quillController.document = doc;
        _quillController.moveCursorToEnd();
      } catch (_) {
        // Bad JSON — leave the existing document in place.
      }
    } else {
      // Empty / placeholder content: reset to a blank doc rather than
      // failing Document.fromJson([]) and silently keeping the old one.
      _quillController.document = Document();
      _quillController.moveCursorToEnd();
    }
    // The document object was replaced — the prior subscription pointed at
    // the old one and would never fire again. Resubscribe so subsequent
    // edits to the restored document still mark the entry dirty.
    if (_trackingChanges) {
      _lastTitleText = _titleController.text;
      _subscribeToDocChanges();
    }
    // A revision restore replaces unsaved-or-saved content; flag dirty so
    // the user is prompted to save the restored state explicitly.
    if (mounted) setState(() => _isDirty = true);
  }

  void _showVoiceNoteRecorder() {
    showModalBottomSheet(
      context: context,
      builder: (_) => VoiceNoteRecorder(
        onRecordingComplete: _handleVoiceNoteComplete,
      ),
    );
  }

  Future<void> _handleVoiceNoteComplete(
    VoiceNoteRecordingResult result,
    String transcript,
  ) async {
    if (_entryId == null) return;

    final cryptoStorage = ref.read(attachmentCryptoStorageProvider);
    final sourceBytes = await File(result.filePath).readAsBytes();
    final payload = await cryptoStorage.encryptAndStore(
      sourceBytes: sourceBytes,
      sourceFileName: result.fileName,
    );
    await File(result.filePath).delete();

    final database = ref.read(appDatabaseProvider);
    try {
      await database.voiceNotesDao.createVoiceNote(
        VoiceNotesCompanion.insert(
          entryId: _entryId!,
          fileName: result.fileName,
          encryptedPath: payload.encryptedPath,
          nonceBase64: payload.nonceBase64,
          keyReference: payload.keyReference,
          durationMs: result.durationMs,
          transcript: Value(transcript.isNotEmpty ? transcript : null),
        ),
      );
    } catch (_) {
      await cryptoStorage.deleteStoredFile(payload.encryptedPath);
      rethrow;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Voice note saved (${(result.durationMs / 1000).toStringAsFixed(0)}s)',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isDirty ? 'Edit entry •' : 'Edit entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _openVersionHistory,
            tooltip: 'Version history',
          ),
          if (_entryId != null)
            IconButton(
              key: const Key('entry-delete-button'),
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
              tooltip: 'Delete entry',
            ),
          IconButton(
            key: const Key('entry-save-button'),
            icon: Icon(_isDirty ? Icons.save : Icons.save_outlined),
            color: _isDirty ? theme.colorScheme.primary : null,
            onPressed: _isDirty ? _saveContent : null,
            tooltip: _isDirty ? 'Save' : 'No unsaved changes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Title field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              key: const Key('entry-title-field'),
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: InputBorder.none,
              ),
              style: Theme.of(context).textTheme.titleLarge,
              textInputAction: TextInputAction.next,
            ),
          ),
          const Divider(height: 1),
          // Rich formatting toolbar
          EditorToolbar(
            key: _toolbarKey,
            controller: _quillController,
            onInsertTable: _insertTable,
            onInsertCallout: _insertCallout,
          ),
          // Editor body
          Expanded(
            child: QuillEditor.basic(
              controller: _quillController,
              config: QuillEditorConfig(
                embedBuilders: _embedBuilders,
                placeholder: 'Write your entry…',
                contextMenuBuilder: _buildSelectionContextMenu,
              ),
            ),
          ),
          // 1–5 mood picker; persisted by _saveContent.
          if (_entryId != null)
            _MoodPickerRow(
              value: _mood,
              onChanged: (v) {
                if (v == _mood) return;
                setState(() {
                  _mood = v;
                  _isDirty = true;
                });
              },
            ),
          // Linked-from panel: inbound references to this entry.
          if (_entryId != null) _LinkedFromPanel(entryId: _entryId!),
          // Attachment tray with per-attachment lock toggle.
          if (_entryId != null) _AttachmentTray(entryId: _entryId!),
          // Bottom action bar
          _BottomActionBar(
            onAddAttachment: _handleAddAttachment,
            onRecordVoiceNote: _showVoiceNoteRecorder,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionContextMenu(
    BuildContext context,
    QuillRawEditorState state,
  ) {
    final buttonItems = <ContextMenuButtonItem>[];
    if (!_quillController.selection.isCollapsed) {
      buttonItems.addAll([
        _formatContextMenuItem('Bold', Attribute.bold),
        _formatContextMenuItem('Italic', Attribute.italic),
        _formatContextMenuItem('Underline', Attribute.underline),
        _formatContextMenuItem('Strike', Attribute.strikeThrough),
      ]);
    }
    buttonItems.addAll(state.contextMenuButtonItems);
    return TextFieldTapRegion(
      child: AdaptiveTextSelectionToolbar.buttonItems(
        buttonItems: buttonItems,
        anchors: _adjustedSelectionAnchors(state.contextMenuAnchors),
      ),
    );
  }

  /// When the selection's natural above-anchor would render the popup on top
  /// of the formatting toolbar, force flutter's fallback path so the popup
  /// flips below the selection instead.
  TextSelectionToolbarAnchors _adjustedSelectionAnchors(
    TextSelectionToolbarAnchors anchors,
  ) {
    final secondary = anchors.secondaryAnchor;
    if (secondary == null) return anchors;
    final toolbarBox =
        _toolbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (toolbarBox == null || !toolbarBox.attached) return anchors;
    final toolbarBottom =
        toolbarBox.localToGlobal(Offset.zero).dy + toolbarBox.size.height;
    // Approximate popup height; if the above-anchor isn't at least this far
    // below the toolbar, the popup would overlap it. Setting primaryAnchor.dy
    // to 0 makes flutter's "fits above" check fail, falling back to secondary.
    const popupHeight = 56.0;
    if (anchors.primaryAnchor.dy < toolbarBottom + popupHeight) {
      return TextSelectionToolbarAnchors(
        primaryAnchor: Offset(anchors.primaryAnchor.dx, 0),
        secondaryAnchor: secondary,
      );
    }
    return anchors;
  }

  ContextMenuButtonItem _formatContextMenuItem(
    String label,
    Attribute<dynamic> attribute,
  ) {
    return ContextMenuButtonItem(
      label: label,
      onPressed: () {
        final attrs = _quillController.getSelectionStyle().attributes;
        final isApplied = attrs.containsKey(attribute.key);
        _quillController
          ..skipRequestKeyboard = !attribute.isInline
          ..formatSelection(
            isApplied ? Attribute.clone(attribute, null) : attribute,
          );
        ContextMenuController.removeAny();
      },
    );
  }

  Future<void> _handleAddAttachment() async {
    final service = ref.read(appPermissionsServiceProvider);
    final permission = await service.getPermission(
      AppPermissionId.attachmentImport,
    );

    if (!mounted) return;

    if (permission.status == AppPermissionState.denied ||
        permission.status == AppPermissionState.permanentlyDenied) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Allow attachment import?'),
          content: const Text(
            'This app needs permission to access your files.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      if (shouldContinue != true || !mounted) return;

      final newState = await service.requestPermission(
        AppPermissionId.attachmentImport,
      );

      if (!mounted) return;

      if (newState == AppPermissionState.permanentlyDenied) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Attachment access blocked'),
            content: const Text(
              'Permission was permanently denied. Please enable it in system settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  service.openSystemSettings();
                  Navigator.pop(context);
                },
                child: const Text('Open system settings'),
              ),
            ],
          ),
        );
        return;
      }

      if (newState != AppPermissionState.granted) return;
    }

    final picker = ref.read(attachmentPickerServiceProvider);
    await picker.pickAttachment();
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.onAddAttachment,
    required this.onRecordVoiceNote,
  });

  final VoidCallback onAddAttachment;
  final VoidCallback onRecordVoiceNote;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            key: const Key('entry-attachment-add-button'),
            icon: const Icon(Icons.attach_file),
            onPressed: onAddAttachment,
            tooltip: 'Add attachment',
          ),
          IconButton(
            key: const Key('entry-voice-note-button'),
            icon: const Icon(Icons.mic_outlined),
            onPressed: onRecordVoiceNote,
            tooltip: 'Record voice note',
          ),
        ],
      ),
    );
  }
}

/// Shows entries that link to the current entry via vault-internal
/// `[[entry:N]]` syntax. Loaded once on mount; the editor's save path can
/// refresh it via [_LinkedFromPanelState.refresh] if the panel is exposed
/// later.
///
/// Uses a one-shot DAO call rather than a watcher because drift's stream
/// cleanup schedules a Timer that leaks past widget disposal in tests.
class _LinkedFromPanel extends ConsumerStatefulWidget {
  const _LinkedFromPanel({required this.entryId});

  final int entryId;

  @override
  ConsumerState<_LinkedFromPanel> createState() => _LinkedFromPanelState();
}

class _LinkedFromPanelState extends ConsumerState<_LinkedFromPanel> {
  List<Backlink>? _links;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _LinkedFromPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entryId != widget.entryId) _load();
  }

  Future<void> _load() async {
    final db = ref.read(appDatabaseProvider);
    final links =
        await db.backlinksDao.getBacklinksForEntryTarget(widget.entryId);
    if (mounted) setState(() => _links = links);
  }

  @override
  Widget build(BuildContext context) {
    final links = _links ?? const <Backlink>[];
    if (links.isEmpty) return const SizedBox.shrink();
    return Container(
      key: const Key('entry-linked-from-panel'),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Linked from',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          for (final link in links)
            _LinkedFromRow(sourceEntryId: link.sourceEntryId),
        ],
      ),
    );
  }
}

class _LinkedFromRow extends ConsumerWidget {
  const _LinkedFromRow({required this.sourceEntryId});

  final int sourceEntryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return FutureBuilder<Entry>(
      future: db.entriesDao.getEntryById(sourceEntryId),
      builder: (context, snapshot) {
        final entry = snapshot.data;
        final title = entry?.title?.isNotEmpty == true
            ? entry!.title!
            : 'Entry #$sourceEntryId';
        return InkWell(
          key: Key('linked-from-row-$sourceEntryId'),
          onTap: entry == null
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => EntryEditorScreen(
                        journalId: entry.journalId,
                        entryId: entry.id,
                      ),
                    ),
                  ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.link, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(title)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 1–5 mood rating row with discrete buttons for each level. Tapping the
/// active level clears the mood.
class _MoodPickerRow extends StatelessWidget {
  const _MoodPickerRow({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  static const _labels = {1: '😞', 2: '🙁', 3: '😐', 4: '🙂', 5: '😄'};

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('entry-mood-picker'),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Text(
            'Mood',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final level in _labels.keys)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        key: Key('entry-mood-$level'),
                        label: Text('${_labels[level]} $level'),
                        selected: value == level,
                        onSelected: (_) =>
                            onChanged(value == level ? null : level),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Per-attachment tray with lock/unlock action and decrypt-to-temp open.
///
/// Locked attachments require re-auth (device biometric / PIN) before they
/// can be opened — gated through [BiometricAuthenticator] so the user gets
/// the same prompt the app-lock gate uses.
class _AttachmentTray extends ConsumerStatefulWidget {
  const _AttachmentTray({required this.entryId});

  final int entryId;

  @override
  ConsumerState<_AttachmentTray> createState() => _AttachmentTrayState();
}

class _AttachmentTrayState extends ConsumerState<_AttachmentTray> {
  List<Attachment>? _attachments;
  Map<int, bool> _lockedById = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _AttachmentTray oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entryId != widget.entryId) _load();
  }

  Future<void> _load() async {
    final db = ref.read(appDatabaseProvider);
    final attachments =
        await db.attachmentsDao.getAttachmentsForEntry(widget.entryId);
    final lockService = ref.read(attachmentLockServiceProvider);
    final lockedMap = <int, bool>{
      for (final a in attachments) a.id: await lockService.isLocked(a.id),
    };
    if (mounted) {
      setState(() {
        _attachments = attachments;
        _lockedById = lockedMap;
      });
    }
  }

  Future<void> _toggleLock(Attachment a) async {
    final svc = ref.read(attachmentLockServiceProvider);
    if (_lockedById[a.id] ?? false) {
      await svc.removeLock(a.id);
    } else {
      await svc.lockAttachment(attachmentId: a.id);
    }
    await _load();
  }

  Future<void> _open(Attachment a) async {
    if (_lockedById[a.id] ?? false) {
      final auth = ref.read(biometricAuthenticatorProvider);
      final result = await auth.authenticate(
        reason: 'Unlock "${a.fileName}"',
      );
      if (result != BiometricAuthResult.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication required.')),
          );
        }
        return;
      }
    }
    final openService = ref.read(attachmentOpenServiceProvider);
    try {
      await openService.prepareOpen(a);
    } on AttachmentOpenException catch (error) {
      if (!mounted) return;
      await _showOpenFailureDialog(a, error.failure);
    }
  }

  Future<void> _showOpenFailureDialog(
    Attachment a,
    AttachmentOpenFailure failure,
  ) async {
    final (title, retry) = switch (failure) {
      AttachmentOpenFailure.noCompatibleApp => (
          'No compatible app found',
          true,
        ),
      AttachmentOpenFailure.decryptFailed => ('Could not decrypt attachment', true),
      AttachmentOpenFailure.fileNotFound => ('Attachment file is missing', false),
      AttachmentOpenFailure.permissionDenied => (
          'Permission required to open attachment',
          true,
        ),
    };
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        actions: [
          if (failure == AttachmentOpenFailure.noCompatibleApp)
            TextButton(
              key: Key('attachment-open-with-${a.id}'),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Open with...'),
            ),
          if (retry)
            TextButton(
              key: Key('attachment-retry-${a.id}'),
              onPressed: () {
                Navigator.pop(dialogContext);
                _open(a);
              },
              child: const Text('Retry'),
            ),
          TextButton(
            key: Key('attachment-close-${a.id}'),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attachments = _attachments;
    if (attachments == null || attachments.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      key: const Key('entry-attachment-tray'),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attachments',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          for (final a in attachments)
            ListTile(
              key: Key('attachment-tile-${a.id}'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                (_lockedById[a.id] ?? false)
                    ? Icons.lock
                    : Icons.attach_file,
              ),
              title: Text(a.fileName),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: Key('attachment-lock-toggle-${a.id}'),
                    icon: Icon(
                      (_lockedById[a.id] ?? false)
                          ? Icons.lock_open
                          : Icons.lock_outline,
                    ),
                    tooltip: (_lockedById[a.id] ?? false)
                        ? 'Remove attachment lock'
                        : 'Lock attachment',
                    onPressed: () => _toggleLock(a),
                  ),
                  IconButton(
                    key: Key('open-attachment-${a.id}'),
                    icon: const Icon(Icons.open_in_new),
                    tooltip: 'Open attachment',
                    onPressed: () => _open(a),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
