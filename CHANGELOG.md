# Changelog

User-facing release history for SreerajP Journal Vault.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html). Engineering detail lives in
[`change_log/`](change_log/); this file records what a user of the app would notice.

> No release has been distributed yet. The release keystore does not exist, so every build so far
> falls back to the debug key and must not be installed on a device holding real entries. See
> [`docs/release_process.md`](docs/release_process.md).

---

## [Unreleased]

### Added

- Malayalam and Sanskrit, alongside English. Every screen works in all three. The language can be
  chosen in Settings and changes without restarting the app. Malayalam and Devanagari fonts are
  bundled.
- Entry and journal export to Markdown, HTML, plain text, and PDF. The HTML and PDF exports embed
  their fonts, so they render Malayalam correctly and work with no network.
- Password-protected encrypted export, and a screen to open such a file again.
- Restore from a backup.
- Import button on the journal screen, next to Export.
- In-app viewers for PDF, audio, and ZIP attachments. The decrypted copy is deleted as soon as the
  viewer closes.
- Scan text from a photo (OCR) into an entry, fully offline, for English and Malayalam. Includes an
  in-app camera with flash, focus and zoom, crop and rotate, clean-up filters, a blur warning, and
  a text preview before inserting.
- Voice notes, saved as encrypted attachments that can be played and deleted.
- Drawing and handwriting blocks in entries.
- Tables in entries, with column resize and formatted text in cells.
- "Paste as Markdown", and pasting formatted text from web pages and other apps with its
  formatting kept.
- Custom entry templates with date tokens, plus topic-specific built-in templates in a collapsible
  chooser.
- Editor quality of life: word and character count, a Tab button, and "go to line start / end" in
  the selection menu.
- Receive text and images shared from other apps.
- Wi-Fi Sync: an encrypted, direct link between two of the user's own phones on the same local
  network. No server is involved.
- AirQR: move settings, templates, journals or single entries between phones with animated QR
  codes, with no network at all.
- Time capsules: entries sealed until a chosen future date.
- Ritual mode, a guided daily opening practice, with 50 Sanathana Dharma thought cards (English and
  Malayalam) and cards the user writes themselves.
- Paper / sepia reading theme and entry text typography settings.
- Settings pages for Appearance, Features, and Help.
- Smart tag suggestions in the entry editor, taken from the live document text.
- Tamper alerts and a security events screen.

### Changed

- New app lock screen design, and App Lock Mode shown as real radio options.
- Settings are grouped into section cards that open their own pages.
- The editor toolbar order is tidied, and the selection menu stays after "Select all".
- The app no longer locks while the user is in a system screen the app opened (file picker, camera,
  "Save as", the fingerprint prompt, or another app showing an attachment). It still locks if the
  user stays away for more than 2 minutes.
- Buttons and text no longer hide under the Android navigation bar.
- The About screen shows the app name, author and credits in the chosen language, and the real
  build version and date.
- Attachments now honour the storage location setting — app-private or SD card — on every write,
  read, delete, and migration. Changing the setting takes effect without restarting the app.
- The PDF viewer now uses an open-source engine (pdfrx) instead of a commercial one.

### Fixed

- Deleting an entry that had an attachment failed, and deleted entries left their encrypted files
  on the device.
- On a phone set to Malayalam, the entry body could not be edited.
- The editor no longer jumps focus to the title while typing in the body.
- Going back from the OCR edit screen no longer shows a long black loading screen.
- Tapping an attachment crashed the app instead of opening it.
- Migrating attachment storage between app-private and the SD card did nothing.
- A removed SD card now reports a clear message instead of failing silently.

### Security

- The journal database itself is now encrypted at rest (SQLCipher), with its key in the Android
  Keystore. An existing plain database is converted on first launch.
- Keyboard privacy: every text box asks the keyboard not to learn what is typed. On by default;
  can be switched off in Settings.
- Screenshots and task-switcher previews are blocked across the whole app. Since this version the
  user can switch this off in Settings, and the change is recorded in the security event log.
- Decrypted attachment copies, file-picker copies and other temporary files are deleted after use
  and swept again at start-up.
- Android cloud backup and device-to-device transfer are disabled, so journal content cannot leave
  the device that way.
- Release builds are obfuscated and shrunk.

### Known issues

- Wi-Fi Sync is one way: the host phone sends new items, edits and deletes to the client. For the
  client's changes to travel, it must be the host. A delete on the host deletes the item on the
  client. It is designed for two phones.

---

## [1.0.1] — 2026-07-25

First internal build. Not distributed.

### Added

- Journals and entries with a rich text editor, tags, and grouping.
- Attachments encrypted with AES-256-GCM under an Android Keystore key.
- App lock with one active mode at a time — phone lock or a separate app lock — plus optional
  per-journal locks.
- Full-text search with saved filters.
- Entry templates and wiki-style backlinks between entries.
- Timeline calendar and an insights screen.
- Import, and a scheduled local backup.
- Permissions Center with an explicit runtime permission flow.
- Light and Dark themes, with the choice remembered.
- About screen showing version, build, and credits.
