import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_temp_file_manager.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/inline_image_store.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('inline_image_store_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  /// A stand-in for a decrypted plaintext file in the app cache.
  AttachmentTempFileHandle makeHandle(String name) {
    final file = File('${tempDir.path}${Platform.pathSeparator}$name')
      ..writeAsBytesSync([1, 2, 3]);
    return AttachmentTempFileHandle(file: file);
  }

  const source = InlineImageSource(
    fileName: 'beach.jpg',
    encryptedPath: 'enc/1.bin',
    nonceBase64: 'bm9uY2U=',
    keyReference: 'key-1',
  );

  InlineImageStore buildStore({
    Future<InlineImageSource?> Function(int)? loadSource,
    Future<bool> Function(int)? isLocked,
    Future<AttachmentTempFileHandle> Function(InlineImageSource)? decrypt,
    Future<bool> Function(String)? authenticate,
  }) {
    return InlineImageStore(
      loadSource: loadSource ?? (_) async => source,
      isLocked: isLocked ?? (_) async => false,
      decrypt: decrypt ?? (_) async => makeHandle('plain.jpg'),
      authenticate: authenticate ?? (_) async => true,
    );
  }

  test('resolves an unlocked image to a ready file', () async {
    final store = buildStore();

    final state = await store.resolve(1);

    expect(state, isA<InlineImageReady>());
    expect((state as InlineImageReady).file.existsSync(), isTrue);
  });

  test('decrypts once and reuses the result', () async {
    var decryptCount = 0;
    final store = buildStore(
      decrypt: (_) async {
        decryptCount++;
        return makeHandle('plain_$decryptCount.jpg');
      },
    );

    await store.resolve(1);
    await store.resolve(1);
    await store.resolve(1);

    expect(decryptCount, 1);
  });

  test('two embeds asking at the same time share one decryption', () async {
    var decryptCount = 0;
    final store = buildStore(
      decrypt: (_) async {
        decryptCount++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return makeHandle('plain_$decryptCount.jpg');
      },
    );

    await Future.wait([store.resolve(1), store.resolve(1)]);

    expect(decryptCount, 1);
  });

  test('a locked attachment is never decrypted', () async {
    var decryptCalled = false;
    final store = buildStore(
      isLocked: (_) async => true,
      decrypt: (_) async {
        decryptCalled = true;
        return makeHandle('plain.jpg');
      },
    );

    final state = await store.resolve(1);

    expect(state, isA<InlineImageLocked>());
    expect(decryptCalled, isFalse);
  });

  test('unlock decrypts once authentication succeeds', () async {
    final store = buildStore(isLocked: (_) async => true);

    expect(await store.resolve(1), isA<InlineImageLocked>());

    final unlocked = await store.unlock(1);

    expect(unlocked, isA<InlineImageReady>());
    expect(store.isUnlocked(1), isTrue);
    // The unlocked result replaces the cached locked one.
    expect(await store.resolve(1), isA<InlineImageReady>());
  });

  test('a refused prompt leaves the image locked', () async {
    var decryptCalled = false;
    final store = buildStore(
      isLocked: (_) async => true,
      authenticate: (_) async => false,
      decrypt: (_) async {
        decryptCalled = true;
        return makeHandle('plain.jpg');
      },
    );

    expect(await store.unlock(1), isA<InlineImageLocked>());
    expect(store.isUnlocked(1), isFalse);
    expect(decryptCalled, isFalse);
  });

  test('a lock check that fails is treated as locked', () async {
    final store = buildStore(isLocked: (_) async => throw Exception('no db'));

    expect(await store.resolve(1), isA<InlineImageLocked>());
  });

  test('a deleted attachment row resolves to unavailable', () async {
    final store = buildStore(
      loadSource: (_) async => throw StateError('no such row'),
    );

    expect(await store.resolve(99), isA<InlineImageUnavailable>());
  });

  test('a failed decrypt resolves to unavailable', () async {
    final store = buildStore(decrypt: (_) async => throw Exception('bad mac'));

    expect(await store.resolve(1), isA<InlineImageUnavailable>());
  });

  test('dispose deletes every decrypted copy', () async {
    var counter = 0;
    final store = buildStore(
      decrypt: (source) async => makeHandle('${counter++}_${source.fileName}'),
    );

    final first = await store.resolve(1) as InlineImageReady;
    final second = await store.resolve(2) as InlineImageReady;
    expect(first.file.existsSync(), isTrue);
    expect(second.file.existsSync(), isTrue);

    await store.dispose();

    expect(first.file.existsSync(), isFalse);
    expect(second.file.existsSync(), isFalse);
  });

  test('a decrypt finishing after dispose deletes its own file', () async {
    late AttachmentTempFileHandle handle;
    final store = buildStore(
      decrypt: (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        handle = makeHandle('late.jpg');
        return handle;
      },
    );

    final pending = store.resolve(1);
    store.dispose();

    expect(await pending, isA<InlineImageUnavailable>());
    expect(handle.file.existsSync(), isFalse);
  });
}
