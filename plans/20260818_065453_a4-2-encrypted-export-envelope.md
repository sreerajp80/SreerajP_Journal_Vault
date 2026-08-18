# A4.2 — finish it: one shared envelope, and an encrypted export file

**Status:** completed

Idea: `docs/enhancement_ideas.md` A4.2 (and the "not done, deliberately" note under A1.1).
Builds on: [`plans/20260818_072141_a4-1-backup-restore.md`](20260818_072141_a4-1-backup-restore.md).

---

## 1. What is left of A4.2

A4.1 already gave the **backup archive** a self-describing envelope with a random salt
(`lib/features/backup/services/backup_envelope.dart`, magic `JVB`, Argon2id + AES-256-GCM).
So the mechanism exists. Two things are still open, and both are named in the idea's own
closing note:

1. **The export file has no envelope at all.** A1.1 writes Markdown, HTML, plain text, PDF
   and zip bundles in the clear, on purpose, with a warning card and a confirmation dialog.
   That was deferred to A4.2 so both files would share one format. Today a user who wants
   their journal out of the app has only a plaintext door.
2. **The wording about converging on PBKDF2.** The idea recommended the
   `sreerajp_youtube_shortcut` `v1:` envelope (PBKDF2 300k). A4.1 kept Argon2id instead.
   That choice needs to be either reversed or written down as deliberate.

### The KDF question — recommendation: keep Argon2id, and change the document

Checked in the sibling apps:

- `SreerajP_Authenticator` export/import service — `v3:<salt>:<nonce>:<ct>`,
  PBKDF2-HMAC-SHA256 at 300k, then AES-256-GCM.
- `sreerajp_youtube_shortcut` backup service — `v1:<salt>:<iv>:<ct>`, the same PBKDF2 shape.

What the idea actually praised in the `v1:` envelope was that it is **versioned and
self-describing**, not the PBKDF2 inside it. The `JVB` envelope has that property and more:
it also writes the KDF id and its cost settings into the file, so the cost can be raised
later without orphaning old files — the `v1:` string cannot do that. Argon2id is memory-hard;
PBKDF2 is not. Moving to PBKDF2 now would also break every archive written since A4.1.

So: keep Argon2id, and rewrite the A4.2 entry to say the family target is the `JVB`
envelope's *idea* (versioned, self-describing, cost written into the file), which the `v1:`
string was standing in for.

---

## 2. The plan

### 2.1 Promote the envelope out of `features/backup/` into `core/`

Export must not import from the backup feature. Move the class, do not fork it.

- New: `lib/core/security/vault_envelope.dart` — the same code, class renamed
  `VaultEnvelope`, plus the password rules (`minimumVaultPasswordLength = 8`,
  `validateVaultPassword`) and the failure classes moved across from `backup_format.dart`.
- `lib/features/backup/services/backup_envelope.dart` becomes a thin alias so the backup
  service, the restore screen and their tests keep compiling unchanged.
- **The bytes on disk do not change.** Magic, version byte, KDF id, salt, nonce, mac and
  ciphertext all stay exactly as A4.1 wrote them. Every existing backup still opens. This
  step is a move, not a format change.

### 2.2 A payload header inside the ciphertext

The envelope says how a file was encrypted but not what is inside it. An encrypted export
needs to carry its own file name and format, and that name must not be readable from
outside — a file called `Therapy notes.md.jvenc` leaks the thing we are hiding.

So put a small header **inside** the sealed payload, ahead of the file bytes:

    ["JVP1"][headerLen:2][header JSON utf8][file bytes]

with `{"kind":"export","fileName":"...","mime":"...","createdAt":"..."}`.

Backup archives keep sealing their zip with no payload header; the reader treats a payload
that does not start with `JVP1` as raw bytes, so nothing old changes.

### 2.3 Offer encryption on the export screen

- A "Protect with a password" switch on `ExportScreen`, off by default.
- When it is on: a password field and a confirm field, minimum 8 characters, the same rule
  as a backup. The plain-language warning card and the "Export without encryption?" dialog
  are **skipped** when it is on — they are for a plaintext export, and this one is not.
  `docs/security.md` section 14 is satisfied either way.
- The saved name becomes `<original name>.jvenc`, the mime type
  `application/octet-stream`.
- Sealing happens in `ExportService.build` (an optional `password` parameter) so the bytes
  are encrypted before they reach `FilePicker.saveFile` and never touch disk in the clear.
- The `export_attempt` security event gains `"encrypted": true|false`. No name, no content.

### 2.4 A way to open one again

An encrypted export nobody can open is not a feature. Add
`lib/features/export/presentation/open_encrypted_export_screen.dart`:

- pick a file, ask the password, decrypt in memory, read the payload header, then offer
  "Save as" with the original file name through `FilePicker.saveFile`.
- A wrong password and a damaged file report exactly as the restore screen reports them
  (they are the same event to AES-GCM).
- Reached from Settings, next to the existing Export Data tile.
- It **only** unwraps the envelope. It does not import anything back into the vault — that
  is not what an export is, and pretending otherwise would add a second, weaker import path.

### 2.5 Docs

- `docs/enhancement_ideas.md` — mark A4.2 implemented, with the KDF decision written out;
  correct the A1.1 "not done, deliberately" note.
- `docs/security.md` section 14 — record the encrypted export path and the payload header.
- `docs/architecture.md` — the new `lib/core/security/` files and the new screen.
- `docs/features.md`, `docs/implementation_progress.md` — the user-facing line.

---

## 3. Files

**New**

- `lib/core/security/vault_envelope.dart`
- `lib/core/security/vault_payload.dart` (the `JVP1` header reader and writer)
- `lib/features/export/presentation/open_encrypted_export_screen.dart`
- `test/core/security/vault_envelope_test.dart`
- `test/core/security/vault_payload_test.dart`
- `test/features/export/open_encrypted_export_screen_test.dart`

**Changed**

- `lib/features/backup/services/backup_envelope.dart` (alias only)
- `lib/features/backup/domain/backup_format.dart` (password rules move out, re-exported)
- `lib/features/export/services/export_service.dart` (optional `password`)
- `lib/features/export/export_strings.dart` (new strings)
- `lib/features/export/presentation/export_screen.dart` (the switch and the fields)
- `lib/features/export/providers/export_providers.dart` (envelope provider)
- `lib/app/app.dart` (the Settings tile)
- `test/features/backup/backup_envelope_test.dart` (renamed target)
- `test/features/export/export_service_test.dart`, `test/features/export/export_screen_test.dart`
- `docs/enhancement_ideas.md`, `docs/security.md`, `docs/architecture.md`,
  `docs/features.md`, `docs/implementation_progress.md`

---

## 4. Tests

- Round trip: seal and open an export in every format, including a zip bundle.
- Wrong password gives `wrong_passphrase`; a truncated or flipped byte gives the same, by
  design.
- A backup written before this change still opens — the A4.1 version 1 and version 2 tests
  keep running against the moved class.
- A payload with no `JVP1` header reads back as raw bytes.
- Widget: the switch hides the plaintext confirmation dialog; a short password is refused;
  the two password fields must match.
- `flutter analyze` clean, `flutter test` green, `dart format lib test integration_test`.

## 5. Risks

- **Moving the envelope touches the one thing that must not break.** Guarded by keeping the
  byte layout identical and running the existing A4.1 tests unchanged against the moved
  class.
- **A lost password is a lost export.** No recovery is possible and none will be faked; the
  screen says so before the file is written.
- **PDF and zip files grow by about 40 bytes.** Not worth telling the user.

## 6. Not in this plan

- Re-importing an export back into the vault (that is the backup restore path).
- Changing the attachment crypto format (A5.2) — it can adopt `VaultEnvelope` later, which
  is the reason for putting the class in `core/`.
- Share-sheet hand-off, still deferred from A1.1.
