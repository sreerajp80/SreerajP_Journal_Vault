import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/voice_note_recorder.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/entry_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/voice_note_saver.dart';
import 'package:sreerajp_journal_vault/features/entries/services/voice_note_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class _FakeRecorder implements VoiceNoteService {
  bool permission = true;
  bool recording = false;
  int cancelCalls = 0;

  @override
  bool get isRecording => recording;

  @override
  Future<bool> startRecording() async {
    if (!permission) return false;
    recording = true;
    return true;
  }

  @override
  Future<VoiceNoteRecordingResult?> stopRecording() async {
    recording = false;
    return const VoiceNoteRecordingResult(
      filePath: 'rec.m4a',
      fileName: 'rec.m4a',
      durationMs: 3200,
    );
  }

  @override
  Future<void> cancelRecording() async {
    if (!recording) return;
    recording = false;
    cancelCalls++;
  }

  @override
  Future<void> dispose() async {}
}

class _FakeSaver implements VoiceNoteSaver {
  bool fail = false;
  final List<({int? entryId, String path, String name})> saves = [];

  @override
  Future<int> save({
    required int? entryId,
    required String recordingPath,
    required String fileName,
  }) async {
    saves.add((entryId: entryId, path: recordingPath, name: fileName));
    if (fail) throw StateError('disk full');
    return 1;
  }
}

void main() {
  late _FakeRecorder recorder;
  late _FakeSaver saver;
  VoiceNoteOutcome? outcome;
  bool closed = false;

  setUp(() {
    recorder = _FakeRecorder();
    saver = _FakeSaver();
    outcome = null;
    closed = false;
  });

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          voiceNoteServiceProvider.overrideWithValue(recorder),
          voiceNoteSaverProvider.overrideWithValue(saver),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  outcome = await showVoiceNoteRecorder(context, entryId: 5);
                  closed = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('voice-note-record')));
    await tester.pump();
  }

  testWidgets('Done saves the recording and reports it', (tester) async {
    await open(tester);
    expect(recorder.recording, isTrue);

    await tester.tap(find.byKey(const Key('voice-note-done')));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(outcome!.saved, isTrue);
    expect(outcome!.durationMs, 3200);
    expect(saver.saves.single.entryId, 5);
    expect(saver.saves.single.path, 'rec.m4a');
    expect(saver.saves.single.name, startsWith('Voice note '));
    expect(saver.saves.single.name, endsWith('.m4a'));
  });

  testWidgets('a failed save is reported, not hidden', (tester) async {
    saver.fail = true;
    await open(tester);

    await tester.tap(find.byKey(const Key('voice-note-done')));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(outcome!.saved, isFalse);
  });

  testWidgets('Discard deletes the recording and saves nothing', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.byKey(const Key('voice-note-discard')));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(outcome, isNull);
    expect(recorder.cancelCalls, 1);
    expect(saver.saves, isEmpty);
  });

  testWidgets('back while recording asks first', (tester) async {
    await open(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Stop and discard this recording?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(closed, isFalse);
    expect(recorder.recording, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('voice-note-discard-confirm')));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
    expect(recorder.cancelCalls, 1);
  });

  testWidgets('a sheet removed while recording stops the microphone', (
    tester,
  ) async {
    await open(tester);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(recorder.recording, isFalse);
    expect(recorder.cancelCalls, 1);
  });
}
