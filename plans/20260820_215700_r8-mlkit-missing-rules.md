# Fix R8 Proguard Missing Rules for ML Kit Text Recognition

**Status:** Completed

## Problem
During release compilation (`flutter build apk --flavor prod --release --split-per-abi`), R8 fails with missing class errors:
```
ERROR: Missing classes detected while running R8.
Missing class com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions...
Missing class com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions...
Missing class com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions...
Missing class com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions...
```
`google_mlkit_text_recognition` references optional language script packages (Chinese, Devanagari, Japanese, Korean) in its initialization method. Since this project only uses the default Latin script recognition library, R8 treats the missing optional classes as an error unless `-dontwarn` rules are added.

## Proposed Changes

### Proguard Rules
- Modify `android/app/proguard-rules.pro` to add `-dontwarn` rules for the unbundled ML Kit text recognition script options (`chinese`, `devanagari`, `japanese`, `korean`).

## Verification
- Run `flutter build apk --flavor prod --release --split-per-abi` to verify R8 minification and APK generation succeed without errors.
