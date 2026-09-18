part of 'entry_editor_screen.dart';

extension _EntryEditorScreenStatePart1 on _EntryEditorScreenState {
  /// True while the caret is in the body editor — that is, while the user is
  /// typing. The panels that sit under the editor are hidden in this state so
  /// nothing below the caret can change height mid-keystroke.
  bool get _isTyping => _editorFocusNode.hasFocus;

  void _handleEditorFocusChange() {
    if (mounted) _rebuild(() {});
  }

  /// Types a tab character at the caret.
  ///
  /// Android soft keyboards carry no Tab key, and flutter_quill only reacts to
  /// a hardware Tab, so the toolbar button is the only route on a phone.
  void _insertTab() {
    final selection = _quillController.selection;
    final start = selection.start;
    _quillController.replaceText(
      start,
      selection.end - start,
      '\t',
      TextSelection.collapsed(offset: start + 1),
    );
  }

  void _updateStats() {
    final text = _quillController.document.toPlainText();
    final words = EditorStatsBar.countWords(text);
    final chars = EditorStatsBar.countCharacters(text);
    if (words != _wordCount || chars != _characterCount) {
      if (mounted) {
        _rebuild(() {
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
    _rebuild(() {
      _entryId = id;
      _mood = existingMood?.mood;
    });
    _updateStats();
    _attachChangeListeners();
  }

  Future<void> _createEntry() async {
    final selected =
        widget.initialTemplate ?? templateFor(widget.initialTemplateId);

    // Runs from initState, where Localizations.localeOf(context) is not
    // allowed, so the language comes from the locale controller instead.
    final locale = effectiveAppLocale(ref.read(localeControllerProvider));
    final l10n = lookupAppLocalizations(locale);
    final localeTag = locale.toLanguageTag();
    String resolvedTitle = TemplateTokenEngine.resolveTokens(
      selected.defaultTitleIn(l10n),
      locale: localeTag,
    );
    String resolvedContentJson = TemplateTokenEngine.resolveContentJsonTokens(
      selected.contentJsonIn(l10n),
      locale: localeTag,
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
    _rebuild(() => _entryId = id);
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
        title: Text(l10n.titleTemplateSaveAsTemplate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.descTemplateSaveAsTemplate),
            const SizedBox(height: 12),
            TextField(
              key: const Key('save-as-template-name-field'),
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.labelTemplateName,
                hintText: l10n.descTemplateName,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('save-as-template-desc-field'),
              controller: descController,
              decoration: InputDecoration(
                labelText: l10n.labelTemplateDescription,
                hintText: l10n.descTemplateDescription,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.actionCommonCancel),
          ),
          FilledButton(
            key: const Key('confirm-save-as-template-button'),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(dialogCtx).pop(true);
              }
            },
            child: Text(l10n.actionCommonSave),
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
        ).showSnackBar(SnackBar(content: Text(l10n.bodyTemplateSaveSuccess)));
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
      _rebuild(() {
        _isDirty = true;
        _saveStatus = EditorSaveStatus.unsaved;
      });
    }
    // Schedule a background auto-save 2.5s after editing stops.
    _autoSaveTimer = Timer(const Duration(milliseconds: 2500), () {
      _saveContent(isAutoSave: true);
    });
  }

  /// Saves the current content and creates a revision snapshot.
  Future<void> _saveContent({bool isAutoSave = false}) async {
    if (_entryId == null) return;
    if (!isAutoSave) {
      _autoSaveTimer?.cancel();
    }

    if (mounted) {
      _rebuild(() => _saveStatus = EditorSaveStatus.saving);
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
    _rebuild(() {
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
            content: Text(AppLocalizations.of(context).labelEntrySaved),
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
        title: Text(AppLocalizations.of(dialogContext).bodyEntryDelete),
        content: Text(AppLocalizations.of(dialogContext).bodyEntryDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.of(dialogContext).actionCommonCancel),
          ),
          TextButton(
            key: const Key('entry-delete-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppLocalizations.of(dialogContext).actionCommonDelete),
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

  /// The callout `type` is a document code, not text for the user. Map it to a
  /// translated label rather than capitalising the code.
  String _calloutLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case 'info':
        return l10n.labelEntryCalloutInfo;
      case 'tip':
        return l10n.labelEntryCalloutTip;
      case 'warning':
        return l10n.bodyEntryCallout;
      case 'important':
        return l10n.labelEntryCalloutImportant;
      default:
        return type;
    }
  }
}
