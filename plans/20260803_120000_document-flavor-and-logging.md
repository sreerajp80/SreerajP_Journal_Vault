# Document build flavors and structured logging in docs/features.md

**Status:** completed

## Files to be changed

- `docs/features.md` (only file changed)

## What the issue is

I re-checked `docs/features.md` against the current code (two earlier passes today already fixed
stale file references, the sync/tamper caveats, journal management, and the search/settings
sections — those are correct and need no further change).

One gap remains. Two real, shipped features have no mention anywhere in the doc:

1. **Dev/prod build flavors.** `android/app/build.gradle.kts` lines 88-97 define an `env` flavor
   dimension with `dev` and `prod` product flavors (different app labels: "sreerajp_journal_vault
   (dev)" vs "sreerajp_journal_vault"). `lib/core/config/app_flavor_config.dart` resolves this at
   compile time from `--dart-define=APP_FLAVOR` or the framework's `FLUTTER_APP_FLAVOR`, defaulting
   to `prod`. This is a real Production App Extension requirement (the app's own `CLAUDE.md` says
   so explicitly) and is already used to gate verbose logging (`enableVerboseLogging => isDev`).

2. **Structured logging via `AppLogger`.** `lib/core/logging/app_logger.dart` is described in its
   own doc comment as "the app's only logging entry point." It wraps the `logger` package (in
   `pubspec.yaml`, not mentioned anywhere in `docs/features.md`), ships info-level-and-above logs
   to the console in prod and trace-level in dev, and enforces a hard rule: never log journal
   titles, entry text, attachment names/bytes, PINs, passwords, key material, or decrypted content
   — with a `redact()` helper for cases that need to distinguish empty/non-empty without leaking
   content. No file output, console only. This is a Sensitive Data Extension requirement
   (engineering standard section 15.5) and deserves a bullet given how much emphasis the rest of
   the doc places on the app's privacy/security posture.

Both were added in recent commits ("Phase 4: make the About screen config-driven", "Phase 6: add
structured logging and a flavor config") after the doc's last two edit passes, which is why they
were missed.

## The plan for the fix

Edit `docs/features.md` only, in place, no new files:

1. **Opening App Description paragraph:** add a short clause noting the app ships `dev`/`prod`
   build flavors with flavor-gated verbose logging, and a zero-file-output structured logger that
   redacts sensitive content by policy. Keep it short, per the simple-English rule.

2. **Section 1 (Security, Privacy & Data Protection):** add a new bullet, "Structured, Privacy-Safe
   Logging", describing `AppLogger` (`app_logger.dart`): console-only output, no log files, prod
   ships info-and-above while dev ships trace-and-above, and the hard rule against logging journal
   content, credentials, or key material, with the `redact()` helper for safe diagnostics.

3. **Section 8 (App Architecture, Navigation & User Experience):** add a bullet, "Dev/Prod Build
   Flavors", describing the Android `productFlavors` (`dev`, `prod`) with distinct app labels, and
   `AppFlavorConfig` as the single compile-time source of truth for flavor-gated behavior (verbose
   logging today; also the switch point for `enableSyncUi` already mentioned in Section 7).

No other sections need changes.

## Change log

Will be written to `change_log/` after this edit is applied.
