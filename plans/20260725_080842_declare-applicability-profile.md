# Declare the applicability profile for SreerajP Journal Vault

**Status:** completed

## What is the issue

The engineering standard, section 1.2, says:

> Every Flutter repository MUST declare which profile applies.

This app has never declared one. The place to write it down is section 1 of `architecture.md`,
which is still a blank template inside the submodule. There is no local copy in the app's own
`docs/` folder, so there is nowhere the declaration currently lives.

Until the profile is declared, nobody can tell which rules are binding and which are optional.

## The evidence I gathered

I read the code and the workspace documents before deciding. This is what they show.

### The app plainly handles sensitive data

| Evidence | Where |
|---|---|
| Attachments encrypted with AES-256-GCM, per-file IV, Keystore-backed keys | `AGENTS.md`; `lib/features/attachments/services/attachment_crypto_storage.dart` |
| PIN and biometric app lock | `lib/features/lock_gate/` |
| Per-journal lock with secrets in a Keystore-backed store | `lib/features/journal_lock/` |
| Encrypted sync payloads | `lib/features/sync/services/sync_encryption_service.dart` |
| The content itself is a private personal diary — PII by definition | whole product |

The standard's trigger for `Sensitive Data Extension` is "auth secrets, financial data, health
data, PII, or locally encrypted content". This app hits three of those five.

### The app is built to be released, not just experimented with

`journal_vault_plan.md` says, in its own words:

- V1 goal: "Ship a **production-ready** core journal app"
- Delivery: "Complete V1 and **release** stable baseline"
- Every increment ends with "**release candidate sign-off**"
- Android flavors `dev` and `prod` already exist in `android/app/build.gradle.kts`

You confirmed the audience is **yourself, sideloaded** — no store, no other users. Strictly read,
"shipped to real users" could be argued either way. I am recommending we apply it anyway, because
your own plan is written to a release standard, and because a bug in a journal app on your daily
phone loses your writing. The release rules exist to prevent exactly that.

## The decision

**All three profiles are in force:**

| Profile | In force | Why |
|---|---|---|
| `Core Baseline` | Yes | Mandatory for every Flutter app. No judgement needed. |
| `Production App Extension` | Yes | The project is planned and executed to a release standard, with flavors and release sign-off gates already defined. |
| `Sensitive Data Extension` | Yes | Encrypted attachments, PIN/biometric lock, Keystore secrets, encrypted sync, and private personal content. |

That means these documents are binding, not optional:

- `guideline.md` and the Core Baseline rules of the engineering standard
- `architecture.md` — must be filled in for this app
- `release_process.md` and `flutter_build_flavors_guide.md` (flavors are already in use)
- `security.md` — must be filled in for this app
- The Production and Sensitive Data sections of the engineering standard, including the
  OWASP Mobile Top 10 checklist (section 15.3) and the retention/purge policy (section 15.4)

## Files to be changed

| File | Change |
|---|---|
| `SreerajP_Journal_Vault/docs/architecture.md` | **New.** Local copy of the template with section 1 filled in — the profile declaration. Other sections seeded from what I can verify in the code; anything I cannot verify is left as an explicit `TODO`, not invented. |
| `SreerajP_Journal_Vault/CLAUDE.md` | **Edit.** Add a short block naming the three profiles, so it is visible without opening architecture.md. |
| `plans/20260725_080842_declare-applicability-profile.md` | This plan. |
| `change_log/<timestamp>_declare-applicability-profile.md` | New. Written after the work. |

Nothing inside `docs/guidelines/` is touched — that is the shared submodule.

## The plan

1. Copy `docs/guidelines/architecture.md` to `docs/architecture.md` as the app's local copy. Per
   the manifest's "local copy wins" rule, this local file becomes the one that governs this app.
2. Fill in **section 1 (Scope)** properly: product name, repository type `application`, all three
   profiles listed as in force, platforms.
3. Fill in the sections I can verify **from the code**, with file references:
   - section 4 repository structure and tier
   - section 8 state management (Riverpod)
   - section 11 database (Drift/SQLite, current schema version read from `app_database.dart`)
   - section 14 persistence (Drift, Keystore via method channel)
   - section 15 build model (the `dev`/`prod` flavors that exist today)
   - section 22 related documents
4. For every section I cannot verify without guessing, write `TODO — not yet decided` with a
   one-line note on what is missing. I will not invent architecture that is not in the code.
   The template itself says to do this rather than populate the form for its own sake.
5. Add the profile block to `CLAUDE.md`.
6. Write a **gap list** at the end of `architecture.md` under section 21 (Known Risks And
   Follow-Ups), recording what the newly-in-force rules require that the app does not do yet.
   I already found these three while reading:
   - **Release builds are signed with debug keys.** `android/app/build.gradle.kts` still has the
     Flutter starter comment `TODO: Add your own signing config`. Under `Production App
     Extension` this is release-blocking. It also breaks `guideline.md`, which the manifest
     names as the source of truth for keystore rules.
   - **`security.md` is not filled in.** Required under `Sensitive Data Extension`, including the
     data retention and purge policy and the OWASP checklist.
   - **`release_process.md` is not filled in.** Required under `Production App Extension`.
7. Commit the change to the repository created earlier today. Nothing is pushed — there is still
   no remote.
8. Write the change log and set this plan to `completed`.

## What is deliberately NOT in this plan

- **Fixing the debug-signing problem.** It is recorded as a gap here, but changing signing config
  touches your release keystore and is its own job. It needs its own plan.
- **Filling in `security.md`.** That is a real piece of work — threat model, data inventory,
  crypto design, OWASP checklist. Separate plan.
- **Filling in `release_process.md`.** Same. Separate plan.
- **Completing every section of `architecture.md`.** I will fill what the code proves and mark the
  rest `TODO`. Finishing it needs decisions only you can make.

This plan produces the declaration and an honest gap list. It does not close the gaps.

## Do you approve this plan?
