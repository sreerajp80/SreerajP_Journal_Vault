part of 'entry_editor_screen.dart';

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.onAddAttachment,
    required this.onRecordVoiceNote,
    required this.onScanText,
    this.mood,
    this.onPickMood,
  });

  final VoidCallback onAddAttachment;
  final VoidCallback onRecordVoiceNote;
  final VoidCallback onScanText;

  /// Current 1–5 mood, or null when none is set. Drives the button's face.
  final int? mood;

  /// Opens the mood picker sheet. Null before the entry row exists.
  final VoidCallback? onPickMood;

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
            tooltip: AppLocalizations.of(context).tooltipEntryAddAttachment,
          ),
          IconButton(
            key: const Key('entry-voice-note-button'),
            icon: const Icon(Icons.mic_outlined),
            onPressed: onRecordVoiceNote,
            tooltip: AppLocalizations.of(context).tooltipEntryRecordVoiceNote,
          ),
          IconButton(
            key: const Key('entry-ocr-scan-button'),
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: onScanText,
            tooltip: AppLocalizations.of(context).tooltipEntryEditorScanText,
          ),
          if (onPickMood != null)
            IconButton(
              key: const Key('entry-mood-button'),
              icon: mood == null
                  ? const Icon(Icons.mood_outlined)
                  : Text(
                      _MoodPickerRow.faceFor(mood!),
                      style: const TextStyle(fontSize: 20),
                    ),
              onPressed: onPickMood,
              tooltip: AppLocalizations.of(context).tooltipEntryMood,
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
            AppLocalizations.of(context).titleEntryLinkedFrom,
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

  /// The face for a 1–5 level, so the button that opens this picker can show
  /// the same emoji the chips use.
  static String faceFor(int level) => _labels[level] ?? _labels[3]!;

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
            AppLocalizations.of(context).titleEntryMood,
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
                          ).labelEntryMood(_labels[level]!, level),
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
      final result = await auth.authenticate(
        reason: AppLocalizations.of(
          context,
        ).descBiometricReasonFile(a.fileName),
      );
      if (result != BiometricAuthResult.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).errorEntryAuth),
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
      AttachmentOpenFailure.noCompatibleApp => (
        l10n.bodyAttachmentOpenNoApp,
        true,
      ),
      AttachmentOpenFailure.decryptFailed => (
        l10n.errorAttachmentOpenDecrypt,
        true,
      ),
      AttachmentOpenFailure.fileNotFound => (
        l10n.bodyAttachmentOpenFileMissing,
        false,
      ),
      AttachmentOpenFailure.permissionDenied => (
        l10n.bodyAttachmentOpenPermissionDenied,
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
              child: Text(l10n.descAttachmentOpenWith),
            ),
          if (retry)
            TextButton(
              key: Key('attachment-retry-${a.id}'),
              onPressed: () {
                Navigator.pop(dialogContext);
                _open(a);
              },
              child: Text(l10n.errorCommonRetry),
            ),
          TextButton(
            key: Key('attachment-close-${a.id}'),
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.actionCommonClose),
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
            AppLocalizations.of(context).titleEntryAttachments,
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
                        ? AppLocalizations.of(
                            context,
                          ).tooltipEntryRemoveAttachmentLock
                        : AppLocalizations.of(
                            context,
                          ).tooltipEntryLockAttachment,
                    onPressed: () => _toggleLock(a),
                  ),
                  IconButton(
                    key: Key('open-attachment-${a.id}'),
                    icon: const Icon(Icons.open_in_new),
                    tooltip: AppLocalizations.of(
                      context,
                    ).tooltipEntryOpenAttachment,
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

/// Offset of the first character of the logical line holding [offset].
///
/// A logical line is the text between two newlines, so a soft-wrapped visual
/// row does not count as its own line. [offset] is clamped into [text].
int lineStartOffset(String text, int offset) {
  final at = offset.clamp(0, text.length);
  if (at == 0) return 0;
  final newline = text.lastIndexOf('\n', at - 1);
  return newline == -1 ? 0 : newline + 1;
}

/// Offset just after the last character of the logical line holding [offset].
///
/// This is the position of the next newline, or the end of [text] when the
/// caret is on the last line. [offset] is clamped into [text].
int lineEndOffset(String text, int offset) {
  final at = offset.clamp(0, text.length);
  final newline = text.indexOf('\n', at);
  return newline == -1 ? text.length : newline;
}
