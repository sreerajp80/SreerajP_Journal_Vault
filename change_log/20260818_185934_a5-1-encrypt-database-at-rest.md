# Change log — A5.1 Encrypt the database at rest

**Date:** 2026-08-18
**Implements:** [`plans/20260818_183817_a5-1-encrypt-database-at-rest.md`](../plans/20260818_183817_a5-1-encrypt-database-at-rest.md)
**Idea:** `docs/enhancement_ideas.md` → A5.1

---

## 1. What changed, in one paragraph

The journal database is now encrypted at rest. It runs on SQLCipher with a 32-byte key held in
the Android Keystore, so entry text, titles, revisions and the whole full-text index are no
longer readable from the file itself. A vault from an older install is converted on the first
launch after the update, and the plain original is deleted only after the encrypted copy has been
verified *and* opened for real. This was the last place where journal content sat in plain form.

## 2. How it was built differently from the plan

The plan said "SQLCipher via `sqlcipher_flutter_libs`". That package was not used.

`package:sqlite3` version 3 supplies the native library itself through a Dart build hook, so
SQLCipher is now selected by four lines at the bottom of `pubspec.yaml`:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: sqlcipher
```

This is better than the planned route in one way that matters: the **test runner** gets SQLCipher
too. The plan assumed the real conversion could only be proven on a device; it is now proven on
the host, in `test/core/database/encrypted_database_test.dart`, with a real encrypted file.

Everything else followed the plan. `drift_flutter` and `sqlite3_flutter_libs` were removed as
planned — for the same reason, and it still matters: they bundle a second `libsqlite3.so`, which
can win the symbol lookup and leave the vault written in plain form with no error anywhere.

## 3. Files changed

### New — `lib/`

| File | What it does |
|---|---|
| `lib/core/database/database_key_manager.dart` | `DatabaseKey` (never logs itself) and the Keystore-backed key manager over a `MethodChannel`. |
| `lib/core/database/encrypted_database_opener.dart` | Opens the vault, converts a plain one, and refuses to run if the cipher is not real. |
| `lib/core/database/plain_database_converter.dart` | The file half of the conversion: the swap order, and repair of an interrupted run. |
| `lib/core/database/database_open_failure.dart` | The four ways the vault can fail to open. |
| `lib/app/vault_unavailable_app.dart` | The screen shown when it does. |

### New — tests

| File | What it covers |
|---|---|
| `test/core/database/encrypted_database_test.dart` | The real conversion: plaintext is gone from the file, rows and schema version survive, search still works, the wrong key fails. Plus the opener end to end. |
| `test/core/database/plain_database_converter_test.dart` | The swap, the failure path, and all three crash-recovery states, with a forced-failure conversion step. |
| `test/core/database/database_key_manager_test.dart` | The channel contract, especially the `createIfMissing` flag. |
| `test/app/vault_unavailable_screen_test.dart` | Each failure gets its own words — and the screen offers nothing to press. |
| `integration_test/encrypted_database_test.dart` | Device only: the Keystore returns a stable usable key, and `libsqlcipher.so` really shipped. |

### Changed

| File | Change |
|---|---|
| `pubspec.yaml` | Removed `drift_flutter` and `sqlite3_flutter_libs`; added `sqlite3` directly and the `hooks:` block selecting the SQLCipher build. |
| `lib/main.dart` | Opens through `EncryptedDatabaseOpener`; on failure shows `VaultUnavailableApp` instead of starting. |
| `android/.../MainActivity.kt` | New `sreerajp.journal_vault/database_key` channel, its own Keystore wrapping alias and prefs file, `SecureRandom`, and `commit()` rather than `apply()` so the key is on disk before it is used. |
| `lib/l10n/app_en.arb` | Seven strings for the failure screen. |
| `docs/security.md` | M9 closed; sections 4, 5, 6 and 17 rewritten. |
| `docs/architecture.md` | Sections 3, 8, 14, 18, 20 and the section 21 gap list. |
| `docs/dependencies.md` | The dependency swap, and why the `hooks:` line is security configuration. |
| `docs/release_process.md` | A checklist item: the APK must carry `libsqlcipher.so` and no `libsqlite3.so`. |
| `docs/enhancement_ideas.md` | A5.1 ticked; the B3 "soft centre" paragraph closed. |
| `README.md`, `CLAUDE.md`, `AGENTS.md` | The database line, and a hard rule against re-adding the removed packages. |

## 4. How an existing vault is converted

Nothing is written over. In order:

1. Repair anything an earlier interrupted run left behind (see below).
2. If the file starts with the plain SQLite header, copy it out with `sqlcipher_export` into
   `journal_vault.sqlite.converting`.
3. Verify that copy: cipher present, `integrity_check` ok, same `user_version`, same row count in
   every user table. Rebuild both FTS indexes.
4. Rename the original to `journal_vault.sqlite.plain-backup`, then the copy into its place.
5. Open the encrypted vault for real. Only then delete the plain backup.

A crash can leave three states, and the next start repairs all three: a half-written
`.converting` file is thrown away; a missing vault with a `.plain-backup` present is restored; a
healthy vault with a leftover `.plain-backup` has the duplicate removed.

If the conversion fails at any point, the plain original is left exactly as it was and the app
shows the failure screen rather than starting with an empty vault.

## 5. Two costs, stated plainly

- **Losing the Keystore key now loses the journal.** There is no password fallback by design —
  a PIN-derived key would not work in `phone_lock` mode and would need a full re-key on every PIN
  change. When the key is gone the app says so and points at restore-from-backup. It never
  offers to wipe.
- **The APK grew.** `libsqlcipher.so` is about 4.9 MB per ABI. The arm64 release APK measured
  32.2 MB. Builds are already split per ABI, so a user downloads one copy.

Reads are also slower, FTS5 most of all, since every page is decrypted. Not measured on a device
yet — see section 7.

## 6. Verification

- `flutter analyze` — no issues.
- `flutter test` — **586 tests pass**, including the new ones. One of them opens a converted vault
  and confirms the entry text can no longer be found in the file's bytes.
- `dart format lib test integration_test` — clean.
- `flutter build apk --flavor dev --debug` and a release build with `--obfuscate
  --split-debug-info --split-per-abi`: both carry `lib/<abi>/libsqlcipher.so` for all three ABIs
  and **no** `libsqlite3.so`.

## 7. Not done, and why

- **No run on a real device.** No Android device was attached to this machine. The on-device
  integration test is written and ready:
  `flutter test integration_test/encrypted_database_test.dart -d <device>`. It should be run,
  along with a manual launch of both flavors, before this is treated as shipped.
- **The prod release build could not be produced here.** It fails at
  `validateSigningProdRelease` because the keystore named in `android/key.properties` does not
  exist on this machine. That is the pre-existing release blocker in `architecture.md` section
  21, not something this change caused. The release path was exercised instead by building with
  the debug-key fallback.
- **The attachment key still uses `kotlin.random.Random`.** Found while reading `MainActivity.kt`
  for this change and raised before implementation; it was kept out of scope. The new database
  key uses `SecureRandom`. Now recorded as an open item in `docs/security.md` section 17.
- **Re-keying the database** was out of scope, as planned.
