import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/entries/providers/entry_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/voice_note_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Bottom-sheet UI for recording voice notes with live transcription.
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
  String _partialTranscript = '';

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
              AppLocalizations.of(context).editorMicPermissionDenied,
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

    // Start live transcription in parallel.
    service.transcribeLive(
      onPartial: (partial) {
        if (mounted) setState(() => _partialTranscript = partial);
      },
    );
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final service = ref.read(voiceNoteServiceProvider);
    await service.stopTranscription();
    final result = await service.stopRecording();

    if (result != null && mounted) {
      widget.onRecordingComplete(result, _partialTranscript);
      Navigator.pop(context);
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    final service = ref.read(voiceNoteServiceProvider);
    await service.stopTranscription();
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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isRecording ? 'Recording...' : 'Voice Note',
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
          // Transcript preview
          if (_partialTranscript.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _partialTranscript,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 24),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_isRecording)
                TextButton.icon(
                  onPressed: _cancelRecording,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(AppLocalizations.of(context).editorDiscard),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              FloatingActionButton(
                heroTag: 'voice_note_record',
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
                  label: Text(AppLocalizations.of(context).editorDone),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
