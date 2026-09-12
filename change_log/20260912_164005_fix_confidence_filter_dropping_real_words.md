# Change log — Stop the confidence filter deleting real Malayalam words

**Plan:** `plans/20260912_162732_fix_confidence_filter_dropping_real_words.md`
**Date:** 2026-09-12

Corrects part of `change_log/20260912_161127_ocr_confidence_filter_and_best_model.md`,
which introduced the filter this change reshapes.

## What was wrong

Scanning a newspaper article on a device showed single words missing from the
middle of otherwise correct lines:

- Page reads `... ഒരു പെൺകുട്ടി. പതിനാറു വയസ്സായ അവളെ ...`, output skipped
  `പതിനാറു`
- Page reads `... ഒരു അർത്ഥവും കാണാൻ അവൾക്കായില്ല.`, output stopped at `കാണാൻ`

Which words vanished changed with the image filter used, while the recognised
word count stayed the same. Poor recognition garbles a word; it does not delete
one cleanly and leave its neighbours intact. This was `WORD_CONFIDENCE_FLOOR`,
set to 55, discarding correct Malayalam that scored below it.

A single flat floor was the wrong shape for the problem. The junk originally
being targeted was Latin letters invented for a printed ornament — a **script**
mismatch, not merely a low score.

## What changed

### `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`

`collectConfidentText` rewritten to apply two floors, chosen per word by script:

| Word contains | Floor | Reason |
|---|---|---|
| any Malayalam letter | 30 | Keep almost everything. A reader can mend a wrong letter but cannot recover a missing word. |
| no Malayalam, on a mostly-Malayalam page | 60 | The ornament case, and only this. |
| no Malayalam, on any other page | 30 | An English scan behaves as it did before the filter existed. |

Because "is this page mostly Malayalam" cannot be known until the whole page has
been read, the method now works in two steps: walk the iterator collecting every
word with its confidence, script flag and end-of-line flag into `RecognisedWord`
records, then decide the page script, then build the string. Only words already
clearing the low floor get a vote on the page script, so junk cannot sway it.

- New `RecognisedWord` private data class.
- New `hasMalayalamLetter`, a plain character-range check against the Unicode
  Malayalam block. No new dependency.
- New constants `MALAYALAM_BLOCK_START`, `MALAYALAM_BLOCK_END`,
  `MALAYALAM_CONFIDENCE_FLOOR` (30) and `FOREIGN_CONFIDENCE_FLOOR` (60).
  `WORD_CONFIDENCE_FLOOR` removed.
- Line breaks are preserved even when the word that ended a line was dropped.
- The existing safety guard is unchanged: if filtering empties the result but the
  recognizer did find words, the unfiltered text is kept.

No Dart change. No new package, permission or asset. Model files untouched, so
`TESSDATA_VERSION` is unchanged.

## Checks run

- `flutter analyze` — no issues found
- `flutter test` — 826 tests, all passed
- `./gradlew :app:compileProdDebugKotlin` — BUILD SUCCESSFUL
- `tool/check_absolute_paths.sh --all` — clean

## Still to confirm on a device

Rescan the same newspaper article with the **Document** filter and **Invert off**,
and check that `പതിനാറു`, `അവൾക്കായില്ല` and `പഠിച്ചുകൊണ്ടിരുന്ന` all appear.

If ornament junk such as `BBE` returns, raise `FOREIGN_CONFIDENCE_FLOOR`. Never
raise `MALAYALAM_CONFIDENCE_FLOOR` to chase it — that trades a real word for a
junk one, which is the mistake this change undoes.

## Notes from the same device session, no code change needed

- The **Invert** toggle was switched on for a normal dark-ink-on-white page,
  which flips a correct image into a wrong one. It is only for genuinely
  light-on-dark material such as a masthead band. Results held up anyway because
  the native auto-invert detected the dark image and tried a re-inverted copy,
  but passes were being spent undoing the toggle.
- The **Document** filter with its new level normalisation visibly cleaned up a
  photographed newsprint page that the plain grayscale filter left grey and
  muddy. It is the right choice for printed pages.
- A large decorative drop capital at the start of an article breaks line
  segmentation, so the word carrying it may still be missed. That is a
  segmentation limit, not a confidence one, and is not addressed here.
