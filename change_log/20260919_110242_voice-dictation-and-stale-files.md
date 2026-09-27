# Voice notes, dictation, deleting, and stale files

Implements `plans/20260919_094126_voice-dictation-and-stale-files.md` (all four parts, approved
2026-09-19). Also finishes `plans/20260918_223500_fix-dictation-and-voice-note.md`, now marked
`partial_completion`.

## What changed

### Part A — Deleting

- New `lib/features/entries/services/entry_deletion_service.dart` (services).
  `deleteEntry`, `deleteJournal` and `deleteAttachment` delete the rows in one transaction —
  attachment rows first, because `attachments.entry_id` is the one foreign key with no cascade —
  and then the encrypted files. A file that cannot be deleted is logged by count only.
- The entry editor, the sealed time capsule screen and the home tab's journal delete use it. A
  failed delete now shows a message instead of failing silently.
- The attachment tray has a delete button with a confirm dialog. A locked attachment asks for the
  fingerprint or PIN first. If the attachment is a picture or drawing inside the text, it is
  taken out of the text and the caret is moved to a valid place (new helper
  `lib/features/entries/presentation/editor/attachment_embed_finder.dart`).
- No schema change. Schema stays at version 11.

### Part B — Voice notes

- New `lib/features/entries/services/voice_note_saver.dart` (services). Saves a recording as a
  normal attachment (`audio/mp4`, named `Voice note yyyy-MM-dd HH-mm.m4a`) through
  `AttachmentImportService`. The plain recording is always deleted in a `finally` block.
- `voice_note_recorder.dart` rewritten: `showVoiceNoteRecorder` returns saved / failed / null.
  The sheet shows "Saving…", cannot be dragged away, asks before discarding on Back, and stops
  the microphone and deletes the partial file if it closes any other way. The editor shows
  "Voice note saved (N s)" or "Could not save the voice note" and refreshes the tray.
- `VoiceNoteService` records into `cache/voice_rec/` and deletes a partial file on every failure
  path.
- New `lib/features/entries/services/legacy_voice_note_mover.dart`: moves old `voice_notes` rows
  into `attachments` once on start, reusing the same encrypted file, nonce and key. The table
  stays for backup compatibility.

### Part C — Dictation

- `dictation_sheet.dart` rewritten: the language list comes first (installed, then not
  downloaded, or a fallback list), and listening starts only when one is picked. The language
  chip reopens the list and keeps the text. A language error offers "Change language". Text
  heard before any other error is kept and can still be finished and inserted. Back or a tap
  outside asks before throwing dictated text away; drag-to-close is off.
- This also fixed a compile error left by the earlier half-built plan: the sheet still called
  `pickDictationLanguage`, which had been removed from the service.

### Part D — Stale files

- New `lib/core/security/stale_file_sweeper.dart`: clears `cache/file_picker/`,
  `cache/restore_staging/` and `cache/voice_rec/`, and deletes orphaned encrypted files (no row
  points at them, older than one hour, app-private storage only; compared by file name; skipped
  if the database cannot be read).
- New `lib/app/startup_maintenance.dart`: `runStartupMaintenance` runs the voice note move,
  `AttachmentTempFileManager.start()`, the scan-photo sweep and the stale-file sweep, each
  guarded, and turns on the temp manager's lifecycle hook. `main.dart` calls it once before
  `runApp`.
- `AttachmentTempFileManager`: `listenToAppLifecycle()`; the 5-minute background sweep now
  deletes only copies handed to another app; released handles leave the list.
- `AttachmentOpenService.openExternally`: marks the copy as handed off, and deletes it at once
  when no app could open it (`keepOnFailure` for the viewer's own button).
- New `lib/core/security/file_picker_cache.dart`: `clearFilePickerCache()` is called after every
  pick — attachments, import, open sealed export, backup restore.
- Backup restore: one staged copy at a time; deleted when the restore screen closes.
- Backup create: a half-written `.vault` file is deleted if writing fails.
- `OcrTempFileSweeper.sweepStale` also removes the gallery picker's `cache/<uuid>/` folders
  (UUID name, files only, old enough) and now also runs at start.

### Text

New keys in `app_en.arb`, `app_ml.arb`, `app_sa.arb`: `tooltipEntryDeleteAttachment`,
`bodyEntryDeleteAttachment`, `bodyEntryDeleteAttachmentBody`, `errorEntryDeleteAttachment`,
`errorEntryDelete`, `errorJournalDelete`, `bodyVoiceNoteDiscardConfirm`,
`bodyDictationDiscardConfirm`. The dictation and voice note keys added by the earlier plan are
now used.

**Needs native-reader review** (new Malayalam and Sanskrit wording):

| Key | ml | sa |
|---|---|---|
| `tooltipEntryDeleteAttachment` | അറ്റാച്ച്മെന്റ് ഇല്ലാതാക്കുക | संलग्नं लोपय |
| `bodyEntryDeleteAttachment` | അറ്റാച്ച്മെന്റ് ഇല്ലാതാക്കണോ? | संलग्नं लोपयितव्यम् किम्? |
| `bodyEntryDeleteAttachmentBody` | "{fileName}" ഈ കുറിപ്പിൽ നിന്നും ഈ ഉപകരണത്തിൽ നിന്നും നീക്കം ചെയ്യും. ഇത് തിരിച്ചെടുക്കാനാവില്ല. | "{fileName}" अस्याः प्रविष्टेः अस्मात् यन्त्रात् च अपनीयते। एतत् पुनः न लभ्यते। |
| `errorEntryDeleteAttachment` | അറ്റാച്ച്മെന്റ് ഇല്ലാതാക്കാൻ കഴിഞ്ഞില്ല. | संलग्नं लोपयितुं न शक्तम्। |
| `errorEntryDelete` | കുറിപ്പ് ഇല്ലാതാക്കാൻ കഴിഞ്ഞില്ല. | प्रविष्टिं लोपयितुं न शक्तम्। |
| `errorJournalDelete` | ജേണൽ ഇല്ലാതാക്കാൻ കഴിഞ്ഞില്ല. ഒന്നും നീക്കം ചെയ്തിട്ടില്ല. | दैनन्दिनीं लोपयितुं न शक्तम्। किमपि न अपनीतम्। |
| `bodyVoiceNoteDiscardConfirm` | ഈ റെക്കോർഡിങ് നിർത്തി ഉപേക്ഷിക്കണോ? | इदं ध्वनिमुद्रणं स्थगयित्वा त्यक्तव्यम् किम्? |
| `bodyDictationDiscardConfirm` | പറഞ്ഞെഴുതിയ വാചകം ഉപേക്ഷിക്കണോ? | वाग्लिखितः पाठः त्यक्तव्यः किम्? |

### Docs

`docs/architecture.md` (section 14 notes, section 21 "Closed on 2026-09-19"), `docs/security.md`
(data table, "Temporary files" — it wrongly said the temp sweep already ran),
`docs/implementation_progress.md`.

## Different from the plan

- The startup work lives in a new `lib/app/startup_maintenance.dart` instead of being wired into
  `lib/app/app.dart`. The pause hook uses `AppLifecycleListener` inside the temp manager
  (`listenToAppLifecycle`), so `app.dart` only gained two imports for the delete changes.
- Two small helpers were added that the plan did not name: `attachment_embed_finder.dart` and
  `file_picker_cache.dart`.
- Drag-to-close is off for the dictation sheet too, not only the recorder: a drag closes a sheet
  without asking, so it would bypass the "discard text?" question.
- `openExternally` got a `keepOnFailure` flag so the viewer's own "open in another app" button
  does not delete the file the viewer is still showing.
- The plan said Wi-Fi Sync looks for the wrong nonce and key columns too. Only the path column
  (`file_path` instead of `encrypted_path`) is wrong. Still not fixed here.

## Not done

- **Phone check.** Recording, playing and deleting a voice note, dictating on a Malayalam phone,
  and checking the cache after a restart were not tried on a device in this session. Only the
  automated tests below were run.
- Wi-Fi Sync attachment bug (above) — separate plan if wanted.
- Native-reader review of the new ml/sa strings.

## Verification

- `flutter analyze`: no issues.
- `flutter test`: 1018 passed, 1 failed. The failure is
  `test/features/sync/sync_engine_wifi_test.dart` hitting its 30-second limit under full-suite
  load; it passed 3 out of 3 runs on its own. No code it uses was changed.
- New tests: `entry_deletion_service_test.dart` (7, including the delete that used to fail),
  `attachment_embed_finder_test.dart` (3), `voice_note_saver_test.dart` (8, saver and mover),
  `voice_note_recorder_test.dart` (5), `dictation_sheet_test.dart` (13, rewritten),
  `dictation_service_test.dart` (language list and "choose another language"),
  `attachment_tray_test.dart` (tray delete), `attachment_open_service_test.dart` (3),
  `attachment_temp_file_manager_test.dart` (pause sweep, handle list),
  `ocr_temp_file_sweeper_test.dart` (picker folders), `stale_file_sweeper_test.dart` (7),
  `startup_maintenance_test.dart` (2).
- `sh tool/check_sanskrit_markers.sh`: passed. Translation parity and label length tests pass.
- `dart format` run on `lib` and `test`.
