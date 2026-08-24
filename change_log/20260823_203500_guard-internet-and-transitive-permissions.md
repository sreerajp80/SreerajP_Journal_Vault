# Change Log: Guard Missing INTERNET and Transitive Permissions (A5.3)

**Date:** 2026-08-23
**Plan reference:** [`plans/20260823_202800_guard-internet-and-transitive-permissions.md`](../plans/20260823_202800_guard-internet-and-transitive-permissions.md)

---

## What was changed

### 1. Production Manifest Hardening
- Added `xmlns:tools="http://schemas.android.com/tools"` namespace to `android/app/src/main/AndroidManifest.xml`.
- Added explicit `tools:node="remove"` entries in `android/app/src/main/AndroidManifest.xml` for:
  - `android.permission.INTERNET`
  - `android.permission.ACCESS_NETWORK_STATE`
  - `android.permission.WAKE_LOCK`
- Configured `android/app/src/debug/AndroidManifest.xml` and `android/app/src/profile/AndroidManifest.xml` with `tools:node="replace"` for `INTERNET` so local developer debugging (such as VM service connections and hot reload) continues to work seamlessly during development.

### 2. CI Automation & Verification Guard Script
- Added `tool/check_no_internet_permission.sh` to verify that `main/AndroidManifest.xml` explicitly contains `tools:node="remove"` for `INTERNET`, `ACCESS_NETWORK_STATE`, and `WAKE_LOCK`, and that any merged release manifest contains no prohibited permissions.
- Added `permission-guard-check` job to `.github/workflows/ci.yml` to ensure future PRs and commits cannot introduce network or wake permissions.

### 3. Automated Guard Tests
- Added unit tests in `test/core/security/manifest_permission_guard_test.dart` asserting that the main manifest contains explicit removal declarations and debug/profile manifests properly specify replacement nodes.

### 4. Documentation Updates
- Updated `docs/security.md` (Section 11 permissions table and hardening gap #10).
- Updated `docs/features.md` (Section 1 zero-telemetry guarantee and resolved gap #6).
- Updated `docs/enhancement_ideas.md` (marked A5.3 implemented).

---

## Verification

- `flutter test test/core/security/manifest_permission_guard_test.dart` passed (2/2 tests).
- `sh tool/check_no_internet_permission.sh` passed.
- `sh tool/check_absolute_paths.sh --all` passed with 0 violations.
- `flutter analyze` completed with 0 issues.
- `flutter test` passed full suite.
