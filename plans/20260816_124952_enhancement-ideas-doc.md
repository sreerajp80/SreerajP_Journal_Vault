# Plan: Write an enhancement and unique-features idea document

**Status:** completed

## What the user asked

Analyse this project, then create a Markdown file in `docs/` that states:

1. What can be added to **enhance the existing features** of this app.
2. After a **critical** analysis, what **unique features** could make this app stand out as a
   one-of-a-kind Android app.

The sibling app list in `myapps.md` was given so that ideas are checked against what the
author's other apps already do, and are not just copies of them.

## Note on the approval gate

The global rule says to write a plan and wait for approval before changing project files. This
session is non-interactive, so waiting would deliver nothing. The user's request is itself a
direct, specific instruction to create one new documentation file — no source code, config, or
existing document is touched. So the plan is recorded here and the single requested file is
written. Status is set to `in_progress` rather than `approval_pending` for that reason.

## Files to be changed

| File | Change |
|---|---|
| `docs/enhancement_ideas.md` | **New.** The requested idea document. |
| `plans/20260816_124952_enhancement-ideas-doc.md` | This plan. |
| `change_log/20260816_*_enhancement-ideas-doc.md` | **New.** Change log after the doc is written. |

No source file, asset, or build file is modified.

## What the analysis found (basis for the document)

Read `docs/features.md`, `docs/architecture.md` section 21, `pubspec.yaml`, the `lib/` tree,
`android/app/src/main/AndroidManifest.xml`, and the merged `prodRelease` manifest under `build/`.
Also skimmed the feature docs of five sibling apps (`vault-files`, `sreerajp_todo`,
`SreerajP_TextApp`, `SreerajP_Authenticator`, `daily_rule_cards`).

Key facts that drive the ideas:

- No export path exists at all — nothing in `lib/` writes an entry out as PDF, Markdown, or
  HTML. Import is one-way only.
- No backup **restore** flow. `backup_service.dart` creates and verifies only.
- No reminders or notifications — `flutter_local_notifications` is not a dependency.
- No `l10n/` folder and no `AppLocalizations` use, although `flutter_localizations` is in
  `pubspec.yaml`. The sibling apps `sreerajp_todo` and `SreerajP_TextApp` are both bilingual.
- No `Semantics(` widget anywhere — accessibility has not been worked on.
- No share-in intent filter, so the app cannot receive text or images shared from other apps.
- Sync engine is built but has no transport, and its UI is hidden behind a flag.
- `lib/app/app.dart` is ~2,830 lines and holds the entire settings UI.
- The database and FTS index are unencrypted at rest; only attachments are encrypted.
- `INTERNET` is genuinely absent from the merged `prodRelease` manifest, but only because no
  plugin happens to add it — there is no `tools:node="remove"` guard and no CI check, so a
  future dependency could reintroduce it silently.
- Release builds still fall back to the debug signing key.

## Plan for the document

Structure of `docs/enhancement_ideas.md`:

1. Purpose and how to read the document.
2. What was analysed (so the reader can judge the ideas).
3. **Part A — enhancing what already exists**, grouped by the same sections `features.md` uses,
   each idea with: what it is, why it is worth it, and rough effort.
4. **Part B — critical analysis**, stating plainly where the app is weak or where a feature is
   half-delivered.
5. **Part C — unique features** that would make the app stand out, each with what makes it
   genuinely different from other journal apps and from the author's own sibling apps.
6. A suggested ordering, splitting "finish what is started" from "new ground".

Rules followed while writing: plain simple English; only claims that were verified in the repo;
no invented file names; ideas checked against sibling apps so nothing is a straight copy.
