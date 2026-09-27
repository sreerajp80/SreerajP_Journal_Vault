# Fix voice notes, dictation, deleting, and stale files

**Status:** completed

**Decisions (2026-09-19):** moving old hidden voice notes into attachments — agreed. Deleting
orphan encrypted files at startup (older than one hour, app-private storage only) — agreed.
Plan approved as a whole (all four parts) on 2026-09-19.

This plan takes over from `plans/20260918_223500_fix-dictation-and-voice-note.md`. That plan was
approved but only half built: the dictation *service* parts and the text keys were added, but the
dictation *sheet*, the voice note save and the voice note display were never done. That older plan
will be marked `partial_completion` and point here.

The work is split into four parts, A to D. Each part is built and tested on its own, in this order.

---

## What I found

### Voice notes

1. **Voice notes are invisible.** A recording is saved to the `voice_notes` table. No screen reads
   that table, so the note never shows up, cannot be played, and cannot be deleted.
2. **Save errors are silent.** `VoiceNoteRecorder._stopRecording()` calls the save callback without
   waiting, then closes the sheet. If saving fails, the user sees nothing.
3. **Stale recording files.** The plain (unencrypted) `.m4a` recording in the cache is left behind
   when:
   - the entry id is not ready yet (the callback returns early without deleting it);
   - encryption or the database write fails;
   - the sheet is swiped away or the back button is pressed while recording. The service lives for
     the whole app, so **the microphone keeps recording** and the file is never removed;
   - the app is killed during a recording. Nothing sweeps these files.

### Dictation (speech to text)

4. The sheet still picks a language on its own and starts listening straight away. On a phone with
   no offline Malayalam model this ends in an error screen with only a Close button — a dead end.
   The service side of the fix (`chooseAnotherLanguage()`, `buildDictationLanguageOptions()`) is
   already written but not used by the sheet.
5. Swiping the sheet away throws away the dictated text with no warning.
6. Changing the language while listening reads the sheet's copy of the state, which can lag one
   step behind the service. So the new language sometimes does not start.
7. Inserting text at the cursor works correctly. Dictation writes no files.

### Deleting

8. **Deleting an entry that has any attachment fails.** `attachments.entry_id` is the only foreign
   key to `entries` with no `ON DELETE CASCADE`, and foreign keys are switched on. I confirmed this
   with a throwaway test: `FOREIGN KEY constraint failed`. The error is not caught, so the entry
   just stays.
9. **Deleting a journal can stop half way.** It removes the journal's tags, then deletes entries one
   by one. At the first entry with an attachment it throws, leaving some entries and the tags gone
   but the journal still there.
10. **Deleted content stays on the device.** Even where a delete works, only database rows are
    removed. The encrypted attachment and voice note files are never deleted from storage.
11. **There is no way to delete an attachment.** The attachment tray has only Open and Lock.

### Other stale files (whole-app check)

12. **Decrypted attachment copies are never swept.** `AttachmentTempFileManager.start()` (deletes
    leftovers from the last run) and its app-pause hook are never called. A file opened in another
    app is left decrypted in the cache on purpose, "for the manager to sweep later" — but that sweep
    never runs. Its list of handles also grows forever.
13. If opening in another app fails (for example no app can open it), the decrypted copy is not
    deleted.
14. **The file picker leaves a plain copy of every picked file.** On Android, `file_picker` copies
    each chosen file to `cache/file_picker/<time>/<name>` and never deletes it. This happens for
    attachments, imports, backup restore and "open encrypted export". So every attachment the user
    ever added also sits unencrypted in the cache. The plugin has `FilePicker.clearTemporaryFiles()`;
    the app never calls it.
15. **Backup restore keeps a copy of the backup file** in `cache/restore_staging/`, forever.
16. If writing a backup fails part way, the half-written `.vault` file stays in the backups folder.
17. The scan (OCR) sweep runs only when a new scan starts, and it looks only at top-level files. A
    gallery photo is copied by the picker into `cache/<random-id>/<name>`, which the sweep misses if
    the app was closed during a scan.

**Checked and fine:** PDF export deletes its temp file; shared text and files are read into memory;
the in-app viewers and inline images delete their decrypted copies when closed; backup "replace"
restore deletes the old files; drawing edits delete the old drawing file; export writes only where
the user chooses.

**Found but not fixed here (separate plan if you want):** Wi-Fi Sync looks for attachment columns
named `file_path`, `nonce_base64` and `key_reference`, but the table uses `encrypted_path`. So sync
never sends the attachment file itself. This is a sync bug, not a stale-file bug.

---

## The fix

### Part A — Deleting works, and removes the files too

1. New service `lib/features/entries/services/entry_deletion_service.dart` (layer: services):
   - `deleteEntry(entryId)`: in one database transaction, collect the file paths of the entry's
     attachments and voice notes, delete the attachment rows, then the entry (the rest cascades).
     After the transaction commits, delete the encrypted files. A file that cannot be deleted is
     logged (no name or path) and left for the orphan sweep in Part D.
   - `deleteJournal(journalId)`: the same, for every entry in the journal, plus its tags, all in
     **one** transaction. Either everything goes or nothing does.
   - `deleteAttachment(attachmentId)`: deletes the row (its lock and search text cascade) and then
     its file.
2. The editor, the time capsule screen and the home tab call this service instead of the DAO.
   A failed delete now shows "Could not delete" instead of failing silently.
3. **No schema change.** The service deletes attachment rows first, so the missing cascade no longer
   matters. Schema stays at version 11.
4. **Delete button in the attachment tray**, with a confirm dialog ("Delete this attachment? It is
   removed from this device and cannot be undone."). If the attachment is an image or drawing that
   also sits inside the entry text, that picture is removed from the text too, so no broken picture
   is left behind. Locked attachments ask for the fingerprint/PIN first, the same as opening them.

### Part B — Voice notes

1. **Save as a normal attachment.** The recording is encrypted and saved through the existing
   `AttachmentImportService`, as `audio/mp4`, named like `Voice note 2026-09-19 09-41.m4a`. It then
   shows in the attachment tray, plays in the in-app audio player, and can be deleted with the new
   delete button. It is also covered by the existing lock, backup and export paths.
2. The save logic moves out of the widget into a new service
   `lib/features/entries/services/voice_note_saver.dart` (layer: services). The plain recording is
   **always** deleted in a `finally` block — on success, on any failure, and when the entry is not
   ready.
3. The recorder sheet waits for the save and shows "Saving…". Then it shows "Voice note saved (N s)"
   or "Could not save the voice note", and the tray refreshes.
4. **No hidden recording.** While recording, the sheet cannot be dragged away. The back button asks
   whether to discard. If the sheet closes for any other reason, it cancels the recording and deletes
   the partial file.
5. Recordings go into their own folder, `cache/voice_rec/`, so the startup sweep (Part D) can clear
   any left by a crash.
6. **Old hidden voice notes are moved** into `attachments` once, at startup. The same encrypted file,
   nonce and key are reused, so nothing is decrypted. The `voice_notes` table stays, for backup
   compatibility. If the table is empty on your phone, nothing happens. (Same as the approved older
   plan.)

### Part C — Dictation

1. **Language first.** The sheet prepares the recogniser and then shows a language list: installed
   languages first (marked "Ready"), then ones not downloaded yet (marked "Not downloaded"). If the
   phone gives no list, it offers English (India), English (US), Malayalam and "Device default". The
   last language used is pre-selected. Tapping a language starts listening.
2. **No dead end.** The language error screen gets a "Choose another language" button that goes back
   to the list, keeping any text heard so far.
3. **No lost text.** If there is dictated text, swiping or pressing back asks "Discard the dictated
   text?" before closing.
4. Language changes read the service's own state, so they always take effect.
5. No download button (you did not ask for one last time; the user is told to install the language
   in the phone's speech settings instead).

### Part D — No stale files

1. New service `lib/core/security/stale_file_sweeper.dart` (layer: services, in core because it is
   app-wide). It runs **once at startup**, after the database opens and before the first screen, and
   never throws. It deletes:
   - `cache/attachment_temp/` — decrypted attachment copies from the last run (calls the existing
     `AttachmentTempFileManager.start()`);
   - `cache/file_picker/` — picker copies;
   - `cache/restore_staging/` — staged backup copies;
   - `cache/voice_rec/` — unfinished recordings;
   - scan photos (runs the existing `OcrTempFileSweeper.sweepStale()`), now also including the
     picker's `cache/<random-id>/` folders — only folders whose name is a random id and that hold
     only image files;
   - **orphan encrypted files**: files in `documents/encrypted_attachments/` that no attachment or
     voice note row points to, and that are older than one hour. These are left by past deletes.
     They cannot be opened anyway, because the nonce needed to decrypt them was in the deleted row.
     If the database cannot be read, this step is skipped. Files on the SD card are not swept (the
     SD card bridge has no "list files" call); new SD card deletes are handled by Part A.
2. `main.dart` gets one call to the sweeper (stays thin). The app host forwards pause events to
   `AttachmentTempFileManager.didChangeAppLifecycleState`.
3. `AttachmentTempFileManager`: the 5-minute pause sweep only deletes copies that were handed to
   another app (in-app viewers and inline images delete their own). Released handles are dropped
   from the list.
4. Opening in another app: if it fails, the decrypted copy is deleted at once.
5. **File picker:** right after the bytes are read, call `FilePicker.clearTemporaryFiles()` — in the
   attachment picker, the import screen and the open-encrypted-export screen. For backup restore,
   clear it right after the staging copy is made, and delete the staging copy when the restore
   finishes, fails, another file is picked, or the screen closes.
6. **Backup:** if writing the backup file fails, delete the half-written file.

### Text (all three ARB files, real Malayalam and Sanskrit)

Already present and now used: `titleDictationChooseLanguage`, `descDictationChooseLanguage`,
`labelDictationLanguageReady`, `labelDictationLanguageNotDownloaded`,
`actionDictationChooseLanguage`, `errorVoiceNoteSaveFailed`, `labelVoiceNoteSaving`,
`labelVoiceNoteFileName`.

New keys (names may change slightly): `tooltipEntryDeleteAttachment`, `bodyEntryDeleteAttachment`,
`bodyEntryDeleteAttachmentBody`, `errorEntryDeleteAttachment`, `errorEntryDelete`,
`errorJournalDelete`, `bodyDictationDiscardConfirm`, `bodyVoiceNoteDiscardConfirm`.
New Malayalam and Sanskrit terms are flagged for native-reader review in the change log.

---

## Files to change

**Part A**
- new `lib/features/entries/services/entry_deletion_service.dart`
- `lib/features/entries/providers/entry_providers.dart` — provider for it
- `lib/features/entries/presentation/entry_editor_actions.dart` — entry delete
- `lib/features/entries/presentation/time_capsule_sealed_screen.dart` — entry delete
- `lib/app/app_home_tab.dart` — journal delete
- `lib/features/entries/presentation/entry_editor_widgets.dart` — tray delete button
- `lib/features/entries/presentation/entry_editor_screen.dart` / `entry_editor_actions_3.dart` —
  remove the matching picture from the text after a tray delete

**Part B**
- new `lib/features/entries/services/voice_note_saver.dart`
- new `lib/features/entries/services/legacy_voice_note_mover.dart` (one-time move)
- `lib/features/entries/services/voice_note_service.dart` — `voice_rec/` folder
- `lib/features/entries/presentation/editor/voice_note_recorder.dart` — saving state, no hidden
  recording
- `lib/features/entries/presentation/entry_editor_actions_2.dart` — use the saver, refresh the tray

**Part C**
- `lib/features/entries/presentation/editor/dictation_sheet.dart`
- `lib/features/entries/presentation/entry_editor_actions_3.dart` — sheet options, if needed

**Part D**
- new `lib/core/security/stale_file_sweeper.dart`
- `lib/main.dart` — one startup call
- `lib/app/app.dart` — forward app pause events
- `lib/features/attachments/services/attachment_temp_file_manager.dart`
- `lib/features/attachments/services/attachment_open_service.dart` and
  `lib/features/entries/presentation/entry_editor_widgets.dart` — close on external-open failure
- `lib/features/attachments/services/file_picker_attachment_picker_service.dart`
- `lib/features/import/presentation/import_screen.dart`
- `lib/features/export/presentation/open_encrypted_export_screen.dart`
- `lib/features/backup/services/backup_file_picker.dart`,
  `lib/features/backup/presentation/restore_backup_screen.dart`
- `lib/features/backup/services/backup_service.dart`
- `lib/features/entries/services/ocr_temp_file_sweeper.dart` — picker folders

**Text and docs**
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` (+ `flutter gen-l10n`)
- `docs/architecture.md` (known gaps / cleanup notes), `docs/security.md` (temp file rules),
  `docs/implementation_progress.md`
- `plans/20260918_223500_fix-dictation-and-voice-note.md` — status to `partial_completion`
- change log in `change_log/`

---

## Tests

- `entry_deletion_service_test.dart`: an entry with attachments and voice notes deletes, and its
  files are gone; a journal delete is all-or-nothing; an attachment delete removes the row, lock and
  file. Includes the exact case that fails today.
- `voice_note_saver_test.dart`: saves an `audio/mp4` attachment; the plain file is deleted on
  success, on encryption failure, on database failure, and when there is no entry.
- `legacy_voice_note_mover_test.dart`: rows move once, same file, and a second run does nothing.
- `stale_file_sweeper_test.dart`: each folder is cleared; an orphan older than one hour is deleted;
  a referenced file, a new file, and anything outside the listed folders are kept; nothing happens
  when the database read fails.
- `attachment_temp_file_manager_test.dart`: pause sweep deletes only handed-off copies; handle list
  does not grow.
- `ocr_temp_file_sweeper` test: picker folders removed, other folders kept.
- Widget tests: tray delete (confirm, cancel, picture removed from text); recorder (saving, saved,
  failed, closing while recording cancels it); dictation sheet (language list first, error offers
  "Choose another language", discard confirm).
- Run `flutter analyze`, `flutter test`, `sh tool/check_sanskrit_markers.sh`, `dart format`.
- On the phone (dev flavor): record, play and delete a voice note; dictate in English on a Malayalam
  phone; delete an entry with a photo; check the cache folder is empty of leftovers after a restart.

## Acceptance criteria

- A saved voice note appears in the entry, plays, and can be deleted.
- The user always sees "saved" or "could not save" after recording.
- Dictation lets the user pick a language, never traps them on an error, and puts the text at the
  cursor.
- An entry or journal with attachments can be deleted, and its files leave the device.
- After a restart, the app's cache holds no picked files, decrypted copies, recordings, staged
  backups or scan photos from earlier sessions.
