# Change log — Declare the applicability profile

**Date:** 2026-07-25 08:14 (local time)
**Implements:** [`plans/20260725_080842_declare-applicability-profile.md`](../plans/20260725_080842_declare-applicability-profile.md)

## Why

The engineering standard section 1.2 says every Flutter repository MUST declare which
applicability profile applies. This app had never declared one, so there was no way to tell which
rules were binding.

## The decision

**All three profiles are in force:** `Core Baseline`, `Production App Extension`, and
`Sensitive Data Extension`.

Evidence used:

- **Sensitive Data** — AES-256-GCM encrypted attachments, PIN and biometric lock, journal secrets
  held in the Android Keystore, encrypted sync payloads, and private diary content that is PII.
  Three of the standard's five triggers.
- **Production App** — `journal_vault_plan.md` sets "production-ready" V1 goals, a
  release delivery sequence, and release-candidate sign-off gates. `dev` and `prod` Android
  flavors already exist. The user confirmed distribution is sideload-to-self only; the release
  rules were still applied, because a bad build loses real journal content.

## What was done

1. **Created `SreerajP_Journal_Vault/docs/architecture.md`** — the app's local copy of the
   template. Per the manifest's "local copy wins" rule, this now governs the app instead of the
   submodule copy.
2. **Filled section 1** with the profile declaration and a table explaining why each applies, plus
   a list of which documents that makes binding.
3. **Filled the sections the code proves**, with file references — structure and tier (4),
   architecture summary (3), state management (8), data flow (9), schema version 7 and the full
   v1→v7 migration history (11), dependency injection (12), navigation (13), persistence and
   platform channels (14), build model (15), UI system (16), testing (18), and decisions (20).
4. **Marked the rest `TODO`** rather than inventing content — initialization sequence (5),
   lifecycle table (6), error handling (10), logging (17), and others. The template explicitly
   says to do this.
5. **Recorded a gap list in section 21** — see below.
6. **Updated `CLAUDE.md`** with a short profile block so the decision is visible without opening
   architecture.md.
7. **Committed** as `59d6719` (2 files, 421 insertions). Working tree clean.

## Gaps found while doing this

These are real findings, not speculation. All are recorded in `docs/architecture.md` section 21.
**None were fixed** — that was out of scope by agreement.

### Release-blocking

- **Release builds are signed with debug keys.** `android/app/build.gradle.kts` still has the
  Flutter starter `signingConfig = signingConfigs.getByName("debug")` and its `TODO` comment. A
  debug-signed app cannot later be updated by a properly signed build, and the debug key is not
  secret. Also breaks `guideline.md`, the source of truth for keystore rules.
- `release_process.md` not filled in.
- Obfuscation not configured (OWASP M7).

### Sensitive Data requirements

- `security.md` not filled in — no threat model, data inventory, OWASP sign-off, or retention and
  purge policy.
- **No screenshot protection.** Section 15.2 says `FLAG_SECURE` MUST be enabled. No `FLAG_SECURE`
  or `setFlags` call exists in `MainActivity.kt`. Journal content is currently capturable by
  screenshot and visible in the task switcher.
- No structured logging; section 15.5 requires it.
- **To verify:** `method_channel_journal_secret_store.dart` and `platform_attachment_key_manager.dart`
  both use `SharedPreferences`, which section 15.2 forbids for sensitive values. Code comments say
  the native side Keystore-wraps the secret first, so only ciphertext is stored — that would be
  compliant. Confirming needs a read of `MainActivity.kt`, which was not done.

### Core Baseline hygiene

- Four **empty** leftover folders: `lib/application/`, `lib/data/`, `lib/domain/`,
  `lib/presentation/` — zero files each, contradicting the declared feature-first structure.
- `go_router: ^17.1.0` declared but imported nowhere (supply-chain surface, OWASP M2).
- `lib/app/app.dart` is 2,568 lines and holds the shell, navigation, and all of settings.
- `analysis_options.yaml` is stock — `flutter_lints` is pinned at `^6.0.0` (satisfies the pin
  rule) but none of the recommended stricter rules are added.
- Database migration path v1→v7 is untested, though the standard names it a critical test area.

## Files changed

| File | Change |
|---|---|
| `SreerajP_Journal_Vault/docs/architecture.md` | New — 400+ lines, the declaration and gap list. |
| `SreerajP_Journal_Vault/CLAUDE.md` | Edited — added the profile block. |

Nothing inside `docs/guidelines/` was touched. Nothing was pushed; the repository still has no
remote.

## Suggested next steps, in order of risk

1. Fix the debug signing config — needs its own plan, touches the release keystore.
2. Add `FLAG_SECURE` — small change, closes a real privacy hole in a diary app.
3. Fill in `security.md`.
4. Fill in `release_process.md`.
5. Core Baseline cleanup — delete the empty folders, drop `go_router`, split `app.dart`.
