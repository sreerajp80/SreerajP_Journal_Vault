# Document build flavors and structured logging in docs/features.md

Implements: `plans/20260803_120000_document-flavor-and-logging.md`

## What changed

Edited `docs/features.md` only:

1. **App Description (opening paragraph):** added a clause noting the app ships dev/prod build
   flavors with flavor-gated verbose logging, and a console-only structured logger that redacts
   sensitive content by policy.

2. **Section 1 (Security, Privacy & Data Protection):** added a new bullet, "Structured,
   Privacy-Safe Logging", describing `AppLogger` (`app_logger.dart`) — console-only output, no log
   files, info-and-above in prod vs. trace-and-above in dev, the hard rule against logging journal
   content or credentials, and the `redact()` helper.

3. **Section 8 (App Architecture, Navigation & User Experience):** added a new bullet, "Dev/Prod
   Build Flavors", describing the Android `productFlavors` (`dev`, `prod`) with distinct app
   labels, and `AppFlavorConfig` as the compile-time source of truth for flavor-gated behavior.

## Why

`docs/features.md` had two real, shipped features with no mention anywhere: dev/prod build
flavors (`android/app/build.gradle.kts`, `app_flavor_config.dart`) and structured privacy-safe
logging (`app_logger.dart`, the `logger` package in `pubspec.yaml`). Both were added in recent
commits ("Phase 4", "Phase 6") after the doc's last two edit passes, so they were missed. This
change closes that gap; no other sections needed changes.
