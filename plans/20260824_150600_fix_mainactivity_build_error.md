# Plan: Fix MainActivity Kotlin Compilation Errors

**Status:** completed  
**Created:** 2026-08-24 15:06:00 IST  
**Scope:** `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`

---

## 1. Problem & Root Cause

During `flutter build apk --flavor prod --release --split-per-abi`, Kotlin compilation fails in `MainActivity.kt`:

1. `android.app.ActivityThread` is an internal Android hidden/private framework API (`@hide`) that is not exposed in public Android SDK compilation stubs. Attempting to call `ActivityThread.currentApplication()` causes `Unresolved reference 'ActivityThread'`.
2. Due to the unresolved type on `ActivityThread`, type inference fails on subsequent calls to `contentResolver.query`, `.use {}`, `moveToFirst()`, `getColumnIndex()`, etc.
3. Top-level helper functions `extractSharePayload` and `resolveMediaItem` were missing an explicit `Context` parameter to query `context.contentResolver` safely and cleanly using standard Android APIs.

---

## 2. Proposed Changes

### `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`
- Update `extractSharePayload(context: Context, intent: Intent?)` to accept `context: Context`.
- Update `resolveMediaItem(context: Context, uri: Uri)` to accept `context: Context`.
- Replace the `ActivityThread.currentApplication()` reference with `context.contentResolver`.
- In `MainActivity.onCreate`: pass `applicationContext` to `extractSharePayload(applicationContext, intent)`.
- In `MainActivity.onNewIntent`: pass `applicationContext` to `extractSharePayload(applicationContext, intent)`.

---

## 3. Verification Plan

1. Verify static compilation by building release APK:
   `flutter build apk --flavor prod --release --split-per-abi`
2. Run Flutter test suite:
   `flutter test`
3. Run static analyzer:
   `flutter analyze`
