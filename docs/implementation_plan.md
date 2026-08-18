# Implementation Plan — SreerajP Journal Vault

The phase-by-phase roadmap for building this app: what each phase delivers, in what order, and how
each one is checked. This is a point-in-time record — it is the plan as it stands on the date
below, not a running status. For status, read
[`implementation_progress.md`](implementation_progress.md).

**Date:** 2026-08-18
**Scope:** V1 through V3, plus the conformance work opened in 2026-08.
**Source:** condensed from [`journal_vault_plan.md`](journal_vault_plan.md) (the product plan) and
[`ai_development_prompts.md`](ai_development_prompts.md) (the numbered build prompts).

Read first: [`../CLAUDE.md`](../CLAUDE.md) · [`architecture.md`](architecture.md) ·
[`workflow_rules.md`](workflow_rules.md)

---

## 1. How the work is sliced

Work is built one numbered prompt at a time, never two at once. Each prompt is a small, testable
slice with its own acceptance criteria. After each one: run the formatter, the analyzer and the
tests for the changed scope, check the acceptance criteria, then mark the prompt in
[`ai_development_prompts.md`](ai_development_prompts.md).

**The V1 backbone runs in order:** `00 → 01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 12 → 13 → 14`.

**Safe to build in parallel once the scaffold (`00`) is done:** `09` permissions, `10` theme,
`11` about.

**Security-sensitive chains that must stay in order:** `05 → 06 → 12`, and `07 → 08`.

---

## 2. Phase V1 — Secure MVP foundation

**Objective:** ship a production-ready core journal app with security, attachments, permissions,
and a baseline backup and export path.

| Prompt | Delivers |
|---|---|
| 00 | Project scaffold, navigation, theming, Riverpod boundaries |
| 01 | Drift schema v1, DAOs, migrations, repositories |
| 02 | Home screen and journal CRUD |
| 03 | Journal detail and entry list |
| 04 | Rich text editor baseline |
| 05 | Attachment import and open routing |
| 06 | Attachment encryption storage service (AES-256-GCM, Keystore keys) |
| 07 | App lock modes — `phone_lock` or `app_lock`, one active at a time |
| 08 | Journal lock and security basics |
| 09 | Permissions Center and the runtime permission flow |
| 10 | Theme selection, Light and Dark, persisted |
| 11 | About screen driven by `assets/config/app_config.json` |
| 12 | Attachment storage migration, app-private ↔ SD card |
| 13 | Search v1 — basic search and saved filters |
| 14 | V1 polish and release hardening |

**Done when:** the V1 UI freeze checkpoint passes, migrations are tested, Light and Dark both
render correctly, and a release candidate is signed off.

---

## 3. Phase V2 — Knowledge, productivity and reliability

**Objective:** make journaling smarter, and make backup and import trustworthy.

Delivered in two increments.

### V2.1 — search, templates, backlinks, editor

| Prompt | Delivers |
|---|---|
| 15 | Entry templates (daily, travel, meeting, gratitude, mood) and wiki-style backlinks |
| 16 | FTS5 full-text search, smart tag suggestions, the timeline calendar |
| 17 | Advanced editor blocks — tables, callouts — and media handling |

### V2.2 — import, backup, history

| Prompt | Delivers |
|---|---|
| 18 | Import, the backup scheduler, and version history |

**Done when:** search returns correct results over both entry text and indexed attachment text,
a backup can be produced on schedule, and version history restores an earlier revision.

---

## 4. Phase V3 — Intelligence, sync and insight

**Objective:** grow from a single-device journal into a multi-device personal knowledge system.

### V3.1 — sync

| Prompt | Delivers |
|---|---|
| 19 | Encrypted multi-device sync and conflict resolution |

### V3.2 — insight and advanced security

| Prompt | Delivers |
|---|---|
| 20 | Insights, reflection, auto-lock profiles, attachment-level lock, tamper alerts, local-only mode |

**Done when:** two devices converge on the same journal without data loss, and the insights screen
reports real numbers over real entries.

---

## 5. Phase A — post-V1 additions (opened 2026-08)

Work that was not in the original prompt list but became necessary.

| Slice | Delivers | State |
|---|---|---|
| A1.1 / W5 | Entry and journal export — Markdown, HTML, plain text, PDF | Delivered 2026-08-16 |
| A4.2 | Encrypting the exported file, sharing the envelope format with backup | Deferred |

---

## 6. Phase C — guidelines conformance (opened 2026-08-18)

Closing the gaps between the repository and the guideline documents. Planned in
`plans/20260818_100606_guidelines-conformance-audit.md`.

| Step | Delivers |
|---|---|
| C1 | `CLAUDE.md`, `AGENTS.md` and `README.md` rewritten to their guidelines; real `pubspec` description |
| C2 | The missing `docs/` baseline set, and `snake_case` doc names |
| C3 | `.gitignore` completions, CI workflow, `CHANGELOG.md`, a stronger pre-commit hook, one tool folder |
| C4 | Localization — `l10n.yaml`, `lib/l10n/app_en.arb`, and every user-visible string read through `AppLocalizations` |

**Done when:** every `MUST` in
[`guidelines/flutter_project_engineering_standard.md`](guidelines/flutter_project_engineering_standard.md)
and [`guidelines/guideline.md`](guidelines/guideline.md) is either satisfied or recorded as an open
gap in [`architecture.md`](architecture.md) section 21.

---

## 7. Verification at the end of every increment

Each increment ends with the same five checks, from the delivery sequence in
[`journal_vault_plan.md`](journal_vault_plan.md):

1. Regression testing across everything already built.
2. Theme parity — every screen checked in Light and Dark.
3. Migration validation from every earlier schema version.
4. Release-candidate sign-off against
   [`release_process.md`](release_process.md).
5. The Definition of Done in [`workflow_rules.md`](workflow_rules.md) section 5.

---

## 8. Related documents

- [`implementation_progress.md`](implementation_progress.md) — what is actually finished
- [`ai_development_prompts.md`](ai_development_prompts.md) — the prompts themselves
- [`journal_vault_plan.md`](journal_vault_plan.md) — the product plan this condenses
- [`architecture.md`](architecture.md) — section 21 lists the known gaps
- [`enhancement_ideas.md`](enhancement_ideas.md) — ideas not yet in any phase
