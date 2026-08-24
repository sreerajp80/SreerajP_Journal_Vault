import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_codec.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_constants.dart';

/// Drives the frame-by-frame loop that streams an AirQR payload on screen.
class AirqrSendController extends ChangeNotifier {
  final AirqrPayload payload;
  final String pairingCode;
  int _fps;
  int _chunkBytes;

  AirqrEncoded? _encoded;
  int _frameIndex = 0;
  Timer? _timer;
  String? _errorMessage;
  bool _isEncoding = false;

  AirqrSendController({
    required this.payload,
    String? pairingCode,
    int fps = AirqrConstants.defaultFps,
    int chunkBytes = AirqrConstants.frameChunkBytes,
  }) : pairingCode = pairingCode ?? AirqrCodec.generatePairingCode(),
       _fps = fps.clamp(AirqrConstants.minFps, AirqrConstants.maxFps),
       _chunkBytes = chunkBytes.clamp(
         AirqrConstants.minChunkBytes,
         AirqrConstants.maxChunkBytes,
       );

  int get fps => _fps;
  int get chunkBytes => _chunkBytes;
  AirqrEncoded? get encoded => _encoded;
  int get currentFrameIndex => _frameIndex;
  String? get errorMessage => _errorMessage;
  bool get isEncoding => _isEncoding;
  bool get isEncrypted => pairingCode.isNotEmpty;

  /// Current QR string to render.
  String? get currentFrame {
    final enc = _encoded;
    if (enc == null || enc.allFrames.isEmpty) return null;
    return enc.allFrames[_frameIndex % enc.allFrames.length];
  }

  /// Whether current frame is the manifest frame (index 0).
  bool get isManifestFrame => _frameIndex == 0;

  /// Total data frames.
  int get totalDataFrames => _encoded?.totalFrames ?? 0;

  /// Starts encoding and frame animation.
  Future<void> start() async {
    _isEncoding = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _encoded = await AirqrCodec.encode(
        payload: payload,
        pairingCode: pairingCode,
        chunkBytes: _chunkBytes,
      );
      _frameIndex = 0;
      _isEncoding = false;
      _startTimer();
    } catch (e) {
      _isEncoding = false;
      _errorMessage = 'Encoding failed: $e';
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    final intervalMs = (1000 / _fps).round();
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      final enc = _encoded;
      if (enc != null && enc.allFrames.isNotEmpty) {
        _frameIndex = (_frameIndex + 1) % enc.allFrames.length;
        notifyListeners();
      }
    });
  }

  /// Updates FPS dynamically.
  void setFps(int newFps) {
    _fps = newFps.clamp(AirqrConstants.minFps, AirqrConstants.maxFps);
    _startTimer();
    notifyListeners();
  }

  /// Changes chunk size (re-encodes the stream).
  Future<void> setChunkBytes(int newChunkBytes) async {
    _chunkBytes = newChunkBytes.clamp(
      AirqrConstants.minChunkBytes,
      AirqrConstants.maxChunkBytes,
    );
    await start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
