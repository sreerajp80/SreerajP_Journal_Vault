import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/entry_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/voice_note_saver.dart';
import 'package:sreerajp_journal_vault/features/entries/services/voice_note_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// What the recorder sheet reports when it closes after a recording.
class VoiceNoteOutcome {
  const VoiceNoteOutcome.saved(this.durationMs) : saved = true;

  const VoiceNoteOutcome.failed() : saved = false, durationMs = 0;

  /// True when the voice note is now an attachment of the entry.
  final bool saved;

  /// Length of the saved recording.
  final int durationMs;
}

/// Opens the recorder for the entry [entryId].
///
/// Returns the outcome, or null when the user closed the sheet without
/// recording or discarded the recording. Dragging the sheet down is off,
/// because a drag would close it without asking while the microphone is on.
Future<VoiceNoteOutcome?> showVoiceNoteRecorder(
  BuildContext context, {
  required int? entryId,
}) {
  return showModalBottomSheet<VoiceNoteOutcome>(
    context: context,
    enableDrag: false,
    builder: (_) => VoiceNoteRecorder(entryId: entryId),
  );
}

enum _Phase { idle, recording, saving }

/// Bottom-sheet UI for recording a voice note.
///
/// Nothing is left behind: stopping saves the recording as an encrypted
/// attachment and deletes the plain file, discarding deletes it, and a sheet
/// that closes any other way stops the microphone and deletes it too.
class VoiceNoteRecorder extends ConsumerStatefulWidget {
  const VoiceNoteRecorder({super.key, required this.entryId});

  /// The entry the voice note belongs to. Null while the entry is being
  /// created, in which case saving fails cleanly.
  final int? entryId;

  @override
  ConsumerState<VoiceNoteRecorder> createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends ConsumerState<VoiceNoteRecorder> {
  // Read once here: `ref` cannot be used in dispose, where the recording may
  // still need stopping.
  late final VoiceNoteService _service = ref.read(voiceNoteServiceProvider);
  _Phase _phase = _Phase.idle;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    if (_phase == _Phase.recording) {
      // Closed without Done or Discard: stop the microphone and delete the
      // partial file.
      unawaited(_service.cancelRecording());
    }
    super.dispose();
  }

  Future<void> _startRecording() async {
    final bool started;
    try {
      started = await _service.startRecording();
    } catch (e) {
      AppLogger.error(
        'VoiceNoteRecorder: recording did not start (${e.runtimeType})',
      );
      if (mounted) Navigator.pop(context, const VoiceNoteOutcome.failed());
      return;
    }
    if (!mounted) {
      if (started) unawaited(_service.cancelRecording());
      return;
    }
    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).bodyEditorMicPermissionDenied,
          ),
        ),
      );
      return;
    }

    setState(() {
      _phase = _Phase.recording;
      _elapsed = Duration.zero;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _stopAndSave() async {
    _timer?.cancel();
    final l10n = AppLocalizations.of(context);
    setState(() => _phase = _Phase.saving);

    VoiceNoteOutcome outcome;
    try {
      final result = await _service.stopRecording();
      if (result == null) {
        throw const VoiceNoteSaveException('no_recording');
      }
      final name =
          '${l10n.labelVoiceNoteFileName(voiceNoteTimestamp(DateTime.now()))}.m4a';
      await ref
          .read(voiceNoteSaverProvider)
          .save(
            entryId: widget.entryId,
            recordingPath: result.filePath,
            fileName: name,
          );
      outcome = VoiceNoteOutcome.saved(result.durationMs);
    } catch (e) {
      // Only the error type: a file system or database error could carry the
      // file name.
      AppLogger.error('VoiceNoteRecorder: save failed (${e.runtimeType})');
      outcome = const VoiceNoteOutcome.failed();
    }
    // The phase is no longer "recording", so dispose does not cancel again.
    _phase = _Phase.idle;
    if (mounted) Navigator.pop(context, outcome);
  }

  Future<void> _discard() async {
    _timer?.cancel();
    _phase = _Phase.idle;
    await _service.cancelRecording();
    if (mounted) Navigator.pop(context);
  }

  /// Back or a tap outside while recording: ask before throwing it away.
  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.bodyVoiceNoteDiscardConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.actionCommonCancel),
          ),
          TextButton(
            key: const Key('voice-note-discard-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.actionEditorDiscard),
          ),
        ],
      ),
    );
    if (discard == true && mounted && _phase == _Phase.recording) {
      await _discard();
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final recording = _phase == _Phase.recording;
    final saving = _phase == _Phase.saving;

    return PopScope(
      canPop: _phase == _Phase.idle,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _phase == _Phase.recording) {
          unawaited(_confirmDiscard());
        }
      },
      child: Padding(
        // Clears the system navigation bar, which the app draws behind on
        // Android 15+.
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              recording ? l10n.bodyVoiceNoteRecording : l10n.titleVoiceNote,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              _formatDuration(_elapsed),
              style: theme.textTheme.displaySmall?.copyWith(
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 32),
            if (saving)
              Semantics(
                liveRegion: true,
                label: l10n.labelVoiceNoteSaving,
                child: Row(
                  key: const Key('voice-note-saving'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    const SizedBox(width: 16),
                    Text(l10n.labelVoiceNoteSaving),
                  ],
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (recording)
                    TextButton.icon(
                      key: const Key('voice-note-discard'),
                      onPressed: _discard,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.actionEditorDiscard),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  FloatingActionButton(
                    key: const Key('voice-note-record'),
                    heroTag: 'voice_note_record',
                    tooltip: recording
                        ? l10n.tooltipStopRecording
                        : l10n.tooltipRecordVoiceNote,
                    onPressed: recording ? _stopAndSave : _startRecording,
                    backgroundColor: recording
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    child: Icon(
                      recording ? Icons.stop : Icons.mic,
                      color: recording
                          ? theme.colorScheme.onError
                          : theme.colorScheme.onPrimary,
                    ),
                  ),
                  if (recording)
                    TextButton.icon(
                      key: const Key('voice-note-done'),
                      onPressed: _stopAndSave,
                      icon: const Icon(Icons.check),
                      label: Text(l10n.actionEditorDone),
                    ),
                ],
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
