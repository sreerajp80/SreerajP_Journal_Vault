import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';

/// Result of a completed voice note recording.
class VoiceNoteRecordingResult {
  const VoiceNoteRecordingResult({
    required this.filePath,
    required this.fileName,
    required this.durationMs,
  });

  final String filePath;
  final String fileName;
  final int durationMs;
}

/// Service that manages voice note recording and speech-to-text transcription.
///
/// Recordings are saved as AAC-encoded M4A files in the app's temporary
/// directory. Callers are responsible for encrypting and persisting the
/// recording via the attachment crypto storage layer.
class VoiceNoteService {
  VoiceNoteService();

  final AudioRecorder _recorder = AudioRecorder();
  final stt.SpeechToText _speech = stt.SpeechToText();

  DateTime? _recordingStartTime;
  bool _isRecording = false;
  String? _currentPath;

  bool get isRecording => _isRecording;

  /// Starts recording audio.
  ///
  /// Returns `true` if recording started successfully, `false` if
  /// microphone permission was denied.
  Future<bool> startRecording() async {
    if (_isRecording) return true;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return false;

    final tempDir = await getTemporaryDirectory();
    final fileName = 'voice_${const Uuid().v4()}.m4a';
    _currentPath = p.join(tempDir.path, fileName);

    await _recorder.start(const RecordConfig(), path: _currentPath!);

    _recordingStartTime = DateTime.now();
    _isRecording = true;
    return true;
  }

  /// Stops recording and returns the result.
  ///
  /// Returns `null` if no recording was in progress.
  Future<VoiceNoteRecordingResult?> stopRecording() async {
    if (!_isRecording || _currentPath == null) return null;

    final path = await _recorder.stop();
    _isRecording = false;

    if (path == null || !File(path).existsSync()) return null;

    final durationMs = _recordingStartTime != null
        ? DateTime.now().difference(_recordingStartTime!).inMilliseconds
        : 0;

    _recordingStartTime = null;
    final fileName = p.basename(path);

    return VoiceNoteRecordingResult(
      filePath: path,
      fileName: fileName,
      durationMs: durationMs,
    );
  }

  /// Cancels an in-progress recording and deletes the partial file.
  Future<void> cancelRecording() async {
    if (!_isRecording) return;
    await _recorder.stop();
    _isRecording = false;
    if (_currentPath != null) {
      final file = File(_currentPath!);
      if (file.existsSync()) await file.delete();
    }
    _currentPath = null;
    _recordingStartTime = null;
  }

  /// Transcribes audio using the device's speech-to-text engine.
  ///
  /// This uses the platform speech recogniser which works on live audio.
  /// For offline file-based transcription a server-side solution would be
  /// needed. This baseline implementation captures live speech during
  /// recording when available.
  ///
  /// Returns the recognized text, or an empty string if unavailable.
  Future<String> transcribeLive({
    required void Function(String partial) onPartial,
  }) async {
    final available = await _speech.initialize();
    if (!available) return '';

    String finalResult = '';

    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          finalResult = result.recognizedWords;
        } else {
          onPartial(result.recognizedWords);
        }
      },
    );

    return finalResult;
  }

  /// Stops live transcription.
  Future<void> stopTranscription() async {
    await _speech.stop();
  }

  /// Releases resources.
  Future<void> dispose() async {
    if (_isRecording) await cancelRecording();
    _recorder.dispose();
  }
}
