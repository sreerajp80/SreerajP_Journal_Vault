import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_models.dart';
import 'package:sreerajp_journal_vault/features/attachments/presentation/archive_attachment_view.dart';
import 'package:sreerajp_journal_vault/features/attachments/presentation/attachment_viewer_screen.dart';
import 'package:sreerajp_journal_vault/features/attachments/presentation/audio_attachment_view.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_open_service.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_temp_file_manager.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Playback that never touches a platform channel.
class _FakePlayback implements AudioPlaybackHandle {
  _FakePlayback({this.loadError});

  final Object? loadError;
  final _position = StreamController<Duration>.broadcast();
  final _playing = StreamController<bool>.broadcast();

  bool disposed = false;
  bool playCalled = false;
  bool pauseCalled = false;
  Duration? seekedTo;

  @override
  Future<Duration?> load(String filePath) async {
    if (loadError != null) throw loadError!;
    return const Duration(seconds: 90);
  }

  @override
  Future<void> play() async {
    playCalled = true;
    _playing.add(true);
  }

  @override
  Future<void> pause() async {
    pauseCalled = true;
    _playing.add(false);
  }

  @override
  Future<void> seek(Duration position) async {
    seekedTo = position;
    _position.add(position);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await _position.close();
    await _playing.close();
  }

  @override
  Stream<Duration> get positionStream => _position.stream;

  @override
  Stream<bool> get playingStream => _playing.stream;
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('viewer_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  /// Builds a session over a real file on disk, so temp-file cleanup is real.
  ///
  /// Deliberately synchronous: `testWidgets` runs in a fake-async zone where an
  /// awaited real file operation never completes.
  AttachmentOpenSession sessionFor({
    required String fileName,
    required AttachmentOpenKind kind,
    List<int> bytes = const [1, 2, 3],
    String? mimeType,
  }) {
    final file = File('${tempDir.path}${Platform.pathSeparator}$fileName');
    file.writeAsBytesSync(bytes);
    return AttachmentOpenSession(
      handle: AttachmentTempFileHandle(file: file),
      decision: AttachmentOpenDecision(kind: kind),
      fileName: fileName,
      mimeType: mimeType,
    );
  }

  Widget host(AttachmentViewerScreen screen) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: screen,
  );

  group('temp file lifetime', () {
    testWidgets('deletes the decrypted file when the viewer is disposed', (
      tester,
    ) async {
      final session = sessionFor(
        fileName: 'notes.zip',
        kind: AttachmentOpenKind.inAppArchive,
      );
      final file = File(session.filePath);
      expect(file.existsSync(), isTrue);

      await tester.pumpWidget(
        host(
          AttachmentViewerScreen(
            session: session,
            archiveEntryReader: (_) => const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tear the screen down the way popping the route would.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      // The screen releases the handle on dispose. The unlink itself is real
      // async I/O, which cannot complete inside the fake-async zone of a
      // widget test — attachment_temp_file_manager_test covers the actual
      // deletion ("removes temp files when released explicitly").
      expect(session.handle.isReleased, isTrue);
    });
  });

  group('archive body', () {
    testWidgets('lists the entries of a ZIP without extracting it', (
      tester,
    ) async {
      final session = sessionFor(
        fileName: 'backup.zip',
        kind: AttachmentOpenKind.inAppArchive,
      );

      await tester.pumpWidget(
        host(
          AttachmentViewerScreen(
            session: session,
            archiveEntryReader: (_) => const [
              ArchiveEntryInfo(
                path: 'docs/readme.txt',
                sizeBytes: 2048,
                isDirectory: false,
              ),
              ArchiveEntryInfo(path: 'docs/', sizeBytes: 0, isDirectory: true),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('archive-attachment-list')), findsOneWidget);
      expect(find.text('docs/readme.txt'), findsOneWidget);
      expect(find.text('2.0 KB'), findsOneWidget);
    });

    testWidgets('shows a recoverable message for an unreadable archive', (
      tester,
    ) async {
      final session = sessionFor(
        fileName: 'locked.zip',
        kind: AttachmentOpenKind.inAppArchive,
      );

      await tester.pumpWidget(
        host(
          AttachmentViewerScreen(
            session: session,
            archiveEntryReader: (_) => throw const FormatException('encrypted'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('archive-attachment-error')), findsOneWidget);
      expect(find.textContaining('could not be read'), findsOneWidget);
    });

    testWidgets('shows an empty state for an archive with no entries', (
      tester,
    ) async {
      final session = sessionFor(
        fileName: 'empty.zip',
        kind: AttachmentOpenKind.inAppArchive,
      );

      await tester.pumpWidget(
        host(
          AttachmentViewerScreen(
            session: session,
            archiveEntryReader: (_) => const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('archive-attachment-empty')), findsOneWidget);
    });
  });

  group('audio body', () {
    testWidgets('loads, plays, pauses and seeks', (tester) async {
      final playback = _FakePlayback();
      final session = sessionFor(
        fileName: 'voice.m4a',
        kind: AttachmentOpenKind.inAppAudio,
        mimeType: 'audio/mp4',
      );

      await tester.pumpWidget(
        host(
          AttachmentViewerScreen(
            session: session,
            playbackHandleFactory: () => playback,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('audio-attachment-player')), findsOneWidget);
      // Duration came from the fake, formatted as mm:ss.
      expect(find.text('01:30'), findsOneWidget);

      await tester.tap(find.byKey(const Key('audio-attachment-play-pause')));
      await tester.pumpAndSettle();
      expect(playback.playCalled, isTrue);

      await tester.tap(find.byKey(const Key('audio-attachment-play-pause')));
      await tester.pumpAndSettle();
      expect(playback.pauseCalled, isTrue);

      await tester.drag(
        find.byKey(const Key('audio-attachment-seek')),
        const Offset(60, 0),
      );
      await tester.pumpAndSettle();
      expect(playback.seekedTo, isNotNull);
    });

    testWidgets('shows an error body when the file cannot be played', (
      tester,
    ) async {
      final session = sessionFor(
        fileName: 'broken.m4a',
        kind: AttachmentOpenKind.inAppAudio,
      );

      await tester.pumpWidget(
        host(
          AttachmentViewerScreen(
            session: session,
            playbackHandleFactory: () =>
                _FakePlayback(loadError: Exception('bad codec')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('audio-attachment-error')), findsOneWidget);
    });

    testWidgets('releases the player when the viewer closes', (tester) async {
      final playback = _FakePlayback();
      final session = sessionFor(
        fileName: 'voice.m4a',
        kind: AttachmentOpenKind.inAppAudio,
      );

      await tester.pumpWidget(
        host(
          AttachmentViewerScreen(
            session: session,
            playbackHandleFactory: () => playback,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      expect(playback.disposed, isTrue);
    });
  });

  group('shell', () {
    testWidgets('shows the file name and the Open with... action', (
      tester,
    ) async {
      var openedExternally = false;
      final session = sessionFor(
        fileName: 'report.zip',
        kind: AttachmentOpenKind.inAppArchive,
      );

      await tester.pumpWidget(
        host(
          AttachmentViewerScreen(
            session: session,
            archiveEntryReader: (_) => const [],
            onOpenExternally: () async => openedExternally = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('report.zip'), findsOneWidget);
      await tester.tap(find.byKey(const Key('attachment-viewer-open-with')));
      await tester.pumpAndSettle();
      expect(openedExternally, isTrue);
    });

    testWidgets('hides the Open with... action when no handler is given', (
      tester,
    ) async {
      final session = sessionFor(
        fileName: 'report.zip',
        kind: AttachmentOpenKind.inAppArchive,
      );

      await tester.pumpWidget(
        host(
          AttachmentViewerScreen(
            session: session,
            archiveEntryReader: (_) => const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('attachment-viewer-open-with')),
        findsNothing,
      );
    });

    testWidgets('states the type is unsupported rather than showing nothing', (
      tester,
    ) async {
      final session = sessionFor(
        fileName: 'report.docx',
        kind: AttachmentOpenKind.unsupported,
      );

      await tester.pumpWidget(host(AttachmentViewerScreen(session: session)));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('attachment-viewer-unsupported')),
        findsOneWidget,
      );
      expect(find.text('Unsupported file type'), findsOneWidget);
    });
  });

  group('readZipEntries', () {
    test('reads a real ZIP archive off disk', () async {
      final archive = Archive()
        ..addFile(ArchiveFile.bytes('hello.txt', [104, 105]));
      final zipPath = '${tempDir.path}${Platform.pathSeparator}real.zip';
      File(zipPath).writeAsBytesSync(ZipEncoder().encodeBytes(archive));

      final entries = readZipEntries(zipPath);

      expect(entries, hasLength(1));
      expect(entries.single.path, 'hello.txt');
      expect(entries.single.sizeBytes, 2);
      expect(entries.single.isDirectory, isFalse);
    });

    test('throws a FormatException for a file that is not a ZIP', () async {
      final path = '${tempDir.path}${Platform.pathSeparator}not.zip';
      File(path).writeAsBytesSync(List<int>.filled(64, 7));

      expect(() => readZipEntries(path), throwsA(isA<FormatException>()));
    });
  });
}
