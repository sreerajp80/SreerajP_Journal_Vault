part of 'entry_editor_screen.dart';

/// The two larger pieces of the editor's layout, kept out of `build` so the
/// screen file stays readable.
extension _EntryEditorLayout on _EntryEditorScreenState {
  /// The full-screen writing mode: a minimal top bar, the title, the toolbar,
  /// the editor and the stats bar, with nothing else on screen.
  Widget _buildDistractionFreeScaffold(
    AppLocalizations l10n,
    ThemeData theme,
    Widget editorContent,
  ) {
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
                    tooltip: l10n.actionEntryDistractionFreeExit,
                    onPressed: () => _rebuild(() => _isDistractionFree = false),
                  ),
                  const Spacer(),
                  IconButton(
                    key: const Key('distraction-free-focus-button'),
                    icon: Icon(
                      _isFocusParagraph
                          ? Icons.filter_center_focus
                          : Icons.center_focus_weak_outlined,
                    ),
                    color: _isFocusParagraph ? theme.colorScheme.primary : null,
                    tooltip: _isFocusParagraph
                        ? l10n.descEntryFocusParagraphOn
                        : l10n.descEntryFocusParagraphOff,
                    onPressed: () =>
                        _rebuild(() => _isFocusParagraph = !_isFocusParagraph),
                  ),
                  IconButton(
                    key: const Key('distraction-free-save-button'),
                    icon: Icon(_isDirty ? Icons.save : Icons.save_outlined),
                    color: _isDirty ? theme.colorScheme.primary : null,
                    onPressed: _isDirty ? _saveContent : null,
                    tooltip: _isDirty
                        ? l10n.tooltipEntrySave
                        : l10n.tooltipEntryNoUnsavedChanges,
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
                  labelText: l10n.labelEntryTitle,
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
              onInsertTab: _insertTab,
              onInsertTable: _insertTable,
              onInsertCallout: _insertCallout,
              onInsertImage: _entryId == null ? null : _insertImage,
              onInsertDrawing: _entryId == null ? null : _insertDrawing,
              onScanText: _scanTextFromPhoto,
              onDictate: _dictate,
              onToggleFocusParagraph: () =>
                  _rebuild(() => _isFocusParagraph = !_isFocusParagraph),
              isFocusParagraph: _isFocusParagraph,
              onToggleDistractionFree: () =>
                  _rebuild(() => _isDistractionFree = !_isDistractionFree),
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

  /// The editor's app-bar buttons.
  List<Widget> _buildAppBarActions(AppLocalizations l10n, ThemeData theme) {
    return [
      IconButton(
        icon: const Icon(Icons.history),
        onPressed: _openVersionHistory,
        tooltip: l10n.tooltipEntryVersionHistory,
      ),
      // Export is offered only once the entry exists, because there is
      // nothing to write out before the first save.
      if (_entryId != null)
        IconButton(
          key: const Key('entry-export-button'),
          icon: const Icon(Icons.ios_share),
          onPressed: _openExport,
          tooltip: l10n.tooltipExportEntry,
        ),
      if (_entryId != null)
        IconButton(
          key: const Key('entry-seal-time-capsule-button'),
          icon: const Icon(Icons.hourglass_top_rounded),
          tooltip: l10n.actionTimeCapsuleActionSeal,
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
            ? l10n.descEntryFocusParagraphOn
            : l10n.descEntryFocusParagraphOff,
        onPressed: () => _rebuild(() => _isFocusParagraph = !_isFocusParagraph),
      ),
      // Distraction-free mode toggle in AppBar
      IconButton(
        key: const Key('entry-appbar-distraction-free-toggle'),
        icon: const Icon(Icons.fullscreen),
        tooltip: l10n.actionEntryDistractionFreeEnter,
        onPressed: () => _rebuild(() => _isDistractionFree = true),
      ),
      if (_entryId != null)
        IconButton(
          key: const Key('entry-delete-button'),
          icon: const Icon(Icons.delete_outline),
          onPressed: _confirmDelete,
          tooltip: l10n.tooltipEntryDelete,
        ),
      IconButton(
        key: const Key('entry-save-as-template-button'),
        icon: const Icon(Icons.bookmark_add_outlined),
        tooltip: l10n.actionTemplateSaveAsTemplate,
        onPressed: _saveAsTemplate,
      ),
      IconButton(
        key: const Key('entry-save-button'),
        icon: Icon(_isDirty ? Icons.save : Icons.save_outlined),
        color: _isDirty ? theme.colorScheme.primary : null,
        onPressed: _isDirty ? _saveContent : null,
        tooltip: _isDirty
            ? l10n.tooltipEntrySave
            : l10n.tooltipEntryNoUnsavedChanges,
      ),
    ];
  }
}
