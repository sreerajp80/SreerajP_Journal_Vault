import 'package:flutter/foundation.dart';

import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_codec.dart';

enum AirqrReceivePhase { scanning, needCode, assembling, done, error }

/// Collects scanned AirQR frames, tracks missing chunks, requests pairing code,
/// and reassembles the received payload.
class AirqrReceiveController extends ChangeNotifier {
  AirqrReceivePhase _phase = AirqrReceivePhase.scanning;
  AirqrManifest? _manifest;
  List<Uint8List?> _chunks = [];
  AirqrPayload? _result;
  String? _errorMessage;
  String? _lastRejection;
  String? _pairingCode;

  AirqrReceivePhase get phase => _phase;
  AirqrManifest? get manifest => _manifest;
  AirqrPayload? get result => _result;
  String? get errorMessage => _errorMessage;
  String? get lastRejection => _lastRejection;
  String? get pairingCode => _pairingCode;

  int? get totalFrames => _manifest?.totalFrames;
  int get receivedCount => _chunks.where((c) => c != null).length;

  double get progress {
    final t = totalFrames;
    if (t == null || t == 0) return 0.0;
    return (receivedCount / t).clamp(0.0, 1.0);
  }

  /// List of frame numbers (1-indexed for user display) still missing.
  List<int> get missingFrames {
    final list = <int>[];
    for (var i = 0; i < _chunks.length; i++) {
      if (_chunks[i] == null) list.add(i + 1);
    }
    return list;
  }

  /// Ingests a raw scanned QR string from the camera.
  void onScan(String raw) {
    if (_phase != AirqrReceivePhase.scanning) return;

    try {
      final parsed = AirqrCodec.parseFrame(raw);
      _lastRejection = null;

      if (parsed.isManifest) {
        final m = parsed.manifest!;
        if (_manifest == null) {
          _manifest = m;
          _chunks = List<Uint8List?>.filled(m.totalFrames, null);
        }
      } else {
        final d = parsed.data!;
        if (_manifest != null && d.totalFrames == _manifest!.totalFrames) {
          if (d.index >= 0 && d.index < _chunks.length) {
            _chunks[d.index] = d.bytes;
          }
        }
      }

      // Check if all chunks are collected
      if (_manifest != null && receivedCount == _manifest!.totalFrames) {
        if (_manifest!.encrypted) {
          _phase = AirqrReceivePhase.needCode;
        } else {
          _assembleAndFinish(null);
        }
      }

      notifyListeners();
    } on AirqrFrameException catch (e) {
      _lastRejection = e.message;
      notifyListeners();
    } catch (_) {
      _lastRejection = 'Unrecognized frame.';
      notifyListeners();
    }
  }

  /// Submits the pairing code for decryption.
  Future<void> submitCode(String code) async {
    _pairingCode = code.trim();
    await _assembleAndFinish(_pairingCode);
  }

  Future<void> _assembleAndFinish(String? code) async {
    _phase = AirqrReceivePhase.assembling;
    _errorMessage = null;
    notifyListeners();

    try {
      final decoded = await AirqrCodec.decodePayload(
        manifest: _manifest!,
        chunks: _chunks,
        pairingCode: code,
      );
      _result = decoded;
      _phase = AirqrReceivePhase.done;
    } catch (e) {
      _phase = AirqrReceivePhase.error;
      _errorMessage = '$e';
    }
    notifyListeners();
  }

  /// Resets the receiver to scan again.
  void reset() {
    _phase = AirqrReceivePhase.scanning;
    _manifest = null;
    _chunks = [];
    _result = null;
    _errorMessage = null;
    _lastRejection = null;
    _pairingCode = null;
    notifyListeners();
  }
}
