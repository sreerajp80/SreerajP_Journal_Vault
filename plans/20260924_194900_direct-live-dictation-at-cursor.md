# Voice Dictation: Direct Live Typing at Cursor (Option A) and Repetition Fix

**Status:** completed

## User Request

The user requested:
> "Direct live typing at the cursor (Option A — words appear directly in the entry as you speak)."
> "Why cannot we place the dictated text directly to the journal entry. Why two step."

The user also reported that speech-to-text was repeating lines and accumulating overlapping rolling phrases:
```text
Let l. Let, Chrome cloud to rainfall. 
Chrome cloud to rainfall, highlight God, and ask for edits. 
Cloud to rainfall highlight God and ask for edits, give cloud rules to Remember. 
Cloud to rainfall highlight God and ask for edits. Give cloud rules to Remember, let edit without stopping. 
Give cloud rules to Remember let edit without stopping use plan more for Complex changes. 
Give cloud rules to Remember let edit without stopping use plan more for Complex changes.
```

## Solution Overview

Combine two enhancements into a single, cohesive workflow:
1. **Direct Live Typing at the Cursor:**
   As words are recognized in real time, they appear immediately in the journal body at the caret position. The live range updates smoothly in-place as the phrase develops. When the user pauses or the phrase finishes, the phrase is finalized with clean capitalization, punctuation, and spacing as a permanent edit.
2. **Overlap Removal & Deduplication:**
   Use session-aware uncommitted text extraction to ensure Android's rolling recognizer window never repeats already-committed words, and identical duplicate final results are dropped.

---

## Detailed Design

### 1. `dictation_text_cleaner.dart`
Add `extractUncommittedText(String committedText, String newText)`:
- **Prefix match:** If `newText` continues `committedText`, strip the committed prefix so only new words remain.
- **Suffix-prefix overlap match:** If Android's rolling buffer sends words that overlap with the tail of `committedText` (e.g. `"Chrome cloud to rainfall"`), strip the overlapping words.
- **Full duplicate containment:** If all words of `newText` are already committed, return empty string `""` to prevent duplicate insertions.

### 2. `dictation_service.dart`
- Track `_sessionCommittedText` for the active listening session.
- When partial results arrive, calculate `uncommitted = extractUncommittedText(_sessionCommittedText, words)`.
- Emit `uncommitted` as `DictationState.partialText` so the editor receives only newly spoken words.
- In `_commit(words)`:
  - Extract only uncommitted words.
  - If empty (e.g. duplicate final result), do not emit anything to `_phrases`.
  - Otherwise, clean the phrase, emit it, and update `_sessionCommittedText` and `_state.committedText`.
- Reset `_sessionCommittedText` on new session (`_listen()`) and `discard()`.

### 3. `dictation_bar.dart`
- Add optional callback `ValueChanged<String>? onLivePartial`.
- When listening to `_service.states`, notify `widget.onLivePartial?.call(next.partialText)` on every update.
- Keep the control bar slim and focused (Mic status, language selector chip, pause/resume, stop).

### 4. `entry_editor_actions_3.dart` & `entry_editor_layout.dart`
- Track the active dictation caret range:
  - `int? _dictationCaretOffset`: where the current phrase started in the document.
  - `int _dictationLiveLength`: length of live partial text currently in the document.
- Implement `_onDictationLivePartial(String text)`:
  - If starting a new range, anchor `_dictationCaretOffset` to the current cursor position.
  - Replace the live range `_quillController.replaceText(_dictationCaretOffset!, _dictationLiveLength, spacedText, selection, ignoreFocus: true)`.
  - Update `_dictationLiveLength = spacedText.length`.
- Implement `_onDictationPhrase(String text)`:
  - When a phrase is finalized (clean punctuation, sentence capitalization):
  - Replace the live range with the finalized text.
  - Advance `_dictationCaretOffset += finalizedText.length`.
  - Reset `_dictationLiveLength = 0`.
  - Mark document dirty.
- When stopped / closed:
  - If a live range remains, finalize or clear it.
  - Reset `_dictationCaretOffset = null`, `_dictationLiveLength = 0`.
- Wire `onLivePartial: _onDictationLivePartial` in `_buildDictationBar()` in `entry_editor_layout.dart`.

---

## Files to Change

- `lib/features/entries/services/dictation_text_cleaner.dart`
- `lib/features/entries/services/dictation_service.dart`
- `lib/features/entries/presentation/editor/dictation_bar.dart`
- `lib/features/entries/presentation/entry_editor_actions_3.dart`
- `lib/features/entries/presentation/entry_editor_layout.dart`
- `test/features/entries/services/dictation_text_cleaner_test.dart`
- `test/features/entries/services/dictation_service_test.dart`
- `test/features/entries/presentation/entry_editor_dictation_test.dart`

---

## Verification Plan

1. **Unit tests:**
   - Run `flutter test test/features/entries/services/dictation_text_cleaner_test.dart`
   - Run `flutter test test/features/entries/services/dictation_service_test.dart`
   - Run `flutter test test/features/entries/presentation/editor/dictation_bar_test.dart`
   - Run `flutter test test/features/entries/presentation/entry_editor_dictation_test.dart`
2. **Static analysis & formatting:**
   - Run `flutter analyze`
   - Run `dart format lib test`
3. **Behavioral checks:**
   - Live partial text appears directly in the document at the cursor while speaking.
   - When pausing, the phrase finalizes in-place with capitalization and punctuation.
   - No repeated lines or duplicate words across phrases.
   - Single Undo takes out the finalized phrase cleanly.
