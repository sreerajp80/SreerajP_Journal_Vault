# Plan: A5.3 Guard the missing INTERNET permission and unused permissions

**Status:** Complete
**Date:** 2026-08-23
**Feature:** A5.3 Guard the missing INTERNET permission

---

## 1. Context & Motivation

The app makes a strict zero-telemetry, fully offline guarantee: no user journal content or metadata may ever leave the device.

Today, the `INTERNET` permission is absent from production releases, but this is only true because current plugin dependencies happen not to request it. If any current dependency is upgraded or a new package is added that pulls in `INTERNET` transitively, Android Gradle Plugin would merge it into the production manifest silently.

Additionally, two unused permissions (`ACCESS_NETWORK_STATE` and `WAKE_LOCK`) are pulled in transitively from third-party plugins.

To guarantee offline isolation permanently and prevent silent regression:
1. Production manifests must explicitly remove `android.permission.INTERNET`, `android.permission.ACCESS_NETWORK_STATE`, and `android.permission.WAKE_LOCK` using `tools:node="remove"`.
2. Debug and profile manifests must use `tools:node="replace"` for `INTERNET` so local Flutter development tools and VM service continue to function during development.
3. A verification script and CI check must fail any build where `INTERNET`, `ACCESS_NETWORK_STATE`, or `WAKE_LOCK` appear unstripped in production manifests.
4. Unit/guard tests must test and enforce this invariant.

---

## 2. Scope of Changes

### A. Android Manifest Hardening
- `android/app/src/main/AndroidManifest.xml`:
  - Add `xmlns:tools="http://schemas.android.com/tools"` namespace.
  - Add `<uses-permission android:name="android.permission.INTERNET" tools:node="remove" />`.
  - Add `<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" tools:node="remove" />`.
  - Add `<uses-permission android:name="android.permission.WAKE_LOCK" tools:node="remove" />`.
- `android/app/src/debug/AndroidManifest.xml`:
  - Add `xmlns:tools="http://schemas.android.com/tools"`.
  - Update `android.permission.INTERNET` with `tools:node="replace"` so debug hot-reload/profiling remains supported.
- `android/app/src/profile/AndroidManifest.xml`:
  - Add `xmlns:tools="http://schemas.android.com/tools"`.
  - Update `android.permission.INTERNET` with `tools:node="replace"`.

### B. CI and Automation Guard Script
- `tool/check_no_internet_permission.sh`:
  - Shell script that verifies:
    1. `android/app/src/main/AndroidManifest.xml` contains explicit `tools:node="remove"` for `INTERNET`, `ACCESS_NETWORK_STATE`, and `WAKE_LOCK`.
    2. Any provided or generated merged manifest does not contain active `INTERNET`, `ACCESS_NETWORK_STATE`, or `WAKE_LOCK` permissions.
- `.github/workflows/ci.yml`:
  - Add a CI check step running `sh tool/check_no_internet_permission.sh`.

### C. Tests
- `test/core/security/manifest_permission_guard_test.dart`:
  - Unit tests verifying that `android/app/src/main/AndroidManifest.xml` contains all three `tools:node="remove"` declarations.
  - Unit tests verifying debug and profile manifest overrides (`tools:node="replace"`).

### D. Documentation Updates
- `docs/security.md`:
  - Update Section 11 (Permissions table and notes on `ACCESS_NETWORK_STATE` and `WAKE_LOCK`).
  - Update Section 17 / Section 18 checklist & gap lists.
- `docs/features.md`:
  - Update Section 1 zero-telemetry offline guarantee and resolve gap #6.
- `docs/architecture.md`:
  - Update Section 21 gap #6 to show `ACCESS_NETWORK_STATE` and `WAKE_LOCK` are stripped.
- `docs/implementation_progress.md`:
  - Check off the permission removal item.
- `docs/enhancement_ideas.md`:
  - Mark item A5.3 completed.

---

## 3. Verification Plan

### Automated Tests & Checks
- Run `flutter test test/core/security/manifest_permission_guard_test.dart`.
- Run `sh tool/check_no_internet_permission.sh`.
- Run `sh tool/check_absolute_paths.sh --all`.
- Run `flutter analyze`.
- Run full test suite: `flutter test`.

---
