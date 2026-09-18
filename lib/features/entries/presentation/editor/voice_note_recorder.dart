import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/entries/providers/entry_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/voice_note_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Bottom-sheet UI for recording voice notes.
class VoiceNoteRecorder extends ConsumerStatefulWidget {
  const VoiceNoteRecorder({super.key, required this.onRecordingComplete});

  final void Function(VoiceNoteRecordingResult result, String transcript)
  onRecordingComplete;

  @override
  ConsumerState<VoiceNoteRecorder> createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends ConsumerState<VoiceNoteRecorder> {
  bool _isRecording = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final service = ref.read(voiceNoteServiceProvider);
    final started = await service.startRecording();
    if (!started) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).bodyEditorMicPermissionDenied,
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isRecording = true;
      _elapsed = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed += const Duration(seconds: 1));
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final service = ref.read(voiceNoteServiceProvider);
    final result = await service.stopRecording();

    if (result != null && mounted) {
      widget.onRecordingComplete(result, '');
      Navigator.pop(context);
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    final service = ref.read(voiceNoteServiceProvider);
    await service.cancelRecording();
    if (mounted) Navigator.pop(context);
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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isRecording ? l10n.bodyVoiceNoteRecording : l10n.titleVoiceNote,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          // Timer display
          Text(
            _formatDuration(_elapsed),
            style: theme.textTheme.displaySmall?.copyWith(
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 24),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_isRecording)
                TextButton.icon(
                  onPressed: _cancelRecording,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(AppLocalizations.of(context).actionEditorDiscard),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              FloatingActionButton(
                heroTag: 'voice_note_record',
                tooltip: _isRecording
                    ? AppLocalizations.of(context).tooltipStopRecording
                    : AppLocalizations.of(context).tooltipRecordVoiceNote,
                onPressed: _isRecording ? _stopRecording : _startRecording,
                backgroundColor: _isRecording
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: _isRecording
                      ? theme.colorScheme.onError
                      : theme.colorScheme.onPrimary,
                ),
              ),
              if (_isRecording)
                TextButton.icon(
                  onPressed: _stopRecording,
                  icon: const Icon(Icons.check),
                  label: Text(AppLocalizations.of(context).actionEditorDone),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
