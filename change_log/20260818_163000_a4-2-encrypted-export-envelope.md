# A4.2 — one sealed-file format, and an encrypted export

**Date:** 2026-08-18
**Plan:** [`plans/20260818_145453_a4-2-encrypted-export-envelope.md`](../plans/20260818_145453_a4-2-encrypted-export-envelope.md)
**Idea:** `docs/enhancement_ideas.md` A4.2, and the deferred item under A1.1.

---

## What was wrong

A4.1 gave the backup archive a versioned, self-describing envelope with a random salt. Two
things were still open:

1. The **export** file had no envelope at all. Markdown, HTML, plain text, PDF and zip bundles
   were written in the clear, with a warning card and a confirmation dialog as the only
   protection. Encrypting it had been deferred to A4.2 so both files would share one format.
2. The envelope lived inside `lib/features/backup/`, where no other feature could use it
   without importing across feature boundaries.

## What changed

### One envelope, in core

- **New** `lib/core/security/vault_envelope.dart` — the A4.1 envelope, moved out of the backup
  feature and renamed `VaultEnvelope`. It carries the password rules
  (`minimumVaultPasswordLength`, `validateVaultPassword`) and the crypto failures
  (`VaultCorruptedException`, `VaultPasswordException`, `VaultVersionTooNewException`).
- **The bytes on disk did not change.** Magic `JVB`, envelope version, KDF id and cost, random
  salt, nonce, MAC, ciphertext — all exactly as A4.1 wrote them, so every existing backup still
  opens. The A4.1 version 1 and version 2 tests were carried over and still pass.
- `vaultEnvelopeVersion` is now a separate number from `backupFormatVersion`. One says how a
  file is sealed, the other says what the sealed bytes contain. Both are 2 today, which is why
  the coupling was easy to miss.
- **New** `VaultEnvelope.isSealed`, so a caller can tell a sealed file from a plain one before
  asking for a password.
- `lib/features/backup/domain/backup_format.dart` now aliases the core names
  (`typedef BackupCorruptedException = VaultCorruptedException`, and so on), so backup code and
  its tests read as backup code while there is only one class behind them.
- `backup_restore_service.dart` translates `VaultVersionTooNewException` into
  `BackupVersionTooNewException`, so the restore screen's message is unchanged.

### A header inside the sealed bytes

- **New** `lib/core/security/vault_payload.dart` — a `JVP1` header carrying the file name, mime
  type and creation time, sealed **with** the payload:
  `["JVP1"][headerLen:2][header JSON][file bytes]`.
- Bytes with no such header read back untouched, so backup archives — a plain zip, sealed with
  no header — are unaffected.

### The export can be sealed

- `ExportService.build` takes an optional `password`. When given, the finished bytes are wrapped
  in a payload header and sealed before they reach the save dialog, so a protected export never
  exists on disk in the clear. `ExportResult` gained `isEncrypted`.
- The sealed file is offered as `journal_export_<date>.jvenc`, **not** as
  `<original name>.jvenc`. A file called `Leaving my job.md.jvenc` would give away the very
  thing the password is hiding, so the real name travels inside the header.
- `export_screen.dart` gained a "Protect with a password" switch (off by default), two password
  fields with the backup's 8-character minimum, and a warning card that changes rather than
  disappears — a forgotten password is its own way to lose the file. With the switch on, the
  plaintext confirmation dialog is skipped: turning it on was the deliberate act instead.
- The `export_attempt` security event gained `encrypted: true|false`. Still no names, no titles,
  no content.

### Opening one again

- **New** `lib/features/export/presentation/open_encrypted_export_screen.dart` — pick a file,
  enter the password, and save what was inside under its original name. Reached from
  Settings → "Open an encrypted export", next to Export Data.
- It only unwraps the file. It never writes anything back into the vault; that is what restoring
  a backup is for.
- "This is not an encrypted export" and "wrong password" are separate messages, because they
  need different fixes. A wrong password and a damaged file stay one message, because AES-GCM
  cannot tell them apart.

## The KDF decision

The idea list recommended converging on the `sreerajp_youtube_shortcut` `v1:` envelope, which
uses PBKDF2 at 300k iterations. **That was not followed, deliberately.** What the `v1:` envelope
was recommended *for* was being versioned and self-describing; `VaultEnvelope` is both, and it
also writes the KDF and its cost into the file, so the cost can be raised later without
orphaning old files — which the `v1:` string cannot do. Argon2id is memory-hard, PBKDF2 is not,
and switching would have broken every archive written since A4.1. Written up in
`docs/security.md` section 14.

## Two departures from the plan

- The plan said `backup_envelope.dart` would stay as a thin alias file. It was **deleted**
  instead, and its four users updated, because a permanent alias file for a class nobody should
  reach through the backup feature again is dead weight.
- The new export tests went into a new file, `test/features/export/export_encryption_test.dart`,
  rather than into `export_service_test.dart`, which is already long.

## Files

**New**

- `lib/core/security/vault_envelope.dart`
- `lib/core/security/vault_payload.dart`
- `lib/features/export/presentation/open_encrypted_export_screen.dart`
- `test/core/security/vault_envelope_test.dart`
- `test/core/security/vault_payload_test.dart`
- `test/features/export/export_encryption_test.dart`
- `test/features/export/open_encrypted_export_screen_test.dart`

**Removed**

- `lib/features/backup/services/backup_envelope.dart` (moved to `core/security/`)
- `test/features/backup/backup_envelope_test.dart` (moved to `test/core/security/`)

**Changed**

- `lib/features/backup/domain/backup_format.dart`
- `lib/features/backup/services/backup_service.dart`
- `lib/features/backup/services/backup_restore_service.dart`
- `lib/features/export/services/export_service.dart`
- `lib/features/export/presentation/export_screen.dart`
- `lib/app/app.dart`
- `lib/l10n/app_en.arb` (23 new keys) and the generated `app_localizations*.dart`
- `test/features/backup/backup_test_support.dart`
- `test/features/export/export_screen_test.dart`
- `docs/security.md`, `docs/architecture.md`, `docs/enhancement_ideas.md`,
  `docs/features.md`, `docs/implementation_progress.md`, `docs/project_structure.md`

## Checks

- `flutter analyze` — no issues.
- `flutter test` — **555 passing, 0 failing** (was 534 before this change).
- `dart format lib test integration_test` — clean.
- No new package dependency. Nothing new is logged. The app is still fully offline.

---

## Follow-up, same day — `docs/features.md` restore claims

Spotted while writing this log and fixed on request. `features.md` still described the app as
it was before A4.1:

- Section 1 listed "no backup restore flow exists yet" as a disclosed gap. Removed — it was
  built on 2026-08-18.
- Section 6 said "Creation only: there is no restore-from-backup flow in the app today — a
  backup file cannot be loaded back in." Replaced with what restore actually does: preview,
  replace or merge, dry run, the PIN or device-credential gate, the safety order it runs in,
  and the format version 2 rule that lets an archive restore onto a new phone.
- The heading "One-Tap Encrypted Backup Creation" became "One-Tap Encrypted Backup Creation
  And Restore", and the summary paragraph at the top of the document now mentions restore.

Documentation only. No code changed, so the test and analysis results above still stand.
