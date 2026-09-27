part of 'entry_editor_screen.dart';

extension _EntryEditorScreenStatePart2 on _EntryEditorScreenState {
  void _insertCallout() async {
    final style = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return SimpleDialog(
          title: Text(l10n.titleEntryCalloutType),
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
        .read(entryEditorServiceProvider)
        .loadJournal(widget.journalId);
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
      // intl has no Sanskrit data, so dates fall back to English patterns.
      final formattedDate = DateFormat.yMMMMd(
        formattingLocaleTag(Localizations.localeOf(context).toLanguageTag()),
      ).format(config.unlockDate);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const Key('time-capsule-sealed-snackbar'),
          content: Text(l10n.bodyTimeCapsuleSealedSuccess(formattedDate)),
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
          SnackBar(
            content: Text(AppLocalizations.of(context).errorTimeCapsuleSeal),
          ),
        );
      }
    }
  }

  Future<void> _reloadContent() async {
    if (_entryId == null) return;
    final entry = await ref
        .read(entryEditorServiceProvider)
        .loadEntry(_entryId!);
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
    if (mounted) _rebuild(() => _isDirty = true);
  }

  /// Records a voice note and saves it as an attachment of this entry.
  Future<void> _showVoiceNoteRecorder() async {
    final outcome = await showVoiceNoteRecorder(context, entryId: _entryId);
    if (outcome == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    if (outcome.saved) {
      // The note is now an attachment, so the tray has to read its list again.
      _rebuild(() => _attachmentRefreshToken++);
      _showMessage(
        l10n.labelEntryVoiceNoteSaved(
          (outcome.durationMs / 1000).toStringAsFixed(0),
        ),
      );
    } else {
      _showMessage(l10n.errorVoiceNoteSaveFailed);
    }
  }

  /// Opens the 1–5 mood picker in a bottom sheet.
  ///
  /// The picker used to sit permanently at the foot of the editor. It now
  /// appears only on request, so the writing area keeps that strip of screen.
  Future<void> _showMoodPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: _MoodPickerRow(
          value: _mood,
          // Clearing a mood also passes null, so the choice is applied here
          // rather than through the sheet's return value — a swipe-away would
          // look exactly like "cleared".
          onChanged: (v) {
            Navigator.pop(sheetContext);
            if (v == _mood) return;
            _rebuild(() {
              _mood = v;
              _isDirty = true;
              _editGeneration++;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSelectionContextMenu(
    BuildContext context,
    QuillRawEditorState state,
  ) {
    final l10n = AppLocalizations.of(context);
    final buttonItems = <ContextMenuButtonItem>[
      // Jump-to-line-edge items come first, because they are the reason this
      // menu is opened when the caret cannot be tapped near the screen edge.
      _lineJumpContextMenuItem(l10n.actionEditorGotoLineStart, toStart: true),
      _lineJumpContextMenuItem(l10n.actionEditorGotoLineEnd, toStart: false),
    ];
    if (!_quillController.selection.isCollapsed) {
      buttonItems.addAll([
        _formatContextMenuItem(l10n.actionEditorBold, Attribute.bold),
        _formatContextMenuItem(l10n.actionEditorItalic, Attribute.italic),
        _formatContextMenuItem(l10n.actionEditorUnderline, Attribute.underline),
        _formatContextMenuItem(
          l10n.actionEditorStrike,
          Attribute.strikeThrough,
        ),
      ]);

      // "Convert to table" — offered when the selected text looks like
      // tab-separated or pipe-separated tabular data.
      final sel = _quillController.selection;
      final plainText = _quillController.document.toPlainText();
      final selectedText = plainText.substring(
        sel.start.clamp(0, plainText.length),
        sel.end.clamp(0, plainText.length),
      );
      if (_looksLikeTabularText(selectedText)) {
        buttonItems.add(
          ContextMenuButtonItem(
            label: l10n.actionConvertToTable,
            onPressed: () {
              _convertSelectionToTable(selectedText);
              ContextMenuController.removeAny();
            },
          ),
        );
      }
    }
    buttonItems.addAll(state.contextMenuButtonItems);
    // "Paste as plain text" and "Paste as Markdown" sit right after Paste,
    // and only when Paste is offered (the clipboard has something in it).
    // Paste itself keeps the formatting of copied rich text.
    final pasteIndex = buttonItems.indexWhere(
      (item) => item.type == ContextMenuButtonType.paste,
    );
    if (pasteIndex >= 0) {
      buttonItems.insertAll(pasteIndex + 1, [
        ContextMenuButtonItem(
          label: l10n.actionPastePlainText,
          onPressed: () {
            ContextMenuController.removeAny();
            unawaited(_pastePlainText());
          },
        ),
        ContextMenuButtonItem(
          label: l10n.actionPasteMarkdown,
          onPressed: () {
            ContextMenuController.removeAny();
            unawaited(_pasteAsMarkdown());
          },
        ),
      ]);
    }
    return TextFieldTapRegion(
      child: AdaptiveTextSelectionToolbar.buttonItems(
        buttonItems: buttonItems,
        anchors: _adjustedSelectionAnchors(context, state.contextMenuAnchors),
      ),
    );
  }

  /// Keeps the popup between the formatting toolbar and the keyboard, so it
  /// neither covers the toolbar nor lands off-screen after "Select all".
  TextSelectionToolbarAnchors _adjustedSelectionAnchors(
    BuildContext context,
    TextSelectionToolbarAnchors anchors,
  ) {
    final toolbarBox =
        _toolbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (toolbarBox == null || !toolbarBox.attached) return anchors;
    final toolbarBottom =
        toolbarBox.localToGlobal(Offset.zero).dy + toolbarBox.size.height;
    final screenBottom =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom;
    return clampSelectionMenuAnchors(
      anchors,
      visibleTop: toolbarBottom,
      visibleBottom: screenBottom,
    );
  }

  /// Builds one of the two caret-jump items in the selection popup.
  ///
  /// Tapping it collapses the selection onto the first or the last character
  /// of the logical line the caret sits on, then closes the popup.
  ContextMenuButtonItem _lineJumpContextMenuItem(
    String label, {
    required bool toStart,
  }) {
    return ContextMenuButtonItem(
      label: label,
      onPressed: () {
        final text = _quillController.document.toPlainText();
        final from = _quillController.selection.baseOffset;
        final target = toStart
            ? lineStartOffset(text, from)
            : lineEndOffset(text, from);
        _quillController.updateSelection(
          TextSelection.collapsed(offset: target),
          ChangeSource.local,
        );
        ContextMenuController.removeAny();
      },
    );
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
            title: Text(l10n.bodyEntryPermission),
            content: Text(l10n.bodyEntryPermissionBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.actionCommonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.actionCommonContinue),
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
              title: Text(l10n.titleEntryPermissionBlocked),
              content: Text(l10n.bodyEntryPermissionBlocked),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.actionCommonCancel),
                ),
                TextButton(
                  onPressed: () {
                    service.openSystemSettings();
                    Navigator.pop(dialogContext);
                  },
                  child: Text(l10n.actionCommonOpenSystemSettings),
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

  // ---------------------------------------------------------------------------
  // Text-to-table conversion
  // ---------------------------------------------------------------------------

  /// Returns true when [text] looks like tab-separated or pipe-separated
  /// tabular data: at least two lines, and at least one delimiter character.
  bool _looksLikeTabularText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final lines = trimmed.split('\n');
    if (lines.length < 2) return false;
    return trimmed.contains('\t') || trimmed.contains('|');
  }

  /// Pastes only the clipboard's words, with no formatting, tables or links,
  /// even when the clipboard holds rich text. Replaces any selected text;
  /// one Undo removes it.
  Future<void> _pastePlainText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (!mounted || text == null || text.isEmpty) return;
    final selection = _quillController.selection;
    final start = selection.start;
    _quillController.replaceText(
      start,
      selection.end - start,
      text,
      TextSelection.collapsed(offset: start + text.length),
    );
  }

  /// Pastes the clipboard text as Markdown: headings, lists, tables and links
  /// become formatted text. Replaces any selected text; one Undo removes it.
  Future<void> _pasteAsMarkdown() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (!mounted || text == null || text.trim().isEmpty) return;

    final ops = const MarkdownToDelta().convert(text);
    // Like a normal paste, don't add a line break after the last line
    // unless it carries a block style (a list item or heading, say).
    final last = ops.last;
    if (ops.length > 1 &&
        last['insert'] == '\n' &&
        last['attributes'] == null) {
      ops.removeLast();
    }
    final delta = Delta.fromJson(ops);
    final selection = _quillController.selection;
    final start = selection.start;
    _quillController.replaceText(
      start,
      selection.end - start,
      delta,
      TextSelection.collapsed(offset: start + delta.length),
    );
  }

  /// Replaces the current selection with a [TableEmbed] built from the
  /// tab-separated or pipe-separated [text].
  void _convertSelectionToTable(String text) {
    final trimmed = text.trim();
    // Decide the delimiter: prefer tab, fall back to pipe.
    final delimiter = trimmed.contains('\t') ? '\t' : '|';
    final lines = trimmed.split('\n');
    final rows = <List<String>>[];
    int maxCols = 0;

    for (final line in lines) {
      final cells = line.split(delimiter).map((c) => c.trim()).toList();
      rows.add(cells);
      if (cells.length > maxCols) maxCols = cells.length;
    }

    // Pad shorter rows so every row has the same column count.
    for (final row in rows) {
      while (row.length < maxCols) {
        row.add('');
      }
    }

    // Bound dimensions to match the insert-table dialog limits.
    if (rows.length > 20) rows.removeRange(20, rows.length);
    if (maxCols > 20) {
      for (int r = 0; r < rows.length; r++) {
        rows[r] = rows[r].sublist(0, 20);
      }
    }

    final sel = _quillController.selection;
    final start = sel.start;
    final length = sel.end - sel.start;
    final embed = TableEmbed.fromRows(rows);

    _quillController.replaceText(start, length, embed, null);
    // Insert a trailing newline so the cursor has somewhere to land.
    _quillController.replaceText(
      start + 1,
      0,
      '\n',
      TextSelection.collapsed(offset: start + 2),
    );
  }
}
