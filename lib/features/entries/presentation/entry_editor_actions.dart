part of 'entry_editor_screen.dart';

extension _EntryEditorScreenStatePart1 on _EntryEditorScreenState {
  /// True while the caret is in the body editor — that is, while the user is
  /// typing. The panels that sit under the editor are hidden in this state so
  /// nothing below the caret can change height mid-keystroke.
  bool get _isTyping => _editorFocusNode.hasFocus;

  void _handleEditorFocusChange() {
    // Back in the entry body: a table cell edit is over, so the toolbar
    // formats the entry again.
    if (_editorFocusNode.hasFocus) _cellEditing.clear();
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
    // Table words count too; see entryPlainText.
    final text = entryPlainText(_quillController.document.toDelta().toJson());
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
    final entry = await ref.read(entryEditorServiceProvider).loadEntry(id);
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

    final editorService = ref.read(entryEditorServiceProvider);
    final id = await editorService.createEntry(
      journalId: widget.journalId,
      title: resolvedTitle,
      contentJson: resolvedContentJson,
    );

    if (widget.initialAttachments != null &&
        widget.initialAttachments!.isNotEmpty) {
      for (final picked in widget.initialAttachments!) {
        try {
          final attachmentId = await editorService.addAttachment(id, picked);
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
      await editorService.updateContentJson(id, updatedJson);
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
              enableIMEPersonalizedLearning: KeyboardPrivacyScope.allowLearning(
                context,
              ),
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
              enableIMEPersonalizedLearning: KeyboardPrivacyScope.allowLearning(
                context,
              ),
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
      await ref
          .read(userTemplateServiceProvider)
          .createTemplate(
            name: name,
            description: desc,
            defaultTitle: title,
            contentJson: contentJson,
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
    _editGeneration++;
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

  /// What a save writes, read from the screen in one go, before any await.
  _EditorSnapshot _snapshot() {
    final delta = _quillController.document.toDelta().toJson();
    return (
      title: _titleController.text.trim(),
      contentJson: jsonEncode(delta),
      // The search index needs the words inside tables as well.
      plainText: entryPlainText(delta),
      mood: _mood,
    );
  }

  /// Writes [snapshot] for entry [entryId]. Uses only services read in
  /// `initState`, never `ref` or widget state, so it may run on after the
  /// screen has closed.
  Future<void> _saveSnapshot(int entryId, _EditorSnapshot snapshot) async {
    // Keeps the stored version as a revision, saves, and refreshes the
    // outgoing backlinks, in one transaction.
    await _editorService.saveContent(
      entryId,
      title: snapshot.title,
      contentJson: snapshot.contentJson,
      plainText: snapshot.plainText,
    );

    // Persist the mood rating if the user picked one. Clear when nulled.
    final mood = snapshot.mood;
    if (mood != null) {
      await _insightsService.setMood(entryId: entryId, mood: mood);
    } else {
      await _insightsService.deleteMood(entryId);
    }
  }

  /// Saves the current content and creates a revision snapshot.
  Future<void> _saveContent({bool isAutoSave = false}) async {
    final entryId = _entryId;
    if (entryId == null) return;
    if (!isAutoSave) {
      _autoSaveTimer?.cancel();
    }

    if (mounted) {
      _rebuild(() => _saveStatus = EditorSaveStatus.saving);
    }

    final generation = _editGeneration;
    await _saveSnapshot(entryId, _snapshot());

    if (!mounted) return;
    // A change made while the save ran is still unsaved: keep it dirty, so the
    // next autosave, or closing the screen, saves it.
    final changedMeanwhile = generation != _editGeneration;
    _rebuild(() {
      _isDirty = changedMeanwhile;
      _saveStatus = changedMeanwhile
          ? EditorSaveStatus.unsaved
          : EditorSaveStatus.saved;
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
    try {
      await ref.read(entryDeletionServiceProvider).deleteEntry(_entryId!);
    } catch (e, stackTrace) {
      AppLogger.error(
        'EntryEditorScreen: entry delete failed',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) _showMessage(AppLocalizations.of(context).errorEntryDelete);
      return;
    }
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
