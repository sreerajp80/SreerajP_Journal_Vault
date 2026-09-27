import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sreerajp_journal_vault/core/security/stale_file_sweeper.dart';
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

/// Service that manages voice note recording.
///
/// It does not transcribe. The app has no speech to text of its own; users who
/// want it use their keyboard's microphone button.
///
/// Recordings are saved as AAC-encoded M4A files in their own folder,
/// [voiceRecordingDirectoryName], inside the app's cache. They are plain
/// audio, so they must not outlive the recording: `VoiceNoteSaver` encrypts
/// and deletes them, [cancelRecording] deletes them, and the startup sweep
/// clears any left by a crash.
class VoiceNoteService {
  VoiceNoteService();

  final AudioRecorder _recorder = AudioRecorder();

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
    final recordingDir = Directory(
      p.join(tempDir.path, voiceRecordingDirectoryName),
    );
    await recordingDir.create(recursive: true);
    final fileName = 'voice_${const Uuid().v4()}.m4a';
    _currentPath = p.join(recordingDir.path, fileName);

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
    final expected = _currentPath;
    _currentPath = null;

    if (path == null || !File(path).existsSync()) {
      // Nothing usable; do not leave a partial file behind.
      if (expected != null) await _deleteQuietly(expected);
      _recordingStartTime = null;
      return null;
    }

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
    _isRecording = false;
    final path = _currentPath;
    _currentPath = null;
    _recordingStartTime = null;
    try {
      await _recorder.stop();
    } finally {
      if (path != null) await _deleteQuietly(path);
    }
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    } catch (_) {
      // The startup sweep removes it next time.
    }
  }

  /// Releases resources.
  Future<void> dispose() async {
    if (_isRecording) await cancelRecording();
    _recorder.dispose();
  }
}
