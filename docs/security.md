# Security — SreerajP Journal Vault

> **This is the local copy.** It overrides `docs/guidelines/security.md` for this app, per the
> "local copy wins" rule in [`GUIDELINES_MANIFEST.md`](GUIDELINES_MANIFEST.md).
>
> Sections marked `TODO` are not yet decided. They are left open on purpose rather than filled
> with content that would read as a completed review when no review happened.

Last reviewed: 2026-07-25 · Reviewer: Sreeraj P (with Claude)

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
  also blanks the task-switcher preview.
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
| Journal entry content | Diary text, titles | Drift/SQLite DB, app-private storage | OS app sandbox; no app-level DB encryption (see section 17) |
| Attachments | PDFs, audio, archives | Encrypted files, app-private or SD card | AES-256-GCM, Keystore-backed key |
| Attachment plaintext (transient) | Decrypted PDF being viewed | App cache directory | Deleted on close, background, and startup sweep |
| App PIN | The user's unlock PIN | Never stored | PBKDF2 verifier only, 100,000 iterations, 16-byte random salt |
| PIN salt + verifier | — | SharedPreferences | Keystore-wrapped (AES-GCM) before storage |
| Journal secrets | Per-journal lock secrets | SharedPreferences | Keystore-wrapped (AES-GCM) before storage |
| Attachment encryption keys | AES-256 keys | Android Keystore | Never leave secure hardware |
| Attachment nonces | Per-file GCM nonce | Drift DB, alongside the attachment row | Not secret; unique per file |
| Search index | Entry title + plain text | FTS5 tables in the same DB | Same protection as the DB — note this duplicates entry text |
| Backups | Full export archive | User-chosen location | AES-256-GCM encrypted ZIP |
| Voice notes | Recorded audio | Same path as attachments | Same as attachments |

> **Note on the FTS index.** `entries_fts` holds a copy of entry titles and plain text. Any
> control applied to the entries table must be applied to the FTS tables too, or the index
> becomes a plaintext bypass of it.

---

## 5. Storage Model

### At rest

- Primary local storage: Drift over SQLite, app-private directory.
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

- Network use: **none.** Verified 2026-07-25 against the merged `prodRelease` manifest — the
  `INTERNET` permission is absent, and no HTTP client is in `pubspec.yaml`.
- The `lib/features/sync/` module implements an encrypted sync protocol and conflict resolution
  but has no transport. Adding one would require revisiting this whole document.

---

## 6. Cryptography Design

- Encryption algorithm: **AES-256-GCM** for attachments (Dart `cryptography` package) and for
  Keystore wrapping (Android `Cipher`, `AES/GCM/NoPadding`, 128-bit tag).
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
- Randomness uses the platform CSPRNG in both the Dart and Kotlin paths.

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
> native code (`syncfusion_flutter_pdfviewer`, `just_audio`, `record`, `speech_to_text`,
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
- `android:debuggable`: false in release (verified — section 8.3).
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
| `RECORD_AUDIO` | `record` | Voice notes | Voice notes unavailable; rest of app works |
| `USE_FINGERPRINT` | `local_auth` | Legacy biometric API | Falls back |
| `ACCESS_NETWORK_STATE` | plugin (transitive) | **Not used by this app** | n/a |
| `WAKE_LOCK` | plugin (transitive) | **Not used by this app** | n/a |
| `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | Flutter/androidx | Internal broadcast safety | n/a |

> **Open item.** `ACCESS_NETWORK_STATE` and `WAKE_LOCK` are not used by any app code. The
> standard says to remove permissions the app does not use. They come from plugin manifests, so
> removing them needs `tools:node="remove"` entries. See section 17.

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
| M5 | Insecure Communication | **verified** | No network traffic. `INTERNET` absent from the merged release manifest. |
| M6 | Inadequate Privacy Controls | **partial** | No telemetry; backup excluded; logging policy defined. Existing log statements not yet audited against it. |
| M7 | Insufficient Binary Protections | **verified (build), unverified (runtime)** | `--obfuscate` and R8 both work at build time. Never run on a device. |
| M8 | Security Misconfiguration | **verified** | `debuggable` false, `allowBackup` false, `FLAG_SECURE` on. Two unused transitive permissions remain (section 11). |
| M9 | Insecure Data Storage | **risk-accepted** | Attachments are encrypted; the **database itself is not**. See section 17. |
| M10 | Insufficient Cryptography | **risk-accepted** | Strong primitives and correct nonce handling, but the attachment format is **unversioned**. See section 17. |

### Risk acceptances

- **M9 — the SQLite database is not encrypted at rest.** Journal text, titles, and the FTS index
  sit in a plain SQLite file inside the app-private directory. On a non-rooted device the OS
  sandbox keeps other apps out, which covers the stated threat model. It does **not** cover a
  rooted device or offline flash extraction — both explicitly out of scope in section 3.
  Owner: Sreeraj P. Revisit if SQLCipher or `drift`'s encrypted backend is adopted.
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
  `manifest.json` (with a format `version`), `database.json`, and the already-encrypted
  attachment files copied as-is.
- Backup format: **encrypted only.** No plaintext backup path exists.
- Import supported: yes — Markdown, DOCX, and plain text adapters.
- Recovery flow: restore from an encrypted backup archive.
- Plaintext export policy: the plan calls for "one-tap encrypted export per journal". No
  plaintext export exists, and none should be added without an explicit user confirmation step.

### Validation status

- Import adapters have unit tests for well-formed input. **Malformed-input handling is not
  tested** — see section 17.
- Backup round-trip (export → purge → import → verify) is **not** covered by an integration
  test. `test/features/backup/` covers logging and the verify contract only. Recovery flows are
  high-value attack targets and the standard says to test them like authentication flows.

---

## 15. Security Testing Strategy

| Area | Test type | Status |
|---|---|---|
| Crypto round-trip | Unit | **Covered** — `attachment_crypto_storage_test.dart` |
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

Ordered by how much damage each could do. None of these are fixed.

1. **No "Delete all data" action.** Required by the standard's section 15.4. There is no way for
   the user to wipe the app's contents from inside the app.
   *Hardening:* add it to Settings behind a confirmation, clearing DB, cache, temp files, and
   Keystore entries; then add the purge-completeness integration test.

2. **The database is not encrypted at rest** (M9 risk acceptance). Journal text and the FTS index
   are readable by anyone who can get at the app-private directory — which means root, a custom
   recovery, or an offline flash dump.
   *Hardening:* SQLCipher or drift's encrypted backend, keyed from the Keystore.

3. **The attachment encryption format is unversioned** (M10 risk acceptance). No header, no
   version byte. Any future crypto change becomes a guessing game.
   *Hardening:* add a magic + version prefix now, while the installed base is one device.

4. **R8 has never been runtime-verified.** The release build compiles, but no obfuscated,
   shrunk build has run on a device. A missing keep rule surfaces as a crash only at runtime.
   *Hardening:* the smoke-test list in `release_process.md`, before the first real release.

5. **No backup/restore round-trip test.** The recovery path is the one that matters when
   something has already gone wrong, and it is untested end to end.

6. **Malformed import input is untested.** Import adapters parse third-party file formats —
   the classic place for parser bugs.

7. **Existing log statements have not been audited** against the section 9 policy. The policy
   and the logger are new; the codebase predates both.

8. **Two unused permissions** (`ACCESS_NETWORK_STATE`, `WAKE_LOCK`) arrive transitively and are
   not stripped.

9. **No retention caps** on entry revisions, security events, or sync logs. Unbounded growth in
   tables that hold user-derived data.

10. **No formal dependency audit** (M2). 51 packages have newer versions; none has been reviewed
    for licence or transitive network behaviour.

11. **No memory-clearing strategy** for decrypted content or key material. Accepted for the
    stated threat model but never formally reviewed.

---

## 18. Security Review Checklist

Complete before every release. Nothing below may be ticked from memory.

- [ ] Threat model (section 3) still matches what the app does.
- [ ] Sensitive data inventory (section 4) updated for any new data type.
- [ ] No new log statement violates section 9.
- [ ] `allowBackup="false"` and the data-extraction rules still present in the **merged release**
      manifest.
- [ ] `FLAG_SECURE` still applied — check by trying to screenshot the running app.
- [ ] Permission list re-read from the merged release manifest; nothing new appeared.
- [ ] `--obfuscate --split-debug-info` present in the build command actually used.
- [ ] Debug symbols archived against the released version number.
- [ ] `android:debuggable` absent from the merged release manifest.
- [ ] R8 smoke tests passed on a real device (see `release_process.md`).
- [ ] OWASP table (section 12) re-reviewed; risk acceptances still acceptable.
- [ ] Migration test passes for the full version range.
- [ ] Backup, restore, and import paths exercised by hand if not yet automated.
- [ ] Release is signed with the real release keystore, **not** the debug key.
