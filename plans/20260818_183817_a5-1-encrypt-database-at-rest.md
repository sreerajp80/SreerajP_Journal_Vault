# A5.1 — Encrypt the database at rest (SQLCipher)

**Status:** completed

**Idea:** `docs/enhancement_ideas.md` → A5.1. Effort **XL**.
**Related gaps:** `docs/security.md` sections 3, 17 and OWASP **M9**;
`docs/architecture.md` section 21 ("Still open — Sensitive Data").

---

## 1. The issue

Today only attachments are encrypted. The Drift/SQLite database file sits in the app-private
directory in **plain form**. That file holds:

- every entry title, `content_json` and `plain_text`,
- the whole FTS5 index (`entries_fts`, `attachment_text_fts`) — a second plain copy of the text,
- entry revisions, extracted attachment text, moods and notes.

Anyone with root, a custom recovery, or an offline flash dump reads the whole journal with a free
SQLite browser. The app's headline claim is "a security-hardened vault", so plain entry bodies are
the weakest part of that claim.

Two real costs, both accepted here on purpose:

1. **Speed.** Every page read is decrypted. FTS5 over SQLCipher is measurably slower.
2. **Migration risk.** An existing vault must be converted in place. If the conversion is not
   flawless, the user loses everything. This plan spends most of its care there.

---

## 2. What will be built

### 2.1 The cipher

- **SQLCipher 4** through `sqlcipher_flutter_libs`, driven by Drift's `NativeDatabase`.
- The key is a **32-byte random key held in the Android Keystore**, handed to SQLCipher as a raw
  key (`PRAGMA key = "x'<64 hex chars>'"`). A raw key skips SQLCipher's PBKDF2 step, so opening
  the vault stays fast and the key never depends on a user password.
- Key generation, wrapping and storage copy the pattern already proven in `MainActivity.kt`: the
  raw key is AES-256-GCM wrapped under a Keystore-resident key, and only `iv:ciphertext` goes to
  SharedPreferences. New wrapping-key alias, new prefs file — nothing existing is reused or
  disturbed.
- One difference from the existing code: the new key is drawn from `java.security.SecureRandom`,
  not `kotlin.random.Random`. See section 7, question 1.

### 2.2 Why a Keystore key and not the user's PIN

The app supports `phone_lock` mode, where there is no app PIN at all, and the PIN can be changed.
Deriving the database key from the PIN would mean the vault cannot open in `phone_lock` mode, and
must be fully re-keyed on every PIN change. A Keystore-held key is the right fit and matches how
attachment keys already work. This will be stated plainly in `security.md`: it protects against
**offline** attack (flash dump, stolen device, backup extraction), not against malware already
running as this app on an unlocked, rooted phone.

### 2.3 Converting an existing vault

On startup the opener looks at `journal_vault.sqlite`:

| What it finds | What it does |
|---|---|
| No file | Create a new encrypted database. Nothing to convert. |
| First 16 bytes are the plain SQLite header | Plain database → run the conversion below. |
| Anything else | Already encrypted → open it with the key. |

The conversion never writes over the original file:

1. Open the plain file with SQLCipher **without a key** — SQLCipher reads plain databases fine
   when no key is set.
2. `ATTACH DATABASE '<db>.converting' AS enc KEY "x'…'"`, then `SELECT sqlcipher_export('enc')`,
   then copy `user_version` across explicitly, then `DETACH`.
3. Close everything. Open `<db>.converting` **with the key** and verify it: `cipher_version()` is
   non-empty, `PRAGMA integrity_check` returns `ok`, `user_version` matches, and the row counts of
   the main user tables match the source. Rebuild both FTS indexes from their content tables
   (`INSERT INTO entries_fts(entries_fts) VALUES('rebuild')`) so search cannot be left stale.
4. Only after all of that passes: rename the original to `<db>.plain-backup`, rename
   `<db>.converting` to `<db>`, open it normally, and **only then** delete `<db>.plain-backup`.
5. If any step fails: delete `<db>.converting`, leave the original untouched, report the failure.

**Crash recovery.** Every startup first cleans up leftovers, so a conversion killed halfway is
always recoverable:

- `<db>.converting` present → delete it and start again.
- `<db>` missing but `<db>.plain-backup` present → the crash landed between the two renames;
  rename the backup back and start again.
- `<db>` present and encrypted, `<db>.plain-backup` still there → the crash landed after the swap;
  the vault is fine, just delete the leftover plain copy.

Attachment files, voice notes and their keys are **not** touched. They are already encrypted with
their own keys and live outside the database.

### 2.4 When the vault cannot be opened

If the Keystore key is gone (Keystore wiped, prefs lost, key invalidated) the database cannot be
read by anyone, including the app. Today that would be a crash loop. Instead `main.dart` catches
the failure and shows a small "vault cannot be opened" screen that says what happened and points
at restore-from-backup. It offers **no** destructive action — no silent wipe, ever.

### 2.5 Tests

Host `flutter test` cannot exercise SQLCipher — there is no cipher library on the desktop test
runner — so the work is split:

- **Unit (host).** The conversion orchestration is written against an injectable "convert this
  file" step, so the file swap, the failure path and all three crash-recovery states are tested
  with a fake step and real files. Plus the plain/encrypted header detection.
- **Integration (device).** A new `integration_test/encrypted_database_test.dart`: build a plain
  database with journals, entries and attachment text, run the real conversion, then assert the
  file no longer starts with the plain SQLite header, `cipher_version()` is non-empty, every row
  survived, and FTS search still finds the entry.
- Existing tests keep using `NativeDatabase.memory()` unchanged. Encryption applies at the app's
  real open path only, so the 44 existing test files stay as they are.

---

## 3. Files to be changed

**New**

| File | Why |
|---|---|
| `lib/core/database/database_key_manager.dart` | The key abstraction plus the Keystore-backed implementation over a `MethodChannel`. |
| `lib/core/database/encrypted_database_opener.dart` | Loads the cipher library, opens or creates the encrypted database, verifies the cipher is really on. |
| `lib/core/database/plain_database_converter.dart` | The plain → encrypted conversion, its verification and its crash recovery. |
| `lib/core/database/database_open_failure.dart` | The typed failure returned when the vault cannot be opened. |
| `lib/app/vault_unavailable_app.dart` | The "vault cannot be opened" screen. |
| `test/core/database/plain_database_converter_test.dart` | Swap, failure and recovery tests. |
| `test/core/database/database_key_manager_test.dart` | Channel contract test with a mock channel. |
| `integration_test/encrypted_database_test.dart` | The real end-to-end conversion on a device. |

**Changed**

| File | Change |
|---|---|
| `pubspec.yaml` | Add `sqlcipher_flutter_libs`; remove `drift_flutter` and `sqlite3_flutter_libs`. |
| `lib/main.dart` | Build the database through the encrypted opener; handle the failure path. |
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` | New database-key channel, new wrapping alias, `SecureRandom`. |
| `lib/l10n/app_en.arb` | Strings for the "vault cannot be opened" screen. |
| `docs/security.md` | M9 moves from risk-accepted to closed; sections 3 and 17 rewritten. |
| `docs/architecture.md` | Section 21 gap closed; the database section notes the cipher. |
| `docs/enhancement_ideas.md` | Tick A5.1 with its date, plan and change log. |
| `docs/dependencies.md` | Record the dependency swap and why the two sqlite libraries cannot coexist. |
| `CLAUDE.md`, `AGENTS.md`, `README.md` | The database line now says "encrypted (SQLCipher)". |

**Why `drift_flutter` and `sqlite3_flutter_libs` must go:** they bundle `libsqlite3.so`, which
exports the same symbols as `libsqlcipher.so`. With both in the APK the loader can bind the app to
plain SQLite, and the database would be written **unencrypted without any error**. `drift_flutter`
is used in exactly one line of `main.dart`; the new opener replaces it. The runtime
`cipher_version()` check is the belt-and-braces guard against this ever happening quietly.

---

## 4. Order of work

1. Dependency swap; confirm the app still builds and runs on a device.
2. Kotlin key channel plus the Dart key manager, with tests.
3. The opener, with the `cipher_version()` guard. A fresh install now writes an encrypted vault.
4. The converter, its recovery states and its host tests.
5. The failure screen and its ARB strings.
6. The device integration test.
7. `flutter analyze`, `flutter test`, `dart format`, and a manual run of both flavors.
8. Docs, then the change log.

---

## 5. Risks

| Risk | Handling |
|---|---|
| Conversion loses data | The original is never overwritten; the copy is verified before the swap and the original deleted only after a good open; all three crash states recover on the next start. |
| Plain SQLite silently wins the symbol clash | Both plain sqlite packages removed, and `cipher_version()` checked on every open — an unencrypted open throws instead of writing plaintext. |
| Keystore key lost → vault unreadable | An honest failure screen pointing at restore-from-backup. This is inherent to encryption at rest and will be stated in `security.md`. |
| FTS5 slower | Accepted, and measured on a device in step 7. Search stays capped at 100 rows. |
| APK grows (SQLCipher plus OpenSSL, per ABI) | Accepted; the build is already `--split-per-abi`. The size change is recorded in the change log. |
| Existing installs on a device | A dev build over a real install already destroys data (section 21). Nothing new here, but the conversion is exercised on a real device before this is called done. |

---

## 6. Out of scope

- Re-keying (changing the database key) — no user need yet.
- The A5.2 attachment crypto version byte, or any other change to attachment storage.
- Any change to backup or export. Backups export **rows**, not the database file, so the format is
  untouched and existing backups still restore.

---

## 7. Open questions for approval

1. **The attachment key is generated with `kotlin.random.Random`, not a secure RNG**
   (`MainActivity.kt`, `getAttachmentKey`). That is a genuine weakness in existing code, found
   while reading it for this work. The new database key will use `SecureRandom` either way.
   Should the attachment key be fixed in the same pass? It is a two-line change, and it only
   affects keys generated **after** the fix — existing attachments keep their existing key, so
   nothing breaks.
2. **Confirm the Keystore-held key over a PIN-derived key** (section 2.2). Keystore is the
   recommendation.
