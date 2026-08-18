# Fix remaining gaps in docs/features.md — backup restore, attachment open paths

Implements: `plans/20260803_114824_fix-backup-restore-and-viewer-gaps.md`

## What changed

Edited `docs/features.md` only, three small wording fixes:

1. Added a line to the Section 1 "Disclosed Gaps" list: no backup restore flow exists yet —
   `backup_service.dart` only creates and verifies backups, so a backup file cannot currently be
   loaded back into the app.

2. Renamed Section 6's "One-Tap Encrypted Export" bullet to "One-Tap Encrypted Backup Creation"
   and added a line stating it is creation-only, with no restore-from-backup flow today.

3. Added a line to Section 3's "Wide Media & Document Format Support" bullet clarifying that only
   PDF, audio, and `.zip` render in a built-in viewer — images and other document types still open
   with one tap, but via the device's external app chooser, same as `.7z`.

## Why

A code review of `docs/features.md` against the codebase found these two claims did not match
the code:

- The doc read as if backup/export were a full round trip. `lib/features/backup/services/backup_service.dart`
  only exposes `createBackup()` and `verifyBackup()` — no restore method exists anywhere, and
  `backup_health_screen.dart` has no restore button. This gap was already tracked in
  `docs/architecture.md` section 21 and `security.md` section 17, but not reflected in the
  features doc.
- The "Wide Media & Document Format Support" bullet implied images get the same in-app viewing as
  PDF/audio/archives. `attachment_open_router.dart` only routes PDF, audio, and `.zip` to an
  in-app viewer; images fall through to `AttachmentOpenKind.unsupported`, which — like `.7z` — is
  still opened with one tap, just via the device's external app chooser rather than a built-in
  viewer.

No code was changed; this was a documentation-accuracy pass only.
