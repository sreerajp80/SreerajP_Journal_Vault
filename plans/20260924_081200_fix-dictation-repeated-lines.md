# Voice Dictation: Fix Repeated Lines and Overlapping Speech Phrases

**Status:** dropped
**Note:** In-app dictation was removed on 2026-09-24 (`plans/20260924_220251_remove-dictation-keyboard-privacy-setting.md`), so this fix is no longer needed.

## What the user reported

The Speech-to-text dictation feature is repeating lines and accumulating overlapping phrases in the editor.

### Actual output received
```text
Let l. Let, Chrome cloud to rainfall. Chrome cloud to rainfall, highlight God, and ask for edits. Cloud to rainfall highlight God and ask for edits, give cloud rules to Remember. Cloud to rainfall highlight God and ask for edits. Give cloud rules to Remember, let edit without stopping. Give cloud rules to Remember let edit without stopping use plan more for Complex changes. Give cloud rules to Remember let edit without stopping use plan more for Complex changes.
```

### What was actually spoken
```text
Learn Claude Code
Prompt Claude to write code
Highlight code and ask for edits
Give Claude rules to remember
Let Claude edit without stopping
Use Plan mode for complex changes
```

## Root cause analysis

1. **Cumulative & rolling session buffer on Android:**
   Within a single listening session, Android's on-device `SpeechRecognizer` returns a cumulative transcript or rolling window of the active session in `onPartialResults`.

2. **Pause timer commits partial text without session awareness:**
   In `DictationService._handleResult`, an inactivity pause timer (`pauseCommitDelay`, 1300ms) commits `_state.partialText` to `_phrases` and clears `partialText` to `''`. However, Android's recognizer remains active in the same session. When the user continues speaking, Android emits partial results containing both earlier words and new words (e.g. `[already committed words] + [new words]`). Because `partialText` was cleared, Dart accepts the whole string as new text and commits it again on the next pause, repeating the earlier words.

3. **Duplicate commit on final result (`isFinal` / `onResults`):**
   When the user pauses and `_pauseCommitTimer` commits the phrase, Android subsequently triggers `onResults` with `isFinal: true` for the same phrase. `_handleResult` calls `_commit(words)` unconditionally, emitting the exact same phrase a second time (seen in lines 5 and 6 of the user's transcript).

4. **Sliding window overlap (`_isNewUtterance` misfiring):**
   When Android drops the earliest words from its rolling buffer, `_isNewUtterance` saw different starting words, committed the previous text, and then accepted the new window which still overlapped with the tail of the previous text.

## Proposed fix

### 1. Uncommitted text extractor (`dictation_text_cleaner.dart`)
Add `extractUncommittedText(String committedText, String newText)`:
- **Exact prefix matching:** If `newText` starts with `committedText`, strip the committed prefix so only the new trailing words remain.
- **Full containment check:** If all words of `newText` are already present in `committedText`, return an empty string (drops duplicate final results).
- **Suffix-prefix overlap detection:** If `newText` begins with words that match the tail of `committedText` (e.g. rolling buffer repetition like `"Chrome cloud to rainfall"`), strip the overlapping words and leading punctuation.
- Preserves genuine separate sentences that happen to share a common stopword.

### 2. Session-aware commit and deduplication (`dictation_service.dart`)
- Track `_sessionCommittedText` for the active listening session.
- When partial results arrive, calculate `uncommitted = extractUncommittedText(_sessionCommittedText, words)`.
- Live preview in `DictationBar` displays only the uncommitted words currently being spoken.
- In `_commit(words)`:
  - Extract only the uncommitted portion.
  - If the uncommitted text is empty (already committed by the pause timer or duplicate final result), drop it cleanly without emitting to `_phrases`.
  - Update `_sessionCommittedText` and `_state.committedText`.
- Reset `_sessionCommittedText` when starting a new session in `_listen()` or discarding.

### 3. Automated testing
- Unit tests in `test/features/entries/services/dictation_text_cleaner_test.dart`:
  - Cumulative prefix extensions.
  - Exact duplicates and full containment.
  - Suffix-prefix rolling buffer overlaps.
  - User's exact 6-phrase transcript scenario.
- Unit tests in `test/features/entries/services/dictation_service_test.dart`:
  - Pause auto-commit followed by partial updates in the same session.
  - Duplicate final result after pause auto-commit.
  - Rolling window overlap between phrases.

## Files to change

- `lib/features/entries/services/dictation_text_cleaner.dart`
- `lib/features/entries/services/dictation_service.dart`
- `test/features/entries/services/dictation_text_cleaner_test.dart`
- `test/features/entries/services/dictation_service_test.dart`

## Verification plan

1. Run unit tests:
   ```bash
   flutter test test/features/entries/services/dictation_text_cleaner_test.dart
   flutter test test/features/entries/services/dictation_service_test.dart
   flutter test test/features/entries/presentation/entry_editor_dictation_test.dart
   ```
2. Verify code quality:
   ```bash
   flutter analyze
   dart format lib test
   ```
3. Verify that the user's transcript scenario produces exactly the 5 distinct sentences with zero repetitions.
