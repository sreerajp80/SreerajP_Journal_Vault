# Implementation Progress — SreerajP Journal Vault

What is actually finished, what is partly finished, and what is still open. A point-in-time
record — add a new dated section rather than rewriting an old one.

**Date:** 2026-08-18
**Scope:** every numbered prompt in [`ai_development_prompts.md`](ai_development_prompts.md), plus
the post-V1 slices.
**Result:** V1 and V2 complete. V3 complete except sync, which has no transport. Strict
guidelines conformance (C2) complete in code; native-reader review of the translations is still
open.

Read first: [`implementation_plan.md`](implementation_plan.md) ·
[`architecture.md`](architecture.md) section 21

---

## 1. Status overview

| Phase | State |
|---|---|
| V1 — Secure MVP foundation | **Complete** (prompts 00–14) |
| V2.1 — templates, backlinks, FTS5, editor | **Complete** (prompts 15–17) |
| V2.2 — import, backup scheduler, version history | **Complete** (prompt 18) |
| V3.1 — encrypted sync | **Partial** (prompt 19) — crypto and conflict resolution built and tested, **no transport** |
| V3.2 — insights and advanced security | **Complete** (prompt 20) |
| A1.1 / W5 — export | **Complete** (2026-08-16) |
| A4.1 — backup restore | **Complete** (2026-08-18) |
| A4.2 — one sealed-file format, encrypted export | **Complete** (2026-08-18) |
| C — guidelines conformance | **In progress** (2026-08-18) |

Test suite as of the last full run: **555 passing, 0 failing** (2026-08-18).

---

## 2. Prompt checklist

### V1

- [x] 00 — Project scaffold and architecture
- [x] 01 — Drift schema v1
- [x] 02 — Home and journal CRUD UI
- [x] 03 — Journal detail and entry list
- [x] 04 — Rich text editor baseline
- [x] 05 — Attachment import and open
- [x] 06 — Attachment encryption storage service
- [x] 07 — App lock modes (mutually exclusive)
- [x] 08 — Journal lock and security basics
- [x] 09 — Permissions Center and settings controls
- [x] 10 — Theme selection
- [x] 11 — About screen and build metadata
- [x] 12 — Storage migration, app-private ↔ SD card
- [x] 13 — Search v1, basic and saved filters
- [x] 14 — V1 polish and release hardening

### V2

- [x] 15 — Templates and backlinks
- [x] 16 — FTS5, smart tags, timeline
- [x] 17 — Advanced editor blocks and media
- [x] 18 — Import and backup scheduler

### V3

- [ ] 19 — Encrypted sync and conflict resolution — **partial**, see section 4
- [x] 20 — Security extensions and insights

### Post-V1

- [x] A1.1 / W5 — Entry and journal export (Markdown, HTML, plain text, PDF)
- [x] A4.2 — Encrypting the exported file — built 2026-08-18. The envelope moved to
      `lib/core/security/`, so the backup archive and an encrypted export share one
      versioned format. Settings can open a sealed export again.
- [x] On-device dictation (speech to text) in the entry editor — built 2026-09-16. Plan:
      `plans/20260916_194242_on-device-dictation.md`. Voice notes dropped their unreliable live
      transcription. Needs a manual airplane-mode check on a real phone, and a fluent reader's
      review of the new Malayalam and Sanskrit strings.
- [x] C3 — Time capsules and letters to your future self (cryptographic date-gated key release, cleartext wiping, monotonic clock rollback protection, countdown timer, overview catalogue) — built 2026-08-24.

### C — guidelines conformance (2026-08-18)

- [x] C1 — `CLAUDE.md`, `AGENTS.md`, `README.md`, `pubspec` description
- [x] C2 — Missing `docs/` baseline set, `snake_case` doc names
- [x] C3 — `.gitignore`, CI workflow, `CHANGELOG.md`, pre-commit hook, one tool folder
- [x] C4 — Localization set up and every widget-rendered string moved: `l10n.yaml`,
      `lib/l10n/app_en.arb` with 372 described keys, 20 source files converted.
      **Two pockets remain** — the entry template catalogue and the export feature's
      service-produced strings. See section 4.

### C2 — strict guidelines conformance (opened 2026-09-15)

Against guidelines commit `7ed5a36`. Plan:
`plans/20260915_200933_strict-guidelines-conformance.md`. Baseline before any change:
`flutter analyze` clean, 840 tests passing.

- [x] Phase 1 — docs: `CLAUDE.md`, `AGENTS.md`, `GUIDELINES_MANIFEST.md`, `release_process.md`
      (§6.4–§6.7, §8, §9, §9A), `security.md`, `architecture.md`, `workflow_rules.md`,
      `dependencies.md`, `project_structure.md`
- [x] Phase 2 — Android `enableSplit = false`, `@string/app_name`, plan file rename, stray folder
- [x] Phase 3 — Sanskrit delegates, `formattingLocale`, Devanagari font, language picker
- [x] Phase 4 — localized About config and the "Made with ❤️ from India" badge
- [x] Phase 5 — tooltips on every icon-only control
- [x] Phase 6 — ARB key rename, Malayalam fixes, literal pockets (templates, export, AirQR,
      sync, time capsules, permissions, security events and more), full Sanskrit (1,657 keys),
      short-label pass
- [x] Phase 7 — parity, label-length, delegate, locale and tooltip tests; Sanskrit marker gate in
      CI and the pre-commit hook
- [x] Phase 8 — every source and test file at or under 500 lines

Result (2026-09-16): `flutter analyze` clean, **881 tests passing**, Sanskrit marker gate passing,
absolute-path and permission guards passing. Every Malayalam and Sanskrit string still needs a
fluent reader's review before release (§8.5.4).

---

## 3. Delivered later than planned

Two audits in 2026-07 found features whose data layer, native layer and tests all passed, but whose
user-facing path was never connected. Full detail in [`architecture.md`](architecture.md)
section 21.

| Piece | Was | Now |
|---|---|---|
| Attachment open | `UnimplementedError` — tapping any attachment crashed | Implemented on `open_filex`, 8 tests |
| Storage migration | `UnimplementedError` behind a fully wired UI | Implemented both directions over the SAF channel |
| Storage location | Ignored the setting, always wrote app-private | Location-aware on write, read, delete and migrate |
| Smart tags | Built and tested, imported by no screen | Chip bar mounted in the editor, 4 widget tests |
| In-app PDF / audio / archive viewers | Decisions computed, no screen read them | Delivered as `attachment_viewer_screen.dart` and its three bodies, 12 tests |
| Export | Nothing in `lib/` wrote an entry out | `lib/features/export/`, four formats |

The lesson worth keeping: a passing unit test does not prove a feature is reachable. Check the
screen, not only the service.

---

## 4. Still open

### Release-blocking

- [ ] **The release keystore does not exist.** Gradle reads `android/key.properties`, but with no
      keystore the build falls back to the **debug key**. A debug-signed build must not be
      installed — switching to a real key later needs an uninstall, which destroys all journal data.
      Next step: the `keytool` command in [`release_process.md`](release_process.md) section 0.
- [ ] **R8 has never been runtime-verified.** It compiles, but no shrunk, obfuscated build has run
      on a device. Missing keep rules fail only at runtime.

### Sensitive data

- [ ] No "Delete all data" action anywhere in `lib/`. Required by the standard, section 15.4.
- [ ] The SQLite database is not encrypted at rest. Risk-accepted; only defeated by root or an
      offline flash dump.
- [ ] The attachment crypto format has no version byte. Cheap now, expensive later. It can
      adopt `VaultEnvelope` (A5.2), which is why that class sits in `lib/core/security/`.
- [x] Backup restore, with round-trip test — built 2026-08-18 (A4.1). Preview, replace or
      merge, dry run, gated behind the PIN or device check.
- [ ] No malformed-import test.
- [ ] Existing log statements have not been audited against the logging policy.
- [ ] `ACCESS_NETWORK_STATE` and `WAKE_LOCK` arrive transitively from plugins and are unused.
- [ ] No retention caps on entry revisions, security events, or sync logs.

### Sync (prompt 19)

- [ ] `SyncEngine` is constructed by nothing, and `SyncProtocol` has no concrete implementation, so
      nothing can push or pull. `SyncEncryptionService` and `ConflictResolutionService` are real and
      tested — the transport is the whole gap. The UI is hidden behind
      `AppFlavorConfig.enableSyncUi` (currently `false`).
      Next step: choose a transport (REST, WebDAV, folder sync), then write a plan for it.

### Core baseline

- [ ] `lib/app/app.dart` is about 2,950 lines, holding the shell, navigation and all of settings.
      Needs its own plan — a pure refactor with real regression risk.
- [ ] The Home tab has no error state. A load failure leaves the spinner up forever.
- [ ] `dev` and `prod` share one application ID, so they cannot be installed side by side.
- [ ] `plans/`, `change_log/` and four `docs/` files are not tracked by git, so the committed
      record the standard assumes does not exist yet.
- [ ] `plans/Remediation_Plan.md` does not use the required `yyyymmdd_hhMMss_<slug>.md` name.

### Localization pockets still open

- [ ] `lib/features/entries/templates/entry_templates.dart` — 46 templates, each with a label,
      description, default title and a whole prefilled document. Roughly 190 short strings plus 46
      documents, held in a `const` catalogue that providers read. Needs its own plan, starting with
      the question of whether template bodies count as UI text or as seeded content.
- [ ] `lib/features/export/export_strings.dart` — exported-document content (written by renderers
      with no `BuildContext`) plus service-produced messages. Closing the second half needs an
      error model: `ExportOmission` carrying a reason enum, typed PDF exceptions, and a mapping in
      `export_screen.dart`.

---

## 5. Related documents

- [`implementation_plan.md`](implementation_plan.md) — the roadmap these items belong to
- [`ai_development_prompts.md`](ai_development_prompts.md) — the prompts and their inline markers
- [`architecture.md`](architecture.md) section 21 — the full known-gap record, with detail
- [`release_process.md`](release_process.md) — what must be true before a release
