# Plan — Stop the confidence filter deleting real Malayalam words

**Status:** completed

## The problem, seen on a device

A scanned newspaper article came back with single words missing from the middle
of otherwise correct lines:

- Page reads `... ഒരു പെൺകുട്ടി. പതിനാറു വയസ്സായ അവളെ ...`,
  output has `... ഒരു പെൺകുട്ടി. വയസ്സായ അവളെ ...`
- Page reads `... ഒരു അർത്ഥവും കാണാൻ അവൾക്കായില്ല.`,
  output stops at `... ഒരു അർത്ഥവും കാണാൻ`

Poor recognition garbles a word. It does not delete one cleanly and leave its
neighbours intact. This is `WORD_CONFIDENCE_FLOOR`, added in
`change_log/20260912_161127_ocr_confidence_filter_and_best_model.md` and set to
55, discarding correct Malayalam that happened to score below it.

This is the risk that change's log listed as needing a device to settle. It is
now settled: 55 is too high, and a single flat floor is the wrong shape.

## Why a flat floor is wrong

The junk being targeted was `BBE` — Latin letters invented for a printed
ornament. That is a **script** mismatch, not merely a low score. Real Malayalam
scoring 50 on a poorly lit newspaper photo is still real Malayalam, and deleting
it is worse than keeping a slightly wrong word. A reader can fix a wrong letter.
A reader cannot recover a word that is not there.

## The fix

Replace the single floor with two, chosen per word by script.

In `collectConfidentText` in
`android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`:

1. Detect whether a word contains any Malayalam letter. Malayalam occupies the
   Unicode block `U+0D00`–`U+0D7F`, so a simple character range check is enough —
   no new dependency.
2. Apply the floor for that word:

| Word contains | Floor | Reason |
|---|---|---|
| any Malayalam letter | `MALAYALAM_CONFIDENCE_FLOOR` = 30 | Keep almost everything. Losing a real word costs more than keeping a wrong one. |
| no Malayalam letter, in a mostly-Malayalam result | `FOREIGN_CONFIDENCE_FLOOR` = 60 | This is the ornament case, and only this. |
| no Malayalam letter, in a result that is not mostly Malayalam | `MALAYALAM_CONFIDENCE_FLOOR` = 30 | An English scan must behave as it did before this filter existed. |

"Mostly Malayalam" is decided over the whole page, so the rule needs two steps:
collect every word with its confidence and script flag first, then decide the
floors, then build the string. Judge it on the **words kept so far at the low
floor** — if Malayalam words outnumber non-Malayalam ones, the page is Malayalam.

3. Keep the existing safety guard: if filtering empties the result but the
   recognizer did find words, fall back to the unfiltered text.

4. Remove `WORD_CONFIDENCE_FLOOR`, replaced by the two new constants.

## Files to change

| File | Change |
|---|---|
| `android/.../MainActivity.kt` | Two-tier script-aware floor in `collectConfidentText`; swap the one constant for two |

No Dart change. No new package, permission, or asset. Nothing about the model
files changes, so `TESSDATA_VERSION` stays as it is.

## Checks after implementing

- `flutter analyze` clean
- `flutter test`
- `./gradlew :app:compileProdDebugKotlin`
- On a device, rescan the same newspaper article and confirm `പതിനാറു` and
  `അവൾക്കായില്ല` are both present
- On a device, rescan the masthead from the earlier session and check whether
  `BBE` stayed out. If it returns, raise `FOREIGN_CONFIDENCE_FLOOR` rather than
  touching the Malayalam floor — never trade a real word for a junk one

## Not in scope

The photograph itself is the larger limit on this scan: glare across the top, the
page curving, the whole sheet in shadow. No filter or model recovers detail the
camera did not capture. Worth noting in the change log as guidance, but it is not
a code change.
