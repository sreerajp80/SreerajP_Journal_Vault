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

- Entry and journal export to Markdown, HTML, plain text, and PDF. The HTML and PDF exports embed
  their fonts, so they render Malayalam correctly and work with no network.
- In-app viewers for PDF, audio, and ZIP attachments. The decrypted copy is deleted as soon as the
  viewer closes.
- Smart tag suggestions in the entry editor, taken from the live document text.
- English localization: all screen text now comes from a translation file, so a second language
  needs no code changes.

### Changed

- Attachments now honour the storage location setting — app-private or SD card — on every write,
  read, delete, and migration. Changing the setting takes effect without restarting the app.

### Fixed

- Tapping an attachment crashed the app instead of opening it.
- Migrating attachment storage between app-private and the SD card did nothing.
- A removed SD card now reports a clear message instead of failing silently.

### Security

- Screenshots and task-switcher previews are blocked across the whole app.
- Android cloud backup and device-to-device transfer are disabled, so journal content cannot leave
  the device that way.
- Release builds are obfuscated and shrunk.

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
