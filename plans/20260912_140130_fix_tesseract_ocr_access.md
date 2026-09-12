# Plan: Fix Tesseract OCR Private Member Access in MainActivity

**Status:** Completed  
**Created:** 2026-09-12 14:01:30 IST  
**Scope:** `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`

---

## 1. Problem & Root Cause

During `flutter build apk --flavor prod --release`, Kotlin compilation fails with:
- `Cannot access 'var activeTessApi: TessBaseAPI?': it is private in 'MainActivity'`
- `Cannot access 'var activeTessLang: String?': it is private in 'MainActivity'`

### Root Cause
In `MainActivity.kt`:
1. `activeTessApi` and `activeTessLang` are declared as private instance variables inside `class MainActivity`.
2. The function `performTesseractOcr` was declared outside `class MainActivity` as an extension function (`private fun MainActivity.performTesseractOcr(...)`).
3. In Kotlin, extension functions declared outside the class body cannot access private members of that class.

---

## 2. Proposed Changes

### `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`
- Move `performTesseractOcr(...)` inside the body of `class MainActivity` as a member function (`private fun performTesseractOcr(...)`).
- Remove the top-level extension function declaration from the bottom of the file.

---

## 3. Verification Plan

1. Verify Kotlin compilation by building the release APK:
   `flutter build apk --flavor prod --release --split-per-abi`
2. Run Flutter static analysis:
   `flutter analyze`
3. Run test suite:
   `flutter test`
