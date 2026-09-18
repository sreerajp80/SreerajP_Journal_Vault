import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Playback surface used by [AudioAttachmentView].
///
/// `just_audio`'s `AudioPlayer` is a concrete class that needs a platform
/// channel, so the view talks to this interface instead and widget tests
/// substitute a fake.
abstract class AudioPlaybackHandle {
  /// Loads [filePath] and returns its duration, or null if unknown.
  Future<Duration?> load(String filePath);

  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> dispose();

  Stream<Duration> get positionStream;

  /// Emits true while audio is actually playing.
  Stream<bool> get playingStream;
}

/// [AudioPlaybackHandle] backed by `just_audio`.
class JustAudioPlaybackHandle implements AudioPlaybackHandle {
  JustAudioPlaybackHandle() : _player = AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<Duration?> load(String filePath) => _player.setFilePath(filePath);

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() => _player.dispose();

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<bool> get playingStream => _player.playingStream;
}

/// In-app audio player for an attachment (V1 attachment plan, slice 4).
///
/// Pauses itself when the app is backgrounded so audio never keeps playing
/// behind the lock gate.
class AudioAttachmentView extends StatefulWidget {
  const AudioAttachmentView({
    required this.filePath,
    this.playbackHandleFactory,
    super.key,
  });

  final String filePath;

  /// Injection point for tests. Defaults to the `just_audio` implementation.
  final AudioPlaybackHandle Function()? playbackHandleFactory;

  @override
  State<AudioAttachmentView> createState() => _AudioAttachmentViewState();
}

class _AudioAttachmentViewState extends State<AudioAttachmentView>
    with WidgetsBindingObserver {
  late final AudioPlaybackHandle _handle;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _playingSub;

  Duration _position = Duration.zero;
  Duration? _duration;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handle = (widget.playbackHandleFactory ?? JustAudioPlaybackHandle.new)();
    _load();
  }

  Future<void> _load() async {
    try {
      final duration = await _handle.load(widget.filePath);
      _positionSub = _handle.positionStream.listen((position) {
        if (mounted) setState(() => _position = position);
      });
      _playingSub = _handle.playingStream.listen((playing) {
        if (mounted) setState(() => _isPlaying = playing);
      });
      if (!mounted) return;
      setState(() {
        _duration = duration;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(context).errorAttachmentAudioPlay;
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _isPlaying) {
      _handle.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionSub?.cancel();
    _playingSub?.cancel();
    _handle.dispose();
    super.dispose();
  }

  static String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        key: Key('audio-attachment-loading'),
        child: CircularProgressIndicator(),
      );
    }
    if (_error != null) {
      return Center(
        key: const Key('audio-attachment-error'),
        child: Text(_error!, style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final total = _duration ?? Duration.zero;

    return Padding(
      key: const Key('audio-attachment-player'),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.audiotrack, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Slider(
            key: const Key('audio-attachment-seek'),
            value: _position.inMilliseconds
                .clamp(0, total.inMilliseconds)
                .toDouble(),
            max: max(1.0, total.inMilliseconds.toDouble()),
            onChanged: (ms) => _handle.seek(Duration(milliseconds: ms.round())),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(_format(_position)), Text(_format(total))],
            ),
          ),
          const SizedBox(height: 16),
          IconButton.filled(
            key: const Key('audio-attachment-play-pause'),
            iconSize: 48,
            onPressed: () => _isPlaying ? _handle.pause() : _handle.play(),
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            tooltip: _isPlaying
                ? l10n.tooltipAudioPause
                : l10n.tooltipAudioPlay,
          ),
        ],
      ),
    );
  }
}
