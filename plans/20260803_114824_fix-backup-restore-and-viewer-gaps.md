# Fix remaining gaps in docs/features.md — backup restore, attachment open paths

**Status:** completed

## Files to be changed

- `docs/features.md` (only file changed)

## What the issue is

This is a fourth pass over `docs/features.md` (three earlier passes today already fixed stale
file references, sync/tamper caveats, journal management, search/settings sections, and build
flavors/logging — those are correct and need no further change). I checked the doc line by line
against the code again and found two remaining real gaps.

1. **There is no backup restore anywhere in the code, and the doc does not say so.**
   `lib/features/backup/services/backup_service.dart` only has `createBackup()` and
   `verifyBackup()` — no `restoreBackup` or similar. `backup_health_screen.dart` has no restore
   button, only a manual-backup trigger. This matches a gap already tracked in
   `docs/architecture.md` section 21 ("No backup/restore round-trip test") and `security.md`
   section 17, but `docs/features.md` section 6's "One-Tap Encrypted Export" bullet reads as if
   export/backup is a complete round trip. A reader would reasonably assume a backup can be
   restored. It cannot, today.

2. **Section 3's "Wide Media & Document Format Support" bullet overstates in-app viewing for
   images.** `lib/features/attachments/domain/attachment_open_router.dart` only routes PDF, audio,
   and `.zip` to an in-app viewer (plus `.7z` explicitly to an external app). Every other type,
   including images, falls to `AttachmentOpenKind.unsupported`, which — per
   `attachment_open_service.dart` (`opensInApp` false for `unsupported`) and
   `entry_editor_screen.dart` line 1014 — is still handed to an external app automatically via
   `open_filex` (so "1-tap open" is accurate), it just isn't rendered by a built-in viewer the way
   the bullet's wording implies. This is a smaller, wording-only gap.

## The plan for the fix

Edit `docs/features.md` only, in place, no new files:

1. **Section 1 ("Disclosed Gaps" bullet list, line 55-58):** add one line — no backup restore
   flow exists yet; `createBackup`/`verifyBackup` are the only operations, so a backup file cannot
   currently be restored back into the app.

2. **Section 6 ("One-Tap Encrypted Export" bullet):** reword to make clear this is backup
   *creation* only (database snapshot + encrypted attachments, compressed), and that there is no
   restore-from-backup flow in the app today.

3. **Section 3 ("Wide Media & Document Format Support" bullet):** add a clause clarifying that
   only PDF, audio, and `.zip` render in a built-in viewer; images and other document types are
   still opened with one tap, but via the device's external app chooser, same as `.7z`.

No other sections need changes.

## Change log

Will be written to `change_log/` after this edit is approved and applied.
