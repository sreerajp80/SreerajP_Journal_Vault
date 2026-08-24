import 'dart:convert';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_constants.dart';

/// Represents a typed data payload transferred via AirQR.
class AirqrPayload {
  final String kind;
  final String title;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const AirqrPayload({
    required this.kind,
    required this.title,
    required this.data,
    required this.timestamp,
  });

  /// Factory for app settings & preferences payload.
  factory AirqrPayload.settings({
    required String themeMode,
    String? appThemeMode,
    String? fontFamily,
    double? fontSize,
    required int? accentColorArgb,
    required String? accentPresetName,
    required bool isScreenSecurityEnabled,
    required bool ritualLaunchOnStartup,
    required String ritualBreathTechnique,
    required int ritualBreathCycles,
    required List<Map<String, dynamic>> templates,
    required List<Map<String, dynamic>> tags,
  }) {
    return AirqrPayload(
      kind: AirqrConstants.kindSettings,
      title: 'App Settings & Templates',
      timestamp: DateTime.now(),
      data: {
        'themeMode': themeMode,
        'appThemeMode': ?appThemeMode,
        'fontFamily': ?fontFamily,
        'fontSize': ?fontSize,
        'accentColorArgb': accentColorArgb,
        'accentPresetName': accentPresetName,
        'isScreenSecurityEnabled': isScreenSecurityEnabled,
        'ritualLaunchOnStartup': ritualLaunchOnStartup,
        'ritualBreathTechnique': ritualBreathTechnique,
        'ritualBreathCycles': ritualBreathCycles,
        'templates': templates,
        'tags': tags,
      },
    );
  }

  /// Factory for a single journal entry payload.
  factory AirqrPayload.entry({
    required String title,
    required String contentJson,
    required String plainText,
    String? mood,
    List<String> tags = const [],
    DateTime? createdAt,
  }) {
    return AirqrPayload(
      kind: AirqrConstants.kindEntry,
      title: title.isNotEmpty ? title : 'Journal Entry',
      timestamp: DateTime.now(),
      data: {
        'title': title,
        'contentJson': contentJson,
        'plainText': plainText,
        'mood': mood,
        'tags': tags,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      },
    );
  }

  /// Factory for a complete single journal with text entries.
  factory AirqrPayload.journal({
    required String title,
    String? description,
    required List<Map<String, dynamic>> entries,
    required List<Map<String, dynamic>> tags,
  }) {
    return AirqrPayload(
      kind: AirqrConstants.kindJournal,
      title: title,
      timestamp: DateTime.now(),
      data: {
        'title': title,
        'description': description,
        'entries': entries,
        'tags': tags,
      },
    );
  }

  /// Factory for a vault snapshot payload.
  factory AirqrPayload.snapshot({
    required List<Map<String, dynamic>> journals,
    required List<Map<String, dynamic>> entries,
    required List<Map<String, dynamic>> tags,
  }) {
    return AirqrPayload(
      kind: AirqrConstants.kindSnapshot,
      title: 'Vault Text Snapshot',
      timestamp: DateTime.now(),
      data: {'journals': journals, 'entries': entries, 'tags': tags},
    );
  }

  /// Serializes to JSON UTF-8 bytes.
  List<int> toBytes() {
    final map = {
      'kind': kind,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
    return utf8.encode(jsonEncode(map));
  }

  /// Deserializes from JSON UTF-8 bytes.
  factory AirqrPayload.fromBytes(List<int> bytes) {
    final decoded = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return AirqrPayload(
      kind: decoded['kind'] as String? ?? AirqrConstants.kindSnapshot,
      title: decoded['title'] as String? ?? 'Imported Data',
      timestamp:
          DateTime.tryParse(decoded['timestamp'] as String? ?? '') ??
          DateTime.now(),
      data: (decoded['data'] as Map<String, dynamic>?) ?? {},
    );
  }
}
