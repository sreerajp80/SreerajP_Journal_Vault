# Security — SreerajP Journal Vault

> **This is the local copy.** It overrides `docs/guidelines/security.md` for this app, per the
> "local copy wins" rule in [`GUIDELINES_MANIFEST.md`](GUIDELINES_MANIFEST.md).
>
> Sections marked `TODO` are not yet decided. They are left open on purpose rather than filled
> with content that would read as a completed review when no review happened.

Last reviewed: 2026-08-16 · Reviewer: Sreeraj P (with Claude)

> **2026-08-16 update:** entry and journal export was added (A1.1 / W5). It is the first
> feature that deliberately writes journal content out of the vault unencrypted. See
> section 14 for the controls around it and the residual risks accepted.

## 1. Security Scope

- App: `SreerajP_Journal_Vault`
- Data sensitivity level: **high** — the app's entire content is a private personal diary,
  plus arbitrary user attachments.
- Engineering standard profiles in force: `Core Baseline`, `Production App Extension`,
  `Sensitive Data Extension` (all three — see [`architecture.md`](architecture.md) section 1)
- Platforms in scope: **Android** only (minimum API 28). Flutter scaffolding exists for iOS,
  Windows, Linux, macOS but none is a supported target, and none has been security-reviewed.

---

## 2. Security Objectives

- Protect journal content and attachments from casual extraction on a lost, stolen, or borrowed
  device.
- Prevent accidental disclosure through screenshots, the task switcher, cloud backup, logs, or
  exports.
- Keep the data recoverable by its owner — encryption must never become the reason the user
  loses their own journal.
- Meet the OWASP Mobile Top 10 controls that apply to a fully offline, single-user app.

---

## 3. Threat Model Summary

### In scope

- **Lost or stolen device.** Someone picks up an unlocked or locked phone and tries to read the
  journal. Mitigated by app lock, per-journal lock, at-rest encryption, and Keystore-held keys.
- **Casual local access.** Someone who legitimately has the unlocked phone (family, colleague)
  opens the app. Mitigated by app lock and auto-lock on background.
- **Shoulder surfing and screen capture.** Mitigated by `FLAG_SECURE` (added 2026-07-25), which
  also blanks the task-switcher preview. Since 2026-08-18 the user can switch this off in
  Settings ("Block Screenshots"). It is on by default, turning it off asks for confirmation
  first, and every change is written to the security event log. With it off this threat is not
  mitigated — that is the user's accepted choice.
- **Accidental cloud disclosure.** Android auto-backup copying the database off-device.
  Mitigated by `allowBackup="false"` and `data_extraction_rules.xml` (added 2026-07-25).
- **Accidental plaintext leakage.** Decrypted attachments left in the temp cache after viewing.
  Mitigated by `AttachmentTempFileManager` and a startup orphan sweep.
- **Casual reverse engineering.** Reading class and method names out of the release binary.
  Mitigated by `--obfuscate` and R8 (added 2026-07-25).

### Out of scope

- **Rooted or compromised device.** Root defeats Keystore protections in practice. No root
  detection is implemented and none is planned.
- **A compromised OS or malicious keyboard.** Anything with system privileges can read what the
  user types.
- **Physical hardware attacks.** Chip-off, JTAG, cold-boot.
- **Forensic memory capture of a running, unlocked app.** Decrypted content is in memory while
  a journal is open, by necessity.
- **Targeted or state-level adversaries.** This is a personal journal app, not a threat-model
  match for that.

---

## 4. Sensitive Data Inventory

| Data type | Example | Where it exists | Protection |
|---|---|---|---|
| Journal entry content | Diary text, titles | Drift/SQLCipher DB, app-private storage | AES-256 encrypted at rest, Keystore-held key; plus the OS app sandbox |
| Attachments | PDFs, audio, archives | Encrypted files, app-private or SD card | AES-256-GCM, Keystore-backed key |
| Attachment plaintext (transient) | Decrypted PDF being viewed | App cache directory | Deleted on close, background, and startup sweep |
| App PIN | The user's unlock PIN | Never stored | PBKDF2 verifier only, 100,000 iterations, 16-byte random salt |
| PIN salt + verifier | — | SharedPreferences | Keystore-wrapped (AES-GCM) before storage |
| Journal secrets | Per-journal lock secrets | SharedPreferences | Keystore-wrapped (AES-GCM) before storage |
| Attachment encryption keys | AES-256 keys | Android Keystore | Never leave secure hardware |
| Attachment nonces | Per-file GCM nonce | Drift DB, alongside the attachment row | Not secret; unique per file |
| Database encryption key | The SQLCipher raw key | Android Keystore, wrapped copy in SharedPreferences | 32 bytes from `SecureRandom`, AES-GCM wrapped under a Keystore key |
| Search index | Entry title + plain text | FTS5 tables in the same DB | Same protection as the DB — encrypted with it, page for page |
| Backups | Full export archive | User-chosen location | AES-256-GCM encrypted ZIP |
| Voice notes | Recorded audio | Same path as attachments | Same as attachments |
| Dictation | Live microphone audio and the recognised text | Nowhere — the audio stays inside the on-device recogniser; the text lives only in the dictation sheet until the user inserts it into the entry | On-device recognition only (see the note below); never logged |

> **Note on dictation.** `speech_to_text` wraps Android's `SpeechRecognizer`. When on-device
> recognition is missing, the plugin silently uses the default recogniser, which on most phones
> is an online service. So `DictationService` first asks `MainActivity` (channel
> `sreerajp.journal_vault/speech`, `SpeechRecognizer.isOnDeviceRecognitionAvailable`, API 31+)
> and refuses to start when the answer is no. `PluginSpeechEngine.listen` always passes
> `onDevice: true`. Network or server errors from the recogniser end dictation and are never
> retried. Tests: `test/features/entries/services/dictation_service_test.dart` and
> `speech_engine_test.dart`. Voice notes no longer run speech recognition at all.

> **Note on the FTS index.** `entries_fts` holds a copy of entry titles and plain text. Any
> control applied to the entries table must be applied to the FTS tables too, or the index
> becomes a plaintext bypass of it. Since 2026-08-18 the index lives inside the encrypted
> database, so it is covered by the same key — but the rule still stands for anything new.

---

## 5. Storage Model

### At rest

- Primary local storage: Drift over **SQLCipher**, app-private directory. Every page of the
  database file — entry text, titles, revisions, and the whole FTS index — is AES-256 encrypted.
  Added 2026-08-18 (A5.1); before that the file was plain SQLite.
- Database key: 32 random bytes from `SecureRandom`, generated on first launch, wrapped by a
  Keystore key and stored only as `iv:ciphertext`. It is handed to SQLCipher as a **raw key**, so
  no password derivation is involved and no user password can unlock the file.
- Which library: chosen at build time by the `hooks:` block in `pubspec.yaml`, which tells
  `package:sqlite3` to use its SQLCipher build. Changing that line changes whether journal text
  is encrypted, so the app also checks `PRAGMA cipher_version` on every open and refuses to run
  if plain SQLite answers.
- Existing vaults: a database from an older, unencrypted install is converted on first launch —
  copied out with `sqlcipher_export`, verified, then swapped in. The plain original is deleted
  only after the encrypted vault has opened. See
  `lib/core/database/plain_database_converter.dart`.
- Secure key storage: Android Keystore via a `MethodChannel` in `MainActivity.kt`. Keys are
  generated with `KeyGenParameterSpec`, AES-256, GCM, `setRandomizedEncryptionRequired(true)`,
  and never leave the Keystore.
- Wrapped secrets: `SharedPreferences` stores only `iv:ciphertext`, produced by `wrapPayload()`.
  The plaintext secret never reaches disk. This satisfies section 15.2 of the engineering
  standard despite SharedPreferences being involved.
- Backup behavior: **disabled**. `android:allowBackup="false"` plus
  `res/xml/data_extraction_rules.xml` excluding every domain from both cloud backup and
  device-to-device transfer.

### In memory

- Decrypted attachment bytes and entry content are held while a screen is open.
- Memory clearing strategy: **TODO.** Dart strings are immutable and garbage-collected; there is
  no explicit zeroing of key material or decrypted buffers. Accepted for the stated threat model
  (memory capture of a running app is out of scope), but not formally reviewed.

### In transit

- Cloud, server and third-party network use: **none.** There is no HTTP client in
  `pubspec.yaml`, no analytics, and no crash reporter. CI enforces this with
  `tool/check_no_internet_permission.sh`.
- Local network use: **Wi-Fi Sync only** (added 2026-08-24). Two devices on the same Wi-Fi or
  hotspot talk over a direct TCP socket. Nothing is sent to any other host.
  - Pairing uses a 16-character high-entropy code, shown as a QR code, from which both sides
    derive a session key with PBKDF2-HMAC-SHA256 over a random 16-byte salt.
  - Every payload on the wire is sealed with AES-256-GCM (random 12-byte nonce, 16-byte tag), so
    the LAN is treated as hostile. Attachments are decrypted on the sender and re-encrypted into
    the receiver's own Keystore-managed vault.
  - `lib/features/sync/services/bounded_line_reader.dart` caps payload size and applies timeouts,
    to blunt memory-exhaustion and hang attacks from a malicious peer on the same network.
  - The host binds an ephemeral port and holds a single-client lock; the client must solve a
    cryptographic challenge before any record is transferred.

---

## 6. Cryptography Design

- Encryption algorithm: **AES-256-GCM** for attachments (Dart `cryptography` package) and for
  Keystore wrapping (Android `Cipher`, `AES/GCM/NoPadding`, 128-bit tag). The database itself is
  **AES-256-CBC with HMAC-SHA512 per page**, which is SQLCipher 4's default profile.
- Key derivation: **PBKDF2**, 100,000 iterations, 16-byte cryptographically random salt, for the
  app PIN verifier. The raw PIN is never stored or transmitted.
- Nonce/IV strategy: fresh random nonce per attachment (`_algorithm.newNonce()`), stored
  alongside the attachment row rather than in the file. Keystore wrapping uses a fresh random IV
  per operation, enforced by `setRandomizedEncryptionRequired(true)`.
- Attachment file layout: `ciphertext || mac`, with the nonce held separately in the database.
- Format versioning: **NOT IMPLEMENTED — see section 17.** The attachment file has no version
  byte or header. Backups do carry a `version` field in `manifest.json`.

### Rules

- Keys, IVs, salts, and passwords are not hardcoded anywhere. Verified by inspection.
- Randomness uses the platform CSPRNG in the Dart paths, in SQLCipher, and in the Kotlin database
  key path (`SecureRandom`). **One exception:** the *attachment* key in `MainActivity.kt` is
  generated with `kotlin.random.Random`, which is not a cryptographic generator. Listed in
  section 17.

---

## 7. Authentication And Access Control

- App-lock strategy: two **mutually exclusive** modes — device credential (`local_auth`) or a
  separate app PIN. Changing mode disables the other, behind a confirmation dialog.
- Optional per-journal lock on top of the app lock.
- Optional per-attachment lock requiring re-auth before decrypt-to-temp.
- Fallback behavior: biometric failure falls back to device credential.
- Background lock rule: `AppLockController` observes lifecycle and relocks. Auto-lock profiles
  (immediate / 30 s / custom) are user-configurable.
- Session-expiry rule: governed by the active auto-lock profile.
- Protected-route strategy: a lock gate wraps the whole app shell; there are no unprotected
  routes past it.
- Lock screen implementation: `lib/features/lock_gate/`.

---

## 8. Binary Protections

### 8.1 Obfuscation

Release builds MUST use:

```bash
--obfuscate --split-debug-info=build/symbols/android-<version>/
```

Verified working 2026-07-25. Symbols are produced per ABI (arm, arm64, x64), are git-ignored via
`/build/symbols/`, and MUST be archived per released version — without them a crash report from
an obfuscated build cannot be symbolicated.

### 8.2 R8 / ProGuard

Enabled 2026-07-25 (`isMinifyEnabled = true`). Keep rules live in `android/app/proguard-rules.pro`
and cover the Flutter engine, this app's method channels, `androidx.documentfile`, and the crypto
classes, plus `-dontwarn com.google.android.play.core.**`.

> **Not yet runtime-verified.** R8 has never run against this app on a device. Plugins with
> native code (`pdfrx`, `just_audio`, `record`, `speech_to_text`,
> `local_auth`, `permission_handler`, `file_picker`) could still fail with
> `ClassNotFoundException` in a release build. See the smoke-test list in
> [`release_process.md`](release_process.md).

### 8.3 Debuggable flag

Verified 2026-07-25: `android:debuggable` is absent from the merged `prodRelease` manifest, which
means `false`. Re-verify before every release.

---

## 9. Logging And Telemetry Policy

- **Telemetry: none.** No analytics, no crash reporting, no network calls of any kind.
- Logger: `AppLogger` (`lib/core/logging/app_logger.dart`), added 2026-07-25.
- Verbose gate: `AppFlavorConfig.enableVerboseLogging`, true only for the `dev` flavor. An
  unflavored build defaults to `prod`, so verbose logging is never enabled by accident.
- Log level in production: `info` and above.
- Output: **console only, no log file.** Deliberate — a log file in an encrypted journal app is
  another place for content to leak, and nothing needs post-hoc log retrieval. This is why
  section 13 has no log-file retention row.
- Redaction: `AppLogger.redact()` returns `[redacted N chars]` for values that might carry user
  data.

### Never log

Journal titles or text, attachment names or bytes, PINs, passwords, salts, verifiers, key
material, decrypted content of any kind, or whole database rows.

### Allowed

Operation name, screen or flow name, error category, non-sensitive counts and identifiers.

> **Open item.** The logger exists and `main()` uses it, but the rest of the codebase has not
> been audited for pre-existing `debugPrint` calls or for log statements that predate this
> policy. See section 17.

---

## 10. Platform Security Controls

### Android

- `android:allowBackup`: **false**. The database and wrapped key material must not reach Google's
  cloud backup.
- `android:dataExtractionRules`: `@xml/data_extraction_rules`, excluding `root`, `file`,
  `database`, `sharedpref`, and `external` from both `cloud-backup` and `device-transfer`.
  Needed because on API 31+ `allowBackup="false"` alone does not stop device-to-device transfer.
- Screenshot protection: `FLAG_SECURE` set on the window in `MainActivity.onCreate`, app-wide.
  Applied once rather than per screen because every screen can show private content. Side effect:
  screenshots are impossible anywhere in the app and the task-switcher preview is blank.
  The user may turn this off in Settings. The choice is kept in the app's own native
  SharedPreferences file (`screen_security`, key `enabled`) so `onCreate` can read it before the
  first frame; a missing or unreadable value means protected. The Settings switch reaches the
  native side through the `sreerajp.journal_vault/screen_security` MethodChannel, which saves the
  value and applies or clears the flag on the live window at once.
- `android:debuggable`: false in release (verified — section 8.3).
- Cleartext traffic: off. minSdk 28 makes `usesCleartextTraffic` default to `false`, the manifest
  does not change it, and there is no network security config. Wi-Fi Sync is a raw TCP socket
  sealed with AES-256-GCM, not HTTP. No user-certificate trust anchors may be added.
- Exported components: only `.MainActivity`, which must be exported for the launcher, inbound
  share (`SEND`, `SEND_MULTIPLE`) and `VIEW` of `.jvenc` / `.jvbk` files. Shared content only reaches
  a quick-capture dialog behind the lock gate; an opened archive still needs its password.
  `UCropActivity` has no intent filter and is not exported. Audit steps:
  [`release_process.md`](release_process.md) section 6.7.
- Bundled assets: `assets/` is readable by anyone holding the APK. It holds only the About config,
  fonts, OCR language models and icon sources — no secret, key or personal data. Audit steps:
  [`release_process.md`](release_process.md) section 6.6.
- Root detection: none, and none planned. Rooted devices are out of scope (section 3).

### iOS / Windows / Linux / macOS

Not supported targets. No security controls implemented or reviewed. If any becomes a real
target, this document must be redone for it — in particular iOS Keychain persistence across
uninstall, and the "will resign active" overlay for screen capture.

---

## 11. Permissions

Read from the merged `prodRelease` manifest on 2026-07-25 — the source manifest declares only
two; the rest arrive transitively from plugins.

| Permission | Declared by | Why | Denial handling |
|---|---|---|---|
| `USE_BIOMETRIC` | app | Biometric app unlock | Falls back to device credential or PIN |
| `READ_EXTERNAL_STORAGE` (maxSdk 32) | app | Attachment import on older Android | Permissions screen explains and links to settings |
| `READ_MEDIA_IMAGES` / `_VIDEO` / `_AUDIO` | `file_picker` | Attachment import on API 33+ | As above |
| `RECORD_AUDIO` | app (also `record`) | Voice notes and on-device dictation | Voice notes and dictation unavailable; rest of app works |
| `CAMERA` | app | Capturing a page for on-device OCR (`uses-feature` marked not required) | OCR falls back to picking an existing photo |
| `USE_FINGERPRINT` | `local_auth` | Legacy biometric API | Falls back |
| `ACCESS_NETWORK_STATE` | Wi-Fi Sync | **Declared** — lets Wi-Fi Sync see whether a local network is up | Wi-Fi Sync unavailable; rest of app works |
| `WAKE_LOCK` | plugin (transitive) | **Removed** (`tools:node="remove"`) | n/a |
| `INTERNET` | Wi-Fi Sync / dev | **Declared** — required to bind a local TCP socket. No cloud, no server, no HTTP client | Wi-Fi Sync unavailable; rest of app works |
| `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | Flutter/androidx | Internal broadcast safety | n/a |

> **Hardened 2026-08-23 (A5.3).** `INTERNET`, `ACCESS_NETWORK_STATE`, and `WAKE_LOCK` were
> explicitly removed via `tools:node="remove"` in `android/app/src/main/AndroidManifest.xml`.
>
> **Policy changed 2026-08-24 (Wi-Fi Sync).** Wi-Fi Sync opens a direct device-to-device TCP
> socket on the user's own LAN, so `INTERNET` and `ACCESS_NETWORK_STATE` are now declared on
> purpose. `WAKE_LOCK` is still stripped. `tool/check_no_internet_permission.sh` enforces the new
> policy in CI: `WAKE_LOCK` stripped; `INTERNET` and `ACCESS_NETWORK_STATE` present and **not**
> stripped, so nobody breaks sync by removing them; a deny list of wider network, location, boot
> and background-service permissions absent; and no HTTP or cloud client package in
> `pubspec.yaml`. `test/core/security/manifest_permission_guard_test.dart` checks the same thing
> from Dart.

Rules followed: dangerous permissions are requested at the point of use with a rationale, never
at startup; the app degrades gracefully when one is denied; there is a Permissions screen showing
current status with recovery actions.

---

## 12. OWASP Mobile Top 10 Compliance

Reviewed 2026-07-25. This is an honest snapshot, not a clean bill of health.

| ID | Risk | Status | Note |
|---|---|---|---|
| M1 | Improper Credential Usage | **verified** | No hardcoded secrets. PIN stored only as a PBKDF2 verifier. Keys live in the Keystore. |
| M2 | Inadequate Supply Chain Security | **partial** | `pubspec.lock` is committed and `go_router` (unused) was removed. No formal dependency or licence audit has been done. |
| M3 | Insecure Authentication | **verified** | App lock with background enforcement, mutually exclusive modes, per-journal and per-attachment locks. |
| M4 | Insufficient Input/Output Validation | **partial** | Drift uses parameterised queries throughout. Import adapters (Markdown, DOCX, plain text) have unit tests but no malformed-input fuzzing. |
| M5 | Insecure Communication | **verified** | No cloud, server or HTTP client. The only traffic is the direct device-to-device Wi-Fi Sync socket on the user's own LAN, authenticated by a pairing-code challenge and sealed with AES-256-GCM. See "In transit". |
| M6 | Inadequate Privacy Controls | **partial** | No telemetry; backup excluded; logging policy defined. Existing log statements not yet audited against it. |
| M7 | Insufficient Binary Protections | **verified (build), unverified (runtime)** | `--obfuscate` and R8 both work at build time. Never run on a device. |
| M8 | Security Misconfiguration | **verified** | `debuggable` false, `allowBackup` false, `FLAG_SECURE` on by default (user-switchable in Settings). Two unused transitive permissions remain (section 11). |
| M9 | Insecure Data Storage | **verified** | Attachments and the database are both encrypted at rest, keys in the Keystore. Closed 2026-08-18 (A5.1). |
| M10 | Insufficient Cryptography | **risk-accepted** | Strong primitives and correct nonce handling, but the attachment format is **unversioned**. See section 17. |

### Risk acceptances

- ~~**M9 — the SQLite database is not encrypted at rest.**~~ **Closed 2026-08-18** with A5.1.
  The database is now SQLCipher, keyed from the Android Keystore, and an existing plain vault is
  converted on first launch. What this buys: a flash dump or a stolen, powered-off device no
  longer gives up journal text. What it does not buy: protection from malware running as this app
  on an unlocked device, which can ask the Keystore for the key exactly as the app does.
- **M10 — the attachment encryption format carries no version.** Every stored attachment is
  `ciphertext || mac` with no header. If the algorithm or key derivation ever changes there is no
  in-band way to tell old files from new ones, so a future migration would have to infer format
  from context. Owner: Sreeraj P. Cheap to fix now, expensive after real data exists.

---

## 13. Data Retention And Purge Policy

### Retention schedule

| Data type | Retention | Deletion trigger |
|---|---|---|
| Journals, entries, tags | Indefinite — user content | User deletes the entry or journal |
| Entry revisions | Indefinite | **TODO** — no cap or pruning policy defined |
| Attachments (encrypted) | Indefinite | Deleted with their entry |
| Decrypted temp files | Session only | Viewer close, app background, or startup orphan sweep |
| Backup archives | User-managed, outside the app | User deletes the file |
| Security event log | **TODO** — no cap defined | — |
| Sync logs | **TODO** — no cap defined | — |
| Log files | n/a | No log files are written (section 9) |

### Purge implementation

**NOT IMPLEMENTED.** Section 13 of the standard requires a user-accessible "Delete all data"
action that clears the database, cache, temp files, and secure storage entries. A search of
`lib/` on 2026-07-25 found no such action anywhere. See section 17.

Temporary files are handled correctly: `AttachmentTempFileManager` creates them in
`getTemporaryDirectory()`, deletes them on close and on background, and sweeps orphans at
startup for the case where the process died mid-view.

### Purge on uninstall

Android deletes app-private data on uninstall. With `allowBackup="false"` there is no cloud copy
to restore from, so uninstall is a genuine wipe. Keystore entries are removed with the app.

---

## 14. Backup, Import, Export, And Recovery

- Backup supported: yes — `BackupService` produces an AES-256-GCM encrypted ZIP containing
  `manifest.json` (format version and database schema version), `database.json`, and the
  attachment and voice-note files.
- Backup format: **encrypted only.** No plaintext backup path exists.
- Import supported: yes — Markdown, DOCX, and plain text adapters.
- Recovery flow: **restore from an encrypted backup archive — built 2026-08-18** (A4.1).
  `BackupRestoreService` previews an archive, restores it as a replace or a merge, and can
  dry-run either. The restore screen sits behind the app PIN, or the device credential
  when no PIN is set. See "Archive format version 2" below.
- Encrypted export: **yes, since 2026-08-18** (A4.2). The export screen can seal the finished
  file with the same envelope the backup archive uses. Optional, off by default — see
  "Encrypted export" below.
- Plaintext export policy: **a plaintext export now exists** (added 2026-08-16, A1.1 / W5). The
  earlier wording here said none existed and that none should be added "without an explicit user
  confirmation step". That condition has been met — see below — and this entry supersedes it.

### Plaintext export (added 2026-08-16)

`lib/features/export/` writes entries out as Markdown, HTML, plain text, or PDF. This is a
deliberate reduction in confidentiality, accepted because the alternative — a vault a user cannot
get their own writing out of — is its own kind of harm, and because the app's central promise is
that the data belongs to the user.

What protects it:

| Control | How |
|---|---|
| **Explicit confirmation** | A dialog naming the entry count and format must be accepted before any file is built. Backing out abandons the export. Required by the policy above; covered by `export_screen_test.dart`. |
| **Passive warning too** | The screen states in plain words, before the user acts, that the file will not be encrypted. |
| **Journal locks honoured** | A locked journal is not offered in the Settings picker. It has to be unlocked on its own screen, which is the only place that asks for the password. |
| **Attachment locks honoured** | A locked attachment is **never decrypted**. The lock is checked before the file is touched, and the omission is reported to the user rather than hidden. |
| **Plaintext lifetime bounded** | Each attachment is decrypted, copied into the bundle, and its temporary decrypted file released immediately — never more than one plaintext file in the cache at a time. The native PDF renderer deletes its temporary PDF as soon as the bytes are read. |
| **Audited** | Every export writes a `SecurityEvents` row of type `export_attempt` holding scope, format, journal id, entry count, and skipped count — **never entry content, titles, or file names.** |
| **Offline** | The HTML page embeds its fonts as base64 data URIs and contains no URL; the render WebView additionally sets `blockNetworkLoads` and disables file and content access. No new package dependency, so no new transitive network capability. |

Accepted residual risks, stated plainly:

- **A plain export is unencrypted, by design.** Once saved it is outside every control this app
  has. Since 2026-08-18 the user can seal it instead (see "Encrypted export" below); when they do
  not, the confirmation dialog is the whole of the protection.
- **The user chooses the destination** through the system save dialog. A cloud-backed folder is a
  legitimate choice and the app cannot tell the difference.
- **An exported PDF or HTML page carries entry text in plain form** and is indexable by anything
  that later reads that folder.

### Encrypted export (added 2026-08-18, A4.2)

The export screen has a "Protect with a password" switch, off by default. With it on, the
finished file is sealed by `VaultEnvelope` — the **same** envelope the backup archive uses, moved
to `lib/core/security/` so the app has one password-sealed format rather than one per feature.

What it does:

| Point | How |
|---|---|
| **Same envelope, same rules** | `JVB` magic, envelope version, KDF id and cost, random 16-byte salt, AES-256-GCM under an Argon2id key. Minimum password length 8, the backup's rule. |
| **The file name is protected too** | The real name and mime type are written into a `JVP1` payload header **inside** the sealed bytes. The file on disk is offered as `journal_export_<date>.jvenc` — a name like `Leaving my job.md.jvenc` would give away what the password is hiding. |
| **Sealed before it touches disk** | `ExportService.build` seals the bytes; the save dialog only ever sees ciphertext. No plaintext copy is written and deleted. |
| **No plaintext confirmation dialog** | The dialog exists for a plaintext export. Turning the switch on is the deliberate act instead, and the warning card changes to say that a forgotten password means a lost file. |
| **Openable again** | Settings → "Open an encrypted export" picks a sealed file, asks for the password, and saves what was inside under its original name. It never writes anything back into the vault. |
| **Audited** | The `export_attempt` event gains `encrypted: true|false`. Still no names, no titles, no content. |

**Why Argon2id and not the PBKDF2 the sibling apps use.** The shared idea list recommended the
`sreerajp_youtube_shortcut` `v1:<salt>:<iv>:<ciphertext>` envelope. What it recommended it *for*
was being versioned and self-describing. `VaultEnvelope` is both, and it also records the KDF and
its cost inside the file, so the cost can be raised later without orphaning anything sealed
today — which the `v1:` string cannot do. Argon2id is memory-hard, PBKDF2 is not, and moving to
PBKDF2 would break every archive written since A4.1. So the app converges on this envelope, and
the family target is the *idea* the `v1:` string stood for.

Accepted residual risks:

- **A forgotten password is a lost file.** There is no recovery path and none will be added. The
  screen says so before the file is written.
- **A weak password is the whole of the protection**, exactly as for a backup archive.
- **The file size and the date in its name still leak a little** — roughly how much was exported,
  and when.

### Archive format version 2 (added 2026-08-18)

Two security-relevant changes came with restore, and both are trade-offs worth stating
plainly.

**1. The envelope now uses a random salt.** Version 1 derived the archive key with Argon2id
over a **fixed** salt, so one password produced one key on every device and in every backup —
exactly the shape a precomputed-table attack wants. Version 2 writes a self-describing
header (`JVB`, format version, KDF parameters, random 16-byte salt) so each archive has its
own key and a future build can raise the parameters without orphaning old files. Version 1
archives still decrypt, by design.

**2. Attachment content now sits inside the archive as plain bytes.** Version 1 copied the
encrypted files in as they were, which meant the archive was useless on any device that did
not already hold the Keystore key — that is, in exactly the situation a backup exists for.
Restore now decrypts each file on the way out and re-encrypts it with the receiving
device's Keystore key on the way in, the same shape `SreerajPContactSphere` uses for contact
photos. **The Keystore key itself never leaves the device and is never written to a file.**

The cost: inside the archive file, attachment content is protected by the **backup
password alone**, not by the Keystore. A weak backup password is therefore worse than it
was before. Mitigations: the password must be at least 8 characters, the whole container is
AES-256-GCM under an Argon2id-derived key, and nothing is ever written unencrypted to disk.
On the device itself nothing changed — attachments are still Keystore-encrypted at rest.

Restore safety, in the order it runs: password → format and schema version check (a newer
archive is refused with `BackupVersionTooNewException`) → structure check → optional dry run
→ automatic pre-restore backup before a replace → one database transaction → FTS rebuild →
`PRAGMA integrity_check`. Files written before a failed transaction are deleted, so a
failed restore leaves nothing behind.

### Validation status

- Import adapters have unit tests for well-formed input. **Malformed-input handling is not
  tested** — see section 17.
- Backup round-trip is **covered** since 2026-08-18:
  `test/features/backup/backup_round_trip_test.dart` backs up one database and restores it
  into a second one that shares no rows, no files and no keys — the new-phone case — and
  checks every table, the attachment bytes and the rebuilt search index.
  `backup_restore_service_test.dart` covers wrong password, newer format, newer schema,
  version 1 archives, merge and replace counts, id reassignment, the dry run writing
  nothing, and a file that fails to store.
  `restore_backup_screen_test.dart` covers the PIN and device-credential gate.

---

## 15. Security Testing Strategy

| Area | Test type | Status |
|---|---|---|
| Crypto round-trip | Unit | **Covered** — `attachment_crypto_storage_test.dart` |
| Sealed-file envelope (backup and export) | Unit | **Covered** — `test/core/security/vault_envelope_test.dart`, `vault_payload_test.dart` |
| Encrypted export round-trip | Unit | **Covered** — `test/features/export/export_encryption_test.dart` |
| Sync encryption round-trip | Unit | **Covered** — `sync_encryption_service_test.dart` |
| Secret storage (no plaintext written) | Unit | **Covered** — method channel adapter tests |
| Lock / auth flow | Widget + integration | **Covered** — `lock_gate_test.dart`, controller tests |
| Attachment lock re-auth | Service + widget | **Covered** |
| DB migration v1 → v7 | Unit | **Covered** — added 2026-07-25, mutation-verified |
| Backup and recovery round-trip | Integration | **Missing** |
| Data purge | Integration | **Missing** — the feature itself does not exist |
| Malformed import input | Unit | **Missing** |
| Obfuscation present in release | Build verification | **Covered** — verified 2026-07-25 |
| `debuggable=false` | Build verification | **Covered** — verified 2026-07-25 |
| Permission audit | Build verification | **Covered** — verified 2026-07-25, two unused found |

---

## 16. Incident Response Notes

- Triage owner: Sreeraj P (sole developer and sole user).
- Severity model: anything that exposes journal content off-device, or that loses journal
  content, is critical. Everything else is best-effort.
- Immediate containment: stop installing the affected build; keep the previous APK and the
  matching debug symbols so the fault can be diagnosed.
- User communication trigger: n/a while the app has a single user. Revisit if that changes.
- Patch release process: [`release_process.md`](release_process.md).

---

## 17. Open Risks And Future Hardening

Ordered by how much damage each could do. Items struck through have since been closed; the rest
are open.

1. **No "Delete all data" action.** Required by the standard's section 15.4. There is no way for
   the user to wipe the app's contents from inside the app.
   *Hardening:* add it to Settings behind a confirmation, clearing DB, cache, temp files, and
   Keystore entries; then add the purge-completeness integration test.

2. ~~**The database is not encrypted at rest**~~ **Closed 2026-08-18** with A5.1. The database is
   SQLCipher, keyed from the Keystore. Two things it leaves behind, both accepted:
   - **Losing the Keystore key means losing the journal.** There is no password fallback and no
     recovery path other than a backup file. The app says so plainly instead of starting empty —
     see `lib/app/vault_unavailable_app.dart`.
   - **Reads are slower**, FTS5 search most of all, because every page is decrypted on the way in.

3. **The attachment key is generated with a non-cryptographic RNG.** `getAttachmentKey` in
   `MainActivity.kt` fills its 32 bytes from `kotlin.random.Random`, not `SecureRandom`. The
   database key added in A5.1 uses `SecureRandom`; the attachment path was left alone in that
   change to keep it scoped.
   *Hardening:* a two-line change. It only affects keys generated afterwards, so existing
   attachments keep working — worth doing before the installed base grows.

4. **The attachment encryption format is unversioned** (M10 risk acceptance). No header, no
   version byte. Any future crypto change becomes a guessing game.
   *Hardening:* add a magic + version prefix now, while the installed base is one device.

5. **R8 has never been runtime-verified.** The release build compiles, but no obfuscated,
   shrunk build has run on a device. A missing keep rule surfaces as a crash only at runtime.
   *Hardening:* the smoke-test list in `release_process.md`, before the first real release.

6. ~~**No backup/restore round-trip test.**~~ **Closed 2026-08-18** with A4.1. There was no
   restore path to test; now there is one, and it is covered end to end — see the
   validation status in section 14.

7. **Malformed import input is untested.** Import adapters parse third-party file formats —
   the classic place for parser bugs.

8. **Existing log statements have not been audited** against the section 9 policy. The policy
   and the logger are new; the codebase predates both.

9. **Exported files are unencrypted once written** (added 2026-08-16). Export is gated by an
   explicit confirmation dialog and honours journal and attachment locks, but the file it
   produces has no protection at all once it leaves the app.
   *Hardening:* **done 2026-08-18 (A4.2)** — an export can now be sealed with the same
   `VaultEnvelope` the backup archive uses, so the app has one envelope format rather than two.
   A plain export is still offered, and still warned about.

10. **Two unused permissions** (`ACCESS_NETWORK_STATE`, `WAKE_LOCK`) arrive transitively and are
    not stripped.
    *Hardening:* **done 2026-08-23 (A5.3)** — `tools:node="remove"` explicitly stripped
    `INTERNET`, `ACCESS_NETWORK_STATE`, and `WAKE_LOCK` from production builds, guarded by CI.
    *Updated 2026-08-24:* `INTERNET` and `ACCESS_NETWORK_STATE` were deliberately re-added for
    Wi-Fi Sync, which needs a local TCP socket. They are no longer unused. `WAKE_LOCK` is still
    stripped, and the CI guard now also blocks wider network permissions and any HTTP or cloud
    client package.

11. **No retention caps** on entry revisions, security events, or sync logs. Unbounded growth in
   tables that hold user-derived data.

12. **No formal dependency audit** (M2). 51 packages have newer versions; none has been reviewed
    for licence or transitive network behaviour.

13. **No memory-clearing strategy** for decrypted content or key material. Accepted for the
    stated threat model but never formally reviewed.

---

## 18. Security Review Checklist

Complete before every release. Nothing below may be ticked from memory.

- [ ] Threat model (section 3) still matches what the app does.
- [ ] Sensitive data inventory (section 4) updated for any new data type.
- [ ] No new log statement violates section 9.
- [ ] `allowBackup="false"` and the data-extraction rules still present in the **merged release**
      manifest.
- [ ] `FLAG_SECURE` still applied by default — with "Block Screenshots" on, a screenshot of the
      running app must fail; with it off, a screenshot must succeed; the choice must survive a
      restart.
- [ ] Permission list re-read from the merged release manifest; nothing new appeared.
- [ ] `--obfuscate --split-debug-info` present in the build command actually used.
- [ ] Debug symbols archived against the released version number.
- [ ] `android:debuggable` absent from the merged release manifest.
- [ ] Cleartext traffic still off and no network security config or user trust anchor added.
- [ ] Exported component audit done — only `.MainActivity` exported (`release_process.md` §6.7).
- [ ] Asset leak audit done — no secret, key or personal data in APK `assets/` (§6.6).
- [ ] R8 smoke tests passed on a real device (see `release_process.md`).
- [ ] OWASP table (section 12) re-reviewed; risk acceptances still acceptable.
- [ ] Migration test passes for the full version range.
- [ ] Backup, restore, and import paths exercised by hand if not yet automated.
- [ ] Release is signed with the real release keystore, **not** the debug key.
