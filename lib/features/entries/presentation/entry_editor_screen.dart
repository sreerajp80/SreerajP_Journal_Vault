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
import 'package:sreerajp_journal_vault/core/l10n/formatting_locale.dart';
import 'package:sreerajp_journal_vault/core/l10n/locale_controller.dart';
import 'package:sreerajp_journal_vault/core/links/vault_backlink_parser.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/core/theme/typography_controller.dart';
import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_models.dart';
import 'package:sreerajp_journal_vault/features/attachments/presentation/attachment_viewer_screen.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_picker_service.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/callout_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing/drawing_canvas_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/dictation_sheet.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/editor_markdown_shortcuts.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/editor_stats_bar.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/editor_toolbar.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/image_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/inline_image_store.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/table_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/voice_note_recorder.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_template_text.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/ocr_camera_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/ocr_enhance_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/version_history_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/entry_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/image_edit_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/ocr_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/voice_note_service.dart';
import 'package:sreerajp_journal_vault/features/entries/templates/entry_templates.dart';
import 'package:sreerajp_journal_vault/features/entries/templates/template_token_engine.dart';
import 'package:sreerajp_journal_vault/features/insights/providers/insights_providers.dart';
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

part 'entry_editor_widgets.dart';
part 'entry_editor_actions.dart';
part 'entry_editor_actions_2.dart';
part 'entry_editor_actions_3.dart';
part 'entry_editor_layout.dart';

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
  /// Lets the extensions in this library's part files rebuild the
  /// widget: `setState` is protected, so they cannot call it directly.
  void _rebuild(VoidCallback fn) => setState(fn);

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

  /// Owned by this screen and handed to the body editor. [QuillEditor.basic]
  /// builds a fresh [FocusNode] when it isn't given one, so the editor would
  /// lose focus on every rebuild — typing or deleting a character rebuilds via
  /// [_updateStats], and focus would fall back to the title field.
  final FocusNode _editorFocusNode = FocusNode(debugLabel: 'EntryBodyEditor');

  /// Same reasoning as [_editorFocusNode]: a per-build [ScrollController] would
  /// reset the body's scroll position and leak on every keystroke.
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    _titleController = TextEditingController();
    _imageStore = buildInlineImageStore(ref);
    _editorFocusNode.addListener(_handleEditorFocusChange);
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
    _editorFocusNode.removeListener(_handleEditorFocusChange);
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
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
          title: Text(l10n.tooltipEditorInsertTable),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.labelEntryTableRows,
                  helperText: l10n.labelEntryTableDimensionHelp,
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: '3'),
                onChanged: (v) => rows = parseDim(v),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.labelEntryTableColumns,
                  helperText: l10n.labelEntryTableDimensionHelp,
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
              child: Text(l10n.actionCommonCancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, (rows: rows, cols: cols)),
              child: Text(l10n.actionCommonInsert),
            ),
          ],
        );
      },
    );
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
        focusNode: _editorFocusNode,
        scrollController: _editorScrollController,
        config: QuillEditorConfig(
          // enableAlwaysIndentOnTab is left at its default of false on
          // purpose: a hardware Tab must type a real tab character rather than
          // re-indent the block, matching the toolbar's Tab button.
          embedBuilders: _embedBuilders,
          customStyles: customStyles,
          placeholder: AppLocalizations.of(context).descEditorPlaceholder,
          contextMenuBuilder: _buildSelectionContextMenu,
          // Side padding keeps line starts clear of the screen edge, where the
          // selection handle is cut off and Android's back gesture takes over
          // the drag. 16 matches the title field above.
          padding: const EdgeInsets.symmetric(horizontal: 16),
          // Shows the text under the finger while a selection handle is
          // dragged.
          quillMagnifierBuilder: defaultQuillMagnifierBuilder,
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
      return _buildDistractionFreeScaffold(l10n, theme, editorContent);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isDirty ? l10n.titleEntryEditTitleDirty : l10n.titleEntryEdit,
        ),
        actions: _buildAppBarActions(l10n, theme),
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
                labelText: l10n.labelEntryTitle,
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
            onInsertTab: _insertTab,
            onInsertTable: _insertTable,
            onInsertCallout: _insertCallout,
            // Offered only once the entry exists — an inline image needs a row
            // to hang its attachment off.
            onInsertImage: _entryId == null ? null : _insertImage,
            onInsertDrawing: _entryId == null ? null : _insertDrawing,
            onScanText: _scanTextFromPhoto,
            onDictate: _dictate,
            onToggleFocusParagraph: () =>
                setState(() => _isFocusParagraph = !_isFocusParagraph),
            isFocusParagraph: _isFocusParagraph,
            onToggleDistractionFree: () =>
                setState(() => _isDistractionFree = !_isDistractionFree),
            isDistractionFree: _isDistractionFree,
          ),
          // Editor body
          Expanded(child: editorContent),
          // Word & Character count + Auto-save indicator bar. Fixed height,
          // so it can never grow over the line being typed.
          EditorStatsBar(
            wordCount: _wordCount,
            characterCount: _characterCount,
            saveStatus: _saveStatus,
            lastSavedTime: _lastSavedTime,
            compact: true,
          ),
          // The three panels below can appear, disappear or change height at
          // any moment — the smart-tag bar re-reads the live text on every
          // keystroke. Growing while the user types would shrink the editor and
          // push the caret line out of view, so they are held back until the
          // caret leaves the body.
          if (!_isTyping) ...[
            // Smart tag suggestions for what has been written so far. Reads the
            // live document rather than the saved row, so suggestions track the
            // text as it is typed. Renders nothing when there is no match.
            if (_entryId != null)
              SmartTagChipBar(
                entryId: _entryId!,
                plainText: _quillController.document.toPlainText(),
              ),
            // Linked-from panel: inbound references to this entry.
            if (_entryId != null) _LinkedFromPanel(entryId: _entryId!),
            // Attachment tray with per-attachment lock toggle.
            if (_entryId != null)
              _AttachmentTray(
                entryId: _entryId!,
                refreshToken: _attachmentRefreshToken,
              ),
          ],
          // Bottom action bar. The mood picker lives behind its button rather
          // than in this column, so it does not sit on screen all the time.
          _BottomActionBar(
            onAddAttachment: _handleAddAttachment,
            onRecordVoiceNote: _showVoiceNoteRecorder,
            onScanText: _scanTextFromPhoto,
            mood: _mood,
            onPickMood: _entryId == null ? null : _showMoodPicker,
          ),
        ],
      ),
    );
  }
}
