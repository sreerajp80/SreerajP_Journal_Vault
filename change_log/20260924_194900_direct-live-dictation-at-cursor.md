# Voice Dictation: Direct Live Typing at Cursor (Option A) and Repetition Fix

**Date:** 2026-09-24  
**Plan:** `plans/20260924_194900_direct-live-dictation-at-cursor.md`

## Summary of changes

1. **Direct Live Typing at the Cursor (`entry_editor_actions_3.dart`, `entry_editor_screen.dart`, `entry_editor_layout.dart`):**
   - Added live inline text replacement at the document caret position.
   - Partial speech guesses appear directly in the editor body in real time while speaking, updating smoothly in-place.
   - When the user pauses or completes a phrase, the phrase finalizes in-place with clean sentence capitalization, punctuation, and surrounding spaces.
   - Moving or tapping the cursor shifts subsequent dictation directly to the newly tapped location.
   - A single Undo action cleanly removes the finalized phrase.

2. **Deduplication and Rolling Overlap Stripping (`dictation_text_cleaner.dart`):**
   - Added `extractUncommittedText(committedText, newText)` which:
     - Strips prefix continuations of already committed text.
     - Detects and trims suffix-prefix overlaps across Android's rolling recognizer acoustic buffer.
     - Filters out full duplicate containment so identical or already-inserted phrases are never re-emitted.

3. **Session-Aware Committed Text & Sync Stream Ordering (`dictation_service.dart`):**
   - Added `_sessionCommittedText` tracking per speech recognition session.
   - Made `_states` stream controller synchronous (`sync: true`) to preserve strict event ordering between partial previews and finalized phrase commits.
   - Updated `_handleResult`, `_isNewUtterance`, and `_commit` to strip already-committed text before emitting partials or commits.
   - Automatically drops empty or duplicate final results from Android's `onResults` callback.

4. **Live Partial Callback Support (`dictation_bar.dart`):**
   - Added `onLivePartial` callback wired to `_service.states` to stream real-time hypotheses to the editor.

5. **Automated Tests:**
   - Added comprehensive tests in `test/features/entries/services/dictation_text_cleaner_test.dart` covering prefix continuations, rolling window overlap trimming, and the exact user 6-sentence speech sequence.
   - Added unit tests in `test/features/entries/services/dictation_service_test.dart` covering uncommitted partials, duplicate final result dropping, and rolling buffer overlap stripping across pause commits.
   - Added widget tests in `test/features/entries/presentation/entry_editor_dictation_test.dart` verifying live partial text replacement and in-place phrase finalization at the editor cursor.

## Verification

- `flutter test test/features/entries/services/dictation_text_cleaner_test.dart` (24/24 passed)
- `flutter test test/features/entries/services/dictation_service_test.dart` (36/36 passed)
- `flutter test test/features/entries/presentation/editor/dictation_bar_test.dart` (9/9 passed)
- `flutter test test/features/entries/presentation/entry_editor_dictation_test.dart` (6/6 passed)
- `flutter analyze` (clean, 0 issues)
- `dart format lib test` (clean)
