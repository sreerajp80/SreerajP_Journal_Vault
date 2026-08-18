# Change log: enhancement and unique-features idea document

**Date:** 2026-08-16
**Implements:** [`plans/20260816_124952_enhancement-ideas-doc.md`](../plans/20260816_124952_enhancement-ideas-doc.md)

## What changed

One new documentation file was added. No source code, asset, build file, or existing document was
touched.

| File | Change |
|---|---|
| `docs/enhancement_ideas.md` | **New.** Ideas for enhancing existing features, a critical review of the app, and unique feature ideas. |
| `plans/20260816_124952_enhancement-ideas-doc.md` | **New.** The plan this implements. Status set to `completed`. |
| `change_log/20260816_125800_enhancement-ideas-doc.md` | **New.** This file. |

## What the new document contains

- **Part A** — 34 ideas that build on features the app already has, grouped the same way
  `features.md` is grouped (editor, search, insights, backup, security, app shell). Each has a
  what / why / rough effort.
- **Part B** — a critical review of the app: features that stop one step short of the user,
  the missing export and restore paths, the unencrypted database behind a "hardened vault"
  description, the absence of anything that builds a daily writing habit, and the single-user
  assumptions (no localisation, accessibility, or tablet layout). It also records what the app
  does unusually well.
- **Part C** — 9 unique feature ideas, each checked against both common journal apps and the
  author's own sibling apps from `myapps.md`. Three are marked as strongest: voice-first
  journalling with an aligned searchable audio archive, an on-device personal knowledge graph,
  and cryptographically sealed time capsules.
- A suggested order of work at the end.

## How the ideas were grounded

Read before writing: `docs/features.md`, `docs/architecture.md` section 21, `pubspec.yaml`, the
whole `lib/` tree, `android/app/src/main/AndroidManifest.xml`, the merged `prodRelease` manifest
under `build/`, and the feature documents of five sibling apps (`vault-files`, `sreerajp_todo`,
`SreerajP_TextApp`, `SreerajP_Authenticator`, `daily_rule_cards`).

Facts checked in the repo rather than assumed:

- No export code exists anywhere in `lib/`.
- No `lib/l10n/` folder and no `AppLocalizations` use, despite `flutter_localizations` being a
  dependency.
- No `Semantics(` widget anywhere in `lib/`.
- `INTERNET` is genuinely absent from the merged `prodRelease` manifest — but only because no
  plugin currently requests it. There is no `tools:node="remove"` guard and no build check, which
  is why the document raises it as a real risk rather than a solved item.
- `flutter_local_notifications` is not a dependency, so the app has no notification capability.

## Note on the approval gate

The global workflow rule asks for approval before changing project files. This session was
non-interactive, so the plan was written and the single requested documentation file was created
in the same pass. No existing file was modified.
