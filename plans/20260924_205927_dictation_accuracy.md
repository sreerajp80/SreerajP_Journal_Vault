# Plan: Make dictation put the recogniser's best words into the entry

**Status:** completed
**Change log:** `change_log/20260924_212800_dictation_accuracy.md`

## The issue

A user read this aloud:

> Learn Claude Code. Prompt Claude to write code. Highlight code and ask for edits.
> Give Claude rules to remember. Let Claude edit without stopping. Use Plan mode for
> complex changes.

The entry got:

> Land cloud from cloud to, right? God highlight cord and ask for edits, give cloud
> rules to remember let cloud edit without stopping use planms for Complex changes

Some of this is the phone's offline speech model and cannot be fixed in the app
("Claude" is not a word it knows, so it hears "cloud"). But a large part is caused by
the app itself. The app writes the recogniser's **rough first guess** into the entry,
and throws away the **better final answer** that comes a moment later.

### Why this happens (in `lib/features/entries/services/dictation_service.dart`)

The recogniser sends two kinds of results:

- **Partial results** — fast, rough guesses while you speak. It keeps correcting them
  ("land cloud" → "learn Claude code").
- **A final result** — its best answer, sent once the phrase ends.

The new, not-yet-committed code commits (writes into the entry) the partial guess early
in three ways:

1. **1.3-second timer** (`pauseCommitDelay`). A short breath between words commits the
   rough guess.
2. **0.6-second timer after `end_of_speech`**. The final result usually arrives after
   this, so the rough guess wins.
3. **`_isNewUtterance`**. When the recogniser corrects its first word (it often does),
   the old guess is treated as a finished phrase and committed.

Once committed, the phrase goes straight into the entry through `phrases`. When the
better final result arrives, `extractUncommittedText` compares it with the rough text
already committed. The words differ, so the good version is dropped or partly
duplicated. This matches the output: "Land cloud from cloud to, right?" — two rough
guesses stuck together, with "write code" cut to "right?".

A fourth cause is in `OnDeviceDictation.kt`: partial results add the recogniser's
`UNSTABLE_TEXT` (its lowest-confidence tail words) to the text. With the early timers,
those shaky words get committed too.

## The fix

Commit only what the recogniser has **confirmed**, and let the final result win.

1. `dictation_service.dart`
   - Remove the 1.3-second `pauseCommitDelay` timer and the 0.6-second
     `end_of_speech` timer. A phrase is committed when the final result arrives, or
     when the session ends (`done`), pause, finish or error — as before this change.
   - Remove `_isNewUtterance`. Partial results replace each other; they are never
     committed just because the first word changed.
     *Change during implementation:* a much narrower check, `_startsOver`, replaces
     it. It commits the earlier guess only when the new guess is less than half as
     long and starts with another word — a recogniser starting over without a final
     result. A correction keeps its length or grows, so it never triggers this.
     Without the check, such a phone would lose a whole sentence.
   - When the final result is empty (some phones do this), keep the current
     behaviour: the last partial is used.
   - Keep `_sessionCommittedText` and `extractUncommittedText` for recognisers that
     repeat earlier text in later results.
2. `OnDeviceDictation.kt`
   - Stop adding `UNSTABLE_TEXT` to partial results. The live preview may lag by a
     word, but only confirmed words are shown and committed.
3. No live text in the entry (user's choice). Stop passing `onLivePartial` from
   `entry_editor_layout.dart`, and remove `_onDictationLivePartial` and the
   live-length bookkeeping (`_dictationLiveLength`) from
   `entry_editor_actions_3.dart`. Words reach the entry only through `phrases`, after
   the recogniser's final answer. `onLivePartial` is removed from `DictationBar`.
4. `dictation_bar.dart` — the user does not want the words shown in the dictation bar
   (they already appear in the entry, so the bar showed them twice). Remove the
   italic preview line (`dictation-preview`). While listening or paused the bar shows
   only the status row: listening/paused label, language chip, pause and stop. The
   progress bar (while preparing) and error text stay. `_previewLength` is removed.

### Why wrong text already appears in the entry

Two paths write into the entry while the user speaks:

- `onLivePartial` → `_onDictationLivePartial` in `entry_editor_actions_3.dart` types
  the recogniser's current rough guess into the entry, at the cursor, and replaces it
  on every update. This part is meant to be temporary.
- `phrases` → `_insertDictatedPhrase` makes a phrase permanent.

The early timers (point 1) make the rough guess permanent before the recogniser has
corrected it. After this fix, nothing goes into the entry until the recogniser's
final answer arrives. The app cannot
know if the final answer is wrong — that is the phone's offline model — but it will
no longer lock in the rough first guess.

Not changed: the offline-only rule, the cleaner, the language sheet.

## Files to change

- `lib/features/entries/services/dictation_service.dart`
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/OnDeviceDictation.kt`
- `test/features/entries/services/dictation_service_test.dart` — update tests that
  expect timer commits; add tests:
  - a corrected partial ("land cloud" → "learn Claude code") commits only the final
    text, once;
  - a final result replaces the last partial;
  - an empty final result still commits the last partial.
- `android/app/src/test/kotlin/.../OnDeviceDictationTest.kt` — only if it covers the
  unstable-text join.
- `lib/features/entries/presentation/editor/dictation_bar.dart` — remove the preview
  line and `onLivePartial`.
- `lib/features/entries/presentation/entry_editor_layout.dart` and
  `lib/features/entries/presentation/entry_editor_actions_3.dart` — remove live text.
- `test/features/entries/presentation/entry_editor_dictation_test.dart` — check that a
  partial result puts nothing in the entry and a final result does.
- `test/features/entries/presentation/editor/dictation_bar_test.dart` — replace preview
  tests with one that checks no spoken words show in the bar.

## Trade-off

Text appears in the entry a little later — when the recogniser finishes a phrase (after
a pause of a few seconds) rather than 1.3 seconds after the last word. Until then
nothing is shown — the "Listening…" label and the moving sound icon are the only sign
that speech is being heard. The user chose this over a temporary live guess.

## Acceptance criteria

- The test above passes: a corrected partial never reaches the entry.
- `flutter analyze` is clean and `flutter test` passes.
- On a phone, reading the sample text in `en-IN` (the language already in use) gives the recogniser's final words,
  with no repeated or cut-off phrases. ("Claude" may still come out as "cloud" — that
  is the offline model's vocabulary.)
