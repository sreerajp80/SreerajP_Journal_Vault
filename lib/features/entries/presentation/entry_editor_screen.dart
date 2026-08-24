import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/links/vault_backlink_parser.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/core/theme/typography_controller.dart';
import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_models.dart';
import 'package:sreerajp_journal_vault/features/attachments/presentation/attachment_viewer_screen.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_picker_service.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/callout_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing/drawing_canvas_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/editor_markdown_shortcuts.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/editor_stats_bar.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/editor_toolbar.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/image_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/inline_image_store.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/table_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/voice_note_recorder.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/version_history_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/entry_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/image_edit_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/ocr_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/voice_note_service.dart';
import 'package:sreerajp_journal_vault/features/entries/templates/entry_templates.dart';
import 'package:sreerajp_journal_vault/features/entries/templates/template_token_engine.dart';
import 'package:sreerajp_journal_vault/features/insights/providers/insights_providers.dart';
import 'package:sreerajp_journal_vault/features/export/export_strings.dart';
import 'package:sreerajp_journal_vault/features/export/presentation/export_screen.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';
import 'package:sreerajp_journal_vault/features/smart_tags/presentation/smart_tag_chip_bar.dart';
import 'package:intl/intl.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/time_capsule_seal_dialog.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/time_capsule_sealed_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/time_capsule_providers.dart';
import 'package:sreerajp_journal_vault/features/permissions/domain/app_permission_models.dart';
import 'package:sreerajp_journal_vault/features/permissions/providers/permissions_providers.dart';
import 'package:sreerajp_journal_vault/features/security/providers/security_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class EntryEditorScreen extends ConsumerStatefulWidget {
  const EntryEditorScreen({
    super.key,
    required this.journalId,
    this.entryId,
    this.initialTemplateId,
    this.initialTemplate,
    this.initialTitle,
    this.initialPlainText,
    this.initialAttachments,
    this.imagePicker,
  });

  final int journalId;

  /// If provided, opens an existing entry for editing. If null, creates a new one.
  final int? entryId;

  /// When creating a new entry, the template to seed the title and content
  /// with. Null means start blank.
  final EntryTemplateId? initialTemplateId;

  /// Explicit template instance (built-in or custom user-created).
  final EntryTemplate? initialTemplate;

  /// Optional initial title (e.g. from inbound share).
  final String? initialTitle;

  /// Optional initial plain text (e.g. from inbound share).
  final String? initialPlainText;

  /// Optional initial attachments to import immediately into this new entry.
  final List<PickedAttachmentData>? initialAttachments;

  /// Optional image picker for tests.
  final ImagePicker? imagePicker;

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

  /// Decrypts inline images to temp files for this screen, and deletes them
  /// again when the screen closes.
  late final InlineImageStore _imageStore;

  /// Custom embed builders for tables, callouts and inline images.
  late final List<EmbedBuilder> _embedBuilders;

  /// Bumped whenever an attachment is added, so the tray reloads. The tray
  /// reads the database once on mount; without this an image inserted into the
  /// body would not appear in the list below until the screen was reopened.
  int _attachmentRefreshToken = 0;

  /// Subscribes to document delta events. We don't use
  /// [QuillController.addListener] for the dirty flag because that fires on
  /// selection moves too — tapping into the editor without typing would
  /// otherwise mark the entry dirty.
  StreamSubscription<DocChange>? _docChangeSub;

  /// Handles real-time Markdown prefix expansions.
  final EditorMarkdownShortcuts _markdownShortcuts = EditorMarkdownShortcuts();

  /// Whether distraction-free full-screen writing mode is enabled.
  bool _isDistractionFree = false;

  /// Whether focus paragraph dim mode is enabled.
  bool _isFocusParagraph = false;

  /// Current auto-save status.
  EditorSaveStatus _saveStatus = EditorSaveStatus.saved;

  /// Timestamp of the last successful save.
  DateTime? _lastSavedTime;

  /// Debounce timer for background auto-saving.
  Timer? _autoSaveTimer;

  /// Live word count.
  int _wordCount = 0;

  /// Live character count.
  int _characterCount = 0;

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
    _imageStore = buildInlineImageStore(ref);
    _embedBuilders = [
      TableEmbedBuilder(),
      CalloutEmbedBuilder(),
      VaultImageEmbedBuilder(store: _imageStore),
      DrawingEmbedBuilder(store: _imageStore, onEditDrawing: _editDrawing),
    ];
    if (widget.entryId != null) {
      _loadEntry(widget.entryId!);
    } else {
      _createEntry();
    }
  }

  void _updateStats() {
    final text = _quillController.document.toPlainText();
    final words = EditorStatsBar.countWords(text);
    final chars = EditorStatsBar.countCharacters(text);
    if (words != _wordCount || chars != _characterCount) {
      if (mounted) {
        setState(() {
          _wordCount = words;
          _characterCount = chars;
        });
      }
    }
  }

  Future<void> _loadEntry(int id) async {
    final database = ref.read(appDatabaseProvider);
    final entry = await database.entriesDao.getEntryById(id);
    if (!mounted) return;
    _titleController.text = entry.title ?? '';
    if (entry.contentJson != null &&
        entry.contentJson!.isNotEmpty &&
        entry.contentJson != '[]') {
      try {
        final doc = Document.fromJson(jsonDecode(entry.contentJson!) as List);
        _quillController.document = doc;
        _quillController.moveCursorToEnd();
      } catch (_) {
        // Ignore parse errors — start with empty doc.
      }
    }
    final existingMood = await ref
        .read(insightsServiceProvider)
        .getMoodForEntry(id);
    if (!mounted) return;
    setState(() {
      _entryId = id;
      _mood = existingMood?.mood;
    });
    _updateStats();
    _attachChangeListeners();
  }

  Future<void> _createEntry() async {
    final selected =
        widget.initialTemplate ?? templateFor(widget.initialTemplateId);

    String resolvedTitle = TemplateTokenEngine.resolveTokens(
      selected.defaultTitle,
    );
    String resolvedContentJson = TemplateTokenEngine.resolveContentJsonTokens(
      selected.contentJson,
    );

    if (widget.initialTitle != null && widget.initialTitle!.isNotEmpty) {
      resolvedTitle = widget.initialTitle!;
    }

    // Pre-fill the editor with the template content if one was provided.
    if (selected.id != EntryTemplateId.blank || selected.isCustom) {
      _titleController.text = resolvedTitle;
      if (resolvedContentJson != '[]') {
        try {
          final doc = Document.fromJson(
            jsonDecode(resolvedContentJson) as List,
          );
          _quillController.document = doc;
          _quillController.moveCursorToEnd();
        } catch (_) {
          /* fall through to empty doc */
        }
      }
    } else {
      _titleController.text = resolvedTitle;
    }

    if (widget.initialPlainText != null &&
        widget.initialPlainText!.isNotEmpty) {
      _quillController.document = Document()
        ..insert(0, widget.initialPlainText!);
      resolvedContentJson = jsonEncode(
        _quillController.document.toDelta().toJson(),
      );
    }

    final database = ref.read(appDatabaseProvider);
    final id = await database.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: widget.journalId,
        title: Value(resolvedTitle),
        contentJson: Value(resolvedContentJson),
      ),
    );

    if (widget.initialAttachments != null &&
        widget.initialAttachments!.isNotEmpty) {
      for (final picked in widget.initialAttachments!) {
        try {
          final attachmentId = await ref
              .read(attachmentImportServiceProvider)
              .importToEntry(database: database, entryId: id, picked: picked);
          if (picked.mimeType.startsWith('image/')) {
            final embed = VaultImageEmbed.create(
              attachmentId: attachmentId,
              fileName: picked.fileName,
            );
            final index = _quillController.document.length - 1;
            _quillController.replaceText(index, 0, embed, null);
            _quillController.replaceText(index + 1, 0, '\n', null);
          }
        } catch (_) {}
      }
      final updatedJson = jsonEncode(
        _quillController.document.toDelta().toJson(),
      );
      await database.entriesDao.updateEntryById(
        id,
        EntriesCompanion(contentJson: Value(updatedJson)),
      );
    }

    if (!mounted) return;
    setState(() => _entryId = id);
    _updateStats();
    _attachChangeListeners();
  }

  Future<void> _saveAsTemplate() async {
    final l10n = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    final contentJson = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );

    final nameController = TextEditingController(
      text: title.isNotEmpty ? title : '',
    );
    final descController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.templateSaveAsTemplateTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.templateSaveAsTemplateDesc),
            const SizedBox(height: 12),
            TextField(
              key: const Key('save-as-template-name-field'),
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.templateNameLabel,
                hintText: l10n.templateNameHint,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('save-as-template-desc-field'),
              controller: descController,
              decoration: InputDecoration(
                labelText: l10n.templateDescriptionLabel,
                hintText: l10n.templateDescriptionHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const Key('confirm-save-as-template-button'),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(dialogCtx).pop(true);
              }
            },
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final name = nameController.text.trim();
      final desc = descController.text.trim();
      final db = ref.read(appDatabaseProvider);
      await db.userTemplatesDao.createUserTemplate(
        UserTemplatesCompanion.insert(
          name: name,
          description: Value(desc.isEmpty ? null : desc),
          defaultTitle: Value(title.isEmpty ? null : title),
          contentJson: contentJson,
        ),
      );
      ref.invalidate(allUserTemplatesProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.templateSaveSuccess)));
      }
    }
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
    _docChangeSub = _quillController.document.changes.listen((change) {
      _markdownShortcuts.handleDocChange(_quillController, change);
      _updateStats();
      _markDirty();
    });
  }

  void _handleTitleChange() {
    if (_titleController.text == _lastTitleText) return;
    _lastTitleText = _titleController.text;
    _markDirty();
  }

  void _markDirty() {
    _autoSaveTimer?.cancel();
    if (!_isDirty || _saveStatus != EditorSaveStatus.unsaved) {
      if (!mounted) return;
      setState(() {
        _isDirty = true;
        _saveStatus = EditorSaveStatus.unsaved;
      });
    }
    // Schedule a background auto-save 2.5s after editing stops.
    _autoSaveTimer = Timer(const Duration(milliseconds: 2500), () {
      _saveContent(isAutoSave: true);
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    if (_trackingChanges) {
      _titleController.removeListener(_handleTitleChange);
    }
    _docChangeSub?.cancel();
    // Deletes the decrypted copies of every inline image this screen showed.
    unawaited(_imageStore.dispose());
    _quillController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  /// Saves the current content and creates a revision snapshot.
  Future<void> _saveContent({bool isAutoSave = false}) async {
    if (_entryId == null) return;
    if (!isAutoSave) {
      _autoSaveTimer?.cancel();
    }

    if (mounted) {
      setState(() => _saveStatus = EditorSaveStatus.saving);
    }

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
    await database.backlinksDao.replaceBacklinksForEntry(_entryId!, targets);

    // Persist the mood rating if the user picked one. Clear when nulled.
    final mood = _mood;
    if (mood != null) {
      await ref
          .read(insightsServiceProvider)
          .setMood(entryId: _entryId!, mood: mood);
    } else {
      await ref.read(insightsServiceProvider).deleteMood(_entryId!);
    }

    if (!mounted) return;
    setState(() {
      _isDirty = false;
      _saveStatus = EditorSaveStatus.saved;
      _lastSavedTime = DateTime.now();
    });

    if (!isAutoSave) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            key: const Key('entry-saved-snackbar'),
            content: Text(AppLocalizations.of(context).entrySaved),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  Future<void> _confirmDelete() async {
    if (_entryId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(dialogContext).entryDeleteTitle),
        content: Text(AppLocalizations.of(dialogContext).entryDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.of(dialogContext).commonCancel),
          ),
          TextButton(
            key: const Key('entry-delete-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppLocalizations.of(dialogContext).commonDelete),
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
      final embed = TableEmbed.create(rowCount: size.rows, colCount: size.cols);
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
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(l10n.editorInsertTable),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.entryTableRows,
                  helperText: l10n.entryTableDimensionHelp,
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: '3'),
                onChanged: (v) => rows = parseDim(v),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.entryTableColumns,
                  helperText: l10n.entryTableDimensionHelp,
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: '3'),
                onChanged: (v) => cols = parseDim(v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, (rows: rows, cols: cols)),
              child: Text(l10n.commonInsert),
            ),
          ],
        );
      },
    );
  }

  /// The callout `type` is a document code, not text for the user. Map it to a
  /// translated label rather than capitalising the code.
  String _calloutLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case 'info':
        return l10n.entryCalloutInfo;
      case 'tip':
        return l10n.entryCalloutTip;
      case 'warning':
        return l10n.entryCalloutWarning;
      case 'important':
        return l10n.entryCalloutImportant;
      default:
        return type;
    }
  }

  void _insertCallout() async {
    final style = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return SimpleDialog(
          title: Text(l10n.entryCalloutTypeTitle),
          children: [
            for (final type in ['info', 'tip', 'warning', 'important'])
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, type),
                child: Row(
                  children: [
                    Icon(_calloutIcon(type), color: _calloutColor(type)),
                    const SizedBox(width: 12),
                    Text(_calloutLabel(l10n, type)),
                  ],
                ),
              ),
          ],
        );
      },
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

  /// Opens the export screen for this entry.
  ///
  /// Unsaved edits are saved first, so what is exported is what the user can
  /// see on screen. Exporting a stale copy of an entry the user has just
  /// changed would be a quiet, confusing kind of wrong.
  Future<void> _openExport() async {
    if (_entryId == null) return;

    if (_isDirty) {
      await _saveContent();
      if (!mounted) return;
    }

    final journal = await ref
        .read(appDatabaseProvider)
        .journalsDao
        .getJournalById(widget.journalId);
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ExportScreen(
          journalId: widget.journalId,
          journalTitle: journal.title,
          entryId: _entryId,
          entryTitle: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
        ),
      ),
    );
  }

  Future<void> _sealAsTimeCapsule() async {
    if (_entryId == null) return;
    if (_isDirty) {
      await _saveContent();
      if (!mounted) return;
    }

    final config = await showDialog<TimeCapsuleSealConfig>(
      context: context,
      builder: (_) => const TimeCapsuleSealDialog(),
    );

    if (config == null || !mounted) return;

    try {
      final service = ref.read(timeCapsuleServiceProvider);
      await service.sealEntry(
        entryId: _entryId!,
        unlockDate: config.unlockDate,
        teaserMessage: config.teaserMessage,
      );

      if (!mounted) return;

      final l10n = AppLocalizations.of(context);
      final formattedDate = DateFormat.yMMMMd().format(config.unlockDate);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const Key('time-capsule-sealed-snackbar'),
          content: Text(l10n.timeCapsuleSealedSuccess(formattedDate)),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => TimeCapsuleSealedScreen(
            entryId: _entryId!,
            journalId: widget.journalId,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to seal time capsule: $e')),
        );
      }
    }
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
    _updateStats();
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
      builder: (_) =>
          VoiceNoteRecorder(onRecordingComplete: _handleVoiceNoteComplete),
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
            AppLocalizations.of(context).entryVoiceNoteSaved(
              (result.durationMs / 1000).toStringAsFixed(0),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final typography = ref.watch(typographyProvider);
    final baseStyles = DefaultStyles.getInstance(context);
    final entryBodyStyle = typography.toTextStyle(
      color: theme.colorScheme.onSurface,
    );
    final customStyles = baseStyles.merge(
      DefaultStyles(
        paragraph: DefaultTextBlockStyle(
          entryBodyStyle,
          const HorizontalSpacing(0, 0),
          const VerticalSpacing(0, 6),
          const VerticalSpacing(0, 0),
          null,
        ),
      ),
    );

    Widget editorContent = DefaultTextStyle(
      style: entryBodyStyle,
      child: QuillEditor.basic(
        controller: _quillController,
        config: QuillEditorConfig(
          embedBuilders: _embedBuilders,
          customStyles: customStyles,
          placeholder: 'Write your entry…',
          contextMenuBuilder: _buildSelectionContextMenu,
        ),
      ),
    );

    if (_isFocusParagraph) {
      editorContent = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.15,
          ),
          border: Border(
            left: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: editorContent,
      );
    }

    if (_isDistractionFree) {
      return Scaffold(
        key: const Key('distraction-free-scaffold'),
        body: SafeArea(
          child: Column(
            children: [
              // Minimal distraction-free top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      key: const Key('distraction-free-exit-button'),
                      icon: const Icon(Icons.fullscreen_exit),
                      tooltip: l10n.entryDistractionFreeExit,
                      onPressed: () =>
                          setState(() => _isDistractionFree = false),
                    ),
                    const Spacer(),
                    IconButton(
                      key: const Key('distraction-free-focus-button'),
                      icon: Icon(
                        _isFocusParagraph
                            ? Icons.filter_center_focus
                            : Icons.center_focus_weak_outlined,
                      ),
                      color: _isFocusParagraph
                          ? theme.colorScheme.primary
                          : null,
                      tooltip: _isFocusParagraph
                          ? l10n.entryFocusParagraphOn
                          : l10n.entryFocusParagraphOff,
                      onPressed: () => setState(
                        () => _isFocusParagraph = !_isFocusParagraph,
                      ),
                    ),
                    IconButton(
                      key: const Key('distraction-free-save-button'),
                      icon: Icon(_isDirty ? Icons.save : Icons.save_outlined),
                      color: _isDirty ? theme.colorScheme.primary : null,
                      onPressed: _isDirty ? _saveContent : null,
                      tooltip: _isDirty
                          ? l10n.entrySaveTooltip
                          : l10n.entryNoUnsavedChanges,
                    ),
                  ],
                ),
              ),
              // Title field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: TextField(
                  key: const Key('entry-title-field'),
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.entryTitleLabel,
                    border: InputBorder.none,
                  ),
                  style: theme.textTheme.titleLarge,
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
                onInsertImage: _entryId == null ? null : _insertImage,
                onInsertDrawing: _entryId == null ? null : _insertDrawing,
                onScanText: _scanTextFromPhoto,
                onToggleFocusParagraph: () =>
                    setState(() => _isFocusParagraph = !_isFocusParagraph),
                isFocusParagraph: _isFocusParagraph,
                onToggleDistractionFree: () =>
                    setState(() => _isDistractionFree = !_isDistractionFree),
                isDistractionFree: _isDistractionFree,
              ),
              // Editor body
              Expanded(child: editorContent),
              // Live word and character stats bar
              EditorStatsBar(
                wordCount: _wordCount,
                characterCount: _characterCount,
                saveStatus: _saveStatus,
                lastSavedTime: _lastSavedTime,
                compact: true,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isDirty ? l10n.entryEditTitleDirty : l10n.entryEditTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _openVersionHistory,
            tooltip: l10n.entryVersionHistoryTooltip,
          ),
          // Export is offered only once the entry exists, because there is
          // nothing to write out before the first save.
          if (_entryId != null)
            IconButton(
              key: const Key('entry-export-button'),
              icon: const Icon(Icons.ios_share),
              onPressed: _openExport,
              tooltip: ExportStrings.exportEntryTooltip,
            ),
          if (_entryId != null)
            IconButton(
              key: const Key('entry-seal-time-capsule-button'),
              icon: const Icon(Icons.hourglass_top_rounded),
              tooltip: l10n.timeCapsuleActionSeal,
              onPressed: _sealAsTimeCapsule,
            ),
          // Focus paragraph dim mode toggle in AppBar
          IconButton(
            key: const Key('entry-appbar-focus-toggle'),
            icon: Icon(
              _isFocusParagraph
                  ? Icons.filter_center_focus
                  : Icons.center_focus_weak_outlined,
            ),
            color: _isFocusParagraph ? theme.colorScheme.primary : null,
            tooltip: _isFocusParagraph
                ? l10n.entryFocusParagraphOn
                : l10n.entryFocusParagraphOff,
            onPressed: () =>
                setState(() => _isFocusParagraph = !_isFocusParagraph),
          ),
          // Distraction-free mode toggle in AppBar
          IconButton(
            key: const Key('entry-appbar-distraction-free-toggle'),
            icon: const Icon(Icons.fullscreen),
            tooltip: l10n.entryDistractionFreeEnter,
            onPressed: () => setState(() => _isDistractionFree = true),
          ),
          if (_entryId != null)
            IconButton(
              key: const Key('entry-delete-button'),
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
              tooltip: l10n.entryDeleteTooltip,
            ),
          IconButton(
            key: const Key('entry-save-as-template-button'),
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: l10n.templateSaveAsTemplate,
            onPressed: _saveAsTemplate,
          ),
          IconButton(
            key: const Key('entry-save-button'),
            icon: Icon(_isDirty ? Icons.save : Icons.save_outlined),
            color: _isDirty ? theme.colorScheme.primary : null,
            onPressed: _isDirty ? _saveContent : null,
            tooltip: _isDirty
                ? l10n.entrySaveTooltip
                : l10n.entryNoUnsavedChanges,
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
              decoration: InputDecoration(
                labelText: l10n.entryTitleLabel,
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
            // Offered only once the entry exists — an inline image needs a row
            // to hang its attachment off.
            onInsertImage: _entryId == null ? null : _insertImage,
            onInsertDrawing: _entryId == null ? null : _insertDrawing,
            onScanText: _scanTextFromPhoto,
            onToggleFocusParagraph: () =>
                setState(() => _isFocusParagraph = !_isFocusParagraph),
            isFocusParagraph: _isFocusParagraph,
            onToggleDistractionFree: () =>
                setState(() => _isDistractionFree = !_isDistractionFree),
            isDistractionFree: _isDistractionFree,
          ),
          // Editor body
          Expanded(child: editorContent),
          // Word & Character count + Auto-save indicator bar
          EditorStatsBar(
            wordCount: _wordCount,
            characterCount: _characterCount,
            saveStatus: _saveStatus,
            lastSavedTime: _lastSavedTime,
          ),
          // Smart tag suggestions for what has been written so far. Reads the
          // live document rather than the saved row, so suggestions track the
          // text as it is typed. Renders nothing when there is no match.
          if (_entryId != null)
            SmartTagChipBar(
              entryId: _entryId!,
              plainText: _quillController.document.toPlainText(),
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
          if (_entryId != null)
            _AttachmentTray(
              entryId: _entryId!,
              refreshToken: _attachmentRefreshToken,
            ),
          // Bottom action bar
          _BottomActionBar(
            onAddAttachment: _handleAddAttachment,
            onRecordVoiceNote: _showVoiceNoteRecorder,
            onScanText: _scanTextFromPhoto,
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
    if (!await _ensureAttachmentPermission()) return;
    final picker = ref.read(attachmentPickerServiceProvider);
    await picker.pickAttachment();
  }

  /// Makes sure the app may read files, asking for the permission if needed.
  ///
  /// Returns true when the caller can go ahead and open the picker. Shared by
  /// the attachment button and the inline-image button so both ask in exactly
  /// the same way.
  Future<bool> _ensureAttachmentPermission() async {
    final service = ref.read(appPermissionsServiceProvider);
    final permission = await service.getPermission(
      AppPermissionId.attachmentImport,
    );

    if (!mounted) return false;

    if (permission.status == AppPermissionState.denied ||
        permission.status == AppPermissionState.permanentlyDenied) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final l10n = AppLocalizations.of(dialogContext);
          return AlertDialog(
            title: Text(l10n.entryPermissionTitle),
            content: Text(l10n.entryPermissionBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.commonContinue),
              ),
            ],
          );
        },
      );

      if (shouldContinue != true || !mounted) return false;

      final newState = await service.requestPermission(
        AppPermissionId.attachmentImport,
      );

      if (!mounted) return false;

      if (newState == AppPermissionState.permanentlyDenied) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) {
            final l10n = AppLocalizations.of(dialogContext);
            return AlertDialog(
              title: Text(l10n.entryPermissionBlockedTitle),
              content: Text(l10n.entryPermissionBlockedBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.commonCancel),
                ),
                TextButton(
                  onPressed: () {
                    service.openSystemSettings();
                    Navigator.pop(dialogContext);
                  },
                  child: Text(l10n.commonOpenSystemSettings),
                ),
              ],
            );
          },
        );
        return false;
      }

      if (newState != AppPermissionState.granted) return false;
    }

    return true;
  }

  /// Picks an image and puts it into the body of the entry.
  ///
  /// The picture is imported exactly like any other attachment — encrypted,
  /// with a row in `Attachments` — and the embed holds only that row's id. So
  /// an inline image is backed up, synced and exported by the paths that
  /// already exist, and the document JSON never carries image bytes.
  Future<void> _insertImage() async {
    if (_entryId == null) return;
    if (!await _ensureAttachmentPermission()) return;

    final picked = await ref
        .read(attachmentPickerServiceProvider)
        .pickAttachment();
    if (picked == null || !mounted) return;

    if (!picked.mimeType.startsWith('image/')) {
      _showMessage(AppLocalizations.of(context).entryNotAnImage);
      return;
    }

    final int attachmentId;
    try {
      attachmentId = await ref
          .read(attachmentImportServiceProvider)
          .importToEntry(
            database: ref.read(appDatabaseProvider),
            entryId: _entryId!,
            picked: picked,
          );
    } catch (_) {
      // The import service has already removed the encrypted file it wrote, so
      // there is nothing left behind to clean up here.
      if (mounted) {
        _showMessage(AppLocalizations.of(context).entryImageAddFailed);
      }
      return;
    }

    if (!mounted) return;

    final embed = VaultImageEmbed.create(
      attachmentId: attachmentId,
      fileName: picked.fileName,
    );
    final index = _quillController.selection.baseOffset;
    // Insert the embed, then a trailing newline — without it an image at the
    // end of the document has no editable line after it and the cursor gets
    // trapped, the same as for tables and callouts above.
    _quillController.replaceText(index, 0, embed, null);
    _quillController.replaceText(
      index + 1,
      0,
      '\n',
      TextSelection.collapsed(offset: index + 2),
    );

    // The picture is also a normal attachment, so the tray below has to know.
    setState(() => _attachmentRefreshToken++);
  }

  /// Opens the drawing canvas, saves the sketch as an encrypted attachment,
  /// and embeds it into the entry.
  Future<void> _insertDrawing() async {
    if (_entryId == null) return;

    final result = await Navigator.of(context).push<DrawingCanvasResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const DrawingCanvasScreen(),
      ),
    );

    if (result == null || !mounted) return;

    final fileName = 'drawing_${DateTime.now().millisecondsSinceEpoch}.png';
    final picked = PickedAttachmentData(
      fileName: fileName,
      bytes: result.pngBytes,
      mimeType: 'image/png',
    );

    final int attachmentId;
    try {
      attachmentId = await ref
          .read(attachmentImportServiceProvider)
          .importToEntry(
            database: ref.read(appDatabaseProvider),
            entryId: _entryId!,
            picked: picked,
          );
    } catch (_) {
      if (mounted) {
        _showMessage(AppLocalizations.of(context).drawingSaveError);
      }
      return;
    }

    if (!mounted) return;

    final embed = DrawingEmbed.create(
      attachmentId: attachmentId,
      fileName: fileName,
      strokeJson: result.strokeJson,
    );

    final index = _quillController.selection.baseOffset;
    _quillController.replaceText(index, 0, embed, null);
    _quillController.replaceText(
      index + 1,
      0,
      '\n',
      TextSelection.collapsed(offset: index + 2),
    );

    setState(() {
      _attachmentRefreshToken++;
      _isDirty = true;
    });
  }

  /// Re-opens an existing drawing in the canvas screen to edit its vector strokes.
  Future<void> _editDrawing(DrawingEmbedData data, int documentOffset) async {
    if (_entryId == null) return;

    final result = await Navigator.of(context).push<DrawingCanvasResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => DrawingCanvasScreen(initialStrokeJson: data.strokeJson),
      ),
    );

    if (result == null || !mounted) return;

    final fileName = data.fileName.isNotEmpty
        ? data.fileName
        : 'drawing_${DateTime.now().millisecondsSinceEpoch}.png';

    final picked = PickedAttachmentData(
      fileName: fileName,
      bytes: result.pngBytes,
      mimeType: 'image/png',
    );

    final int newAttachmentId;
    try {
      newAttachmentId = await ref
          .read(attachmentImportServiceProvider)
          .importToEntry(
            database: ref.read(appDatabaseProvider),
            entryId: _entryId!,
            picked: picked,
          );
    } catch (_) {
      if (mounted) {
        _showMessage(AppLocalizations.of(context).drawingSaveError);
      }
      return;
    }

    if (!mounted) return;

    final newEmbed = DrawingEmbed.create(
      attachmentId: newAttachmentId,
      fileName: fileName,
      widthFactor: data.widthFactor,
      strokeJson: result.strokeJson,
    );

    _quillController.replaceText(
      documentOffset,
      1,
      newEmbed,
      null,
      ignoreFocus: true,
    );

    // Clean up old attachment row and file if different
    if (data.attachmentId > 0 && data.attachmentId != newAttachmentId) {
      try {
        final db = ref.read(appDatabaseProvider);
        final oldAttachment = await db.attachmentsDao.getAttachmentById(
          data.attachmentId,
        );
        await db.attachmentsDao.deleteAttachmentById(data.attachmentId);
        final crypto = ref.read(attachmentCryptoStorageProvider);
        await crypto.deleteStoredFile(oldAttachment.encryptedPath);
      } catch (_) {}
    }

    setState(() {
      _attachmentRefreshToken++;
      _isDirty = true;
    });
  }

  Future<void> _scanTextFromPhoto() async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.entryEditorScanSourceCamera),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.entryEditorScanSourceGallery),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picker = widget.imagePicker ?? ImagePicker();
    final XFile? pickedFile;
    try {
      pickedFile = await picker.pickImage(source: source);
    } catch (e, stackTrace) {
      AppLogger.error(
        'EntryEditorScreen: image pick failed',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) _showMessage(l10n.entryEditorOcrError);
      return;
    }

    if (pickedFile == null || !mounted) return;

    // --- Crop & rotate step ---
    final theme = Theme.of(context);
    String? croppedPath;
    try {
      final imageEditService = ref.read(imageEditServiceProvider);
      croppedPath = await imageEditService.cropAndRotate(
        sourcePath: pickedFile.path,
        toolbarTitle: l10n.entryEditorCropImageTitle,
        toolbarColor: theme.colorScheme.surface,
        toolbarWidgetColor: theme.colorScheme.onSurface,
        statusBarBrightness: theme.brightness,
        activeControlColor: theme.colorScheme.primary,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'EntryEditorScreen: image crop failed',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) _showMessage(l10n.entryEditorCropImageError);
      // Clean up the picked file before returning.
      try {
        File(pickedFile.path).deleteSync();
      } catch (_) {}
      return;
    }

    if (croppedPath == null || !mounted) {
      // User cancelled the cropper — clean up and stop.
      try {
        File(pickedFile.path).deleteSync();
      } catch (_) {}
      return;
    }

    // The path to send to OCR: the cropped file if different, else the original.
    final ocrImagePath = croppedPath;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.entryEditorOcrScanning),
          duration: const Duration(seconds: 2),
        ),
      );

    try {
      final ocrService = ref.read(ocrServiceProvider);
      final extractedText = await ocrService.extractTextFromImage(ocrImagePath);
      if (!mounted) return;

      if (extractedText.isEmpty) {
        _showMessage(l10n.entryEditorOcrNoTextFound);
        return;
      }

      final selection = _quillController.selection;
      final int index;
      final int length;
      if (selection.isValid && selection.baseOffset >= 0) {
        index = selection.baseOffset;
        length = selection.isCollapsed
            ? 0
            : (selection.extentOffset - selection.baseOffset).abs();
      } else {
        index = _quillController.document.length - 1;
        length = 0;
      }

      _quillController.replaceText(
        index,
        length,
        extractedText,
        TextSelection.collapsed(offset: index + extractedText.length),
      );

      setState(() => _isDirty = true);
    } catch (e, stackTrace) {
      AppLogger.error(
        'EntryEditorScreen: OCR extraction failed',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) _showMessage(l10n.entryEditorOcrError);
    } finally {
      // Clean up temporary image files.
      for (final path in {pickedFile.path, ocrImagePath}) {
        try {
          final file = File(path);
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (_) {}
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.onAddAttachment,
    required this.onRecordVoiceNote,
    required this.onScanText,
  });

  final VoidCallback onAddAttachment;
  final VoidCallback onRecordVoiceNote;
  final VoidCallback onScanText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            key: const Key('entry-attachment-add-button'),
            icon: const Icon(Icons.attach_file),
            onPressed: onAddAttachment,
            tooltip: AppLocalizations.of(context).entryAddAttachment,
          ),
          IconButton(
            key: const Key('entry-voice-note-button'),
            icon: const Icon(Icons.mic_outlined),
            onPressed: onRecordVoiceNote,
            tooltip: AppLocalizations.of(context).entryRecordVoiceNote,
          ),
          IconButton(
            key: const Key('entry-ocr-scan-button'),
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: onScanText,
            tooltip: AppLocalizations.of(context).entryEditorScanText,
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
    final links = await db.backlinksDao.getBacklinksForEntryTarget(
      widget.entryId,
    );
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
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).entryLinkedFrom,
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
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context).entryMood,
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
                        label: Text(
                          AppLocalizations.of(
                            context,
                          ).entryMoodChip(_labels[level]!, level),
                        ),
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
  const _AttachmentTray({required this.entryId, this.refreshToken = 0});

  final int entryId;

  /// Changes when the editor has added an attachment, which is the tray's cue
  /// to read the list again.
  final int refreshToken;

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
    if (oldWidget.entryId != widget.entryId ||
        oldWidget.refreshToken != widget.refreshToken) {
      _load();
    }
  }

  Future<void> _load() async {
    final db = ref.read(appDatabaseProvider);
    final attachments = await db.attachmentsDao.getAttachmentsForEntry(
      widget.entryId,
    );
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
      final result = await auth.authenticate(reason: 'Unlock "${a.fileName}"');
      if (result != BiometricAuthResult.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).entryAuthRequired),
            ),
          );
        }
        return;
      }
    }
    final openService = ref.read(attachmentOpenServiceProvider);
    try {
      final session = await openService.prepare(a);

      // PDF, audio and ZIP render inside the app; everything else is handed to
      // another app. Only the external path leaves the temp file in place —
      // the viewer deletes it on dispose.
      if (!session.opensInApp) {
        await openService.openExternally(session);
        return;
      }

      if (!mounted) {
        await session.close();
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AttachmentViewerScreen(
            session: session,
            onOpenExternally: () => openService.openExternally(session),
          ),
        ),
      );
    } on AttachmentOpenException catch (error) {
      if (!mounted) return;
      await _showOpenFailureDialog(a, error.failure);
    }
  }

  Future<void> _showOpenFailureDialog(
    Attachment a,
    AttachmentOpenFailure failure,
  ) async {
    final l10n = AppLocalizations.of(context);
    final (title, retry) = switch (failure) {
      AttachmentOpenFailure.noCompatibleApp => (l10n.attachmentOpenNoApp, true),
      AttachmentOpenFailure.decryptFailed => (
        l10n.attachmentOpenDecryptFailed,
        true,
      ),
      AttachmentOpenFailure.fileNotFound => (
        l10n.attachmentOpenFileMissing,
        false,
      ),
      AttachmentOpenFailure.permissionDenied => (
        l10n.attachmentOpenPermissionDenied,
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
              child: Text(l10n.attachmentOpenWith),
            ),
          if (retry)
            TextButton(
              key: Key('attachment-retry-${a.id}'),
              onPressed: () {
                Navigator.pop(dialogContext);
                _open(a);
              },
              child: Text(l10n.commonRetry),
            ),
          TextButton(
            key: Key('attachment-close-${a.id}'),
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.commonClose),
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
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).entryAttachments,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          for (final a in attachments)
            ListTile(
              key: Key('attachment-tile-${a.id}'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                (_lockedById[a.id] ?? false) ? Icons.lock : Icons.attach_file,
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
                        ? AppLocalizations.of(context).entryRemoveAttachmentLock
                        : AppLocalizations.of(context).entryLockAttachment,
                    onPressed: () => _toggleLock(a),
                  ),
                  IconButton(
                    key: Key('open-attachment-${a.id}'),
                    icon: const Icon(Icons.open_in_new),
                    tooltip: AppLocalizations.of(context).entryOpenAttachment,
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
