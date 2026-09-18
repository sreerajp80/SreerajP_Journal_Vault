# On-device dictation (speech to text) in the entry editor

**Status:** completed

## 1. What the user wants

Speak, and have the words written into a journal entry.

## 2. What exists today, and what is wrong with it

- `speech_to_text` 7.4.0 is already a dependency, and `record` supplies the `RECORD_AUDIO`
  permission through manifest merging.
- The only use is inside the voice-note recorder
  (`lib/features/entries/presentation/editor/voice_note_recorder.dart` and
  `lib/features/entries/services/voice_note_service.dart`). It has four problems:
  1. **It can send audio to the cloud.** It calls `listen()` with no on-device option. Also, the
     plugin's Android code (`createRecognizer`) quietly falls back to the normal system
     recogniser when on-device recognition is not available. On most phones that normal
     recogniser is Google's online service. This breaks hard rule 1 ("No cloud").
  2. **It fights with the recorder for the microphone.** `record` and the speech recogniser both
     open the microphone at the same time. On most Android phones only one of them gets audio,
     so the transcript is usually empty.
  3. **`transcribeLive()` returns before any speech arrives**, so the "final" text is always
     empty. Only the last partial result is kept.
  4. **The text never reaches the entry.** It is saved only in the `VoiceNotes.transcript`
     column. The user cannot write an entry by speaking.

## 3. Plan

### 3.1 On-device guard (native, Android)

Add one method to a new `MethodChannel` (`sreerajp_journal_vault/speech`) in `MainActivity.kt`:

- `onDeviceSpeechStatus` → returns `{ available: bool, languages: [String] }`.
  - `available` = API 31+ **and** `SpeechRecognizer.isOnDeviceRecognitionAvailable(context)`.
  - `languages` = on API 33+, the on-device languages from `checkRecognitionSupport`
    (`installedOnDeviceLanguages`, plus `supportedOnDeviceLanguages` shown as "needs download").
    On API 31–32 the list is empty and we fall back to the device locale.

Add a `<queries>` entry for `android.speech.RecognitionService` to the manifest, which Android 11+
needs so the app can see the recogniser. Also declare `RECORD_AUDIO` in our own manifest so the
permission is visible in the file we review, instead of only arriving through merging.

**Rule:** dictation starts only when `available` is true, and always with
`SpeechListenOptions(onDevice: true)`. The plugin checks the very same Android call before it
picks a recogniser, so the fallback to the online recogniser can no longer happen. If on-device
recognition is not available, the feature shows a clear message ("Offline speech recognition is
not available on this device") and does nothing else. It never goes online.

### 3.2 Service layer — `DictationService`

New file `lib/features/entries/services/dictation_service.dart` (layer: **services**; no
`BuildContext`, no UI strings). It:

- asks the native guard for status, and refuses to start when on-device is not available;
- checks microphone permission;
- runs continuous dictation: Android ends a listening session after a short pause, so the service
  starts a new session automatically until the user presses Stop;
- keeps the final text of each finished session, and exposes a stream of
  `DictationState { status, committedText, partialText, errorCode }`;
- never logs recognised text (hard rule 3). It logs only status and error codes.

A thin `SpeechEngine` interface wraps the plugin and the channel, so the service can be tested
with a fake.

Provider: `dictationServiceProvider` in `lib/features/entries/providers/dictation_providers.dart`.

### 3.3 Presentation — Dictate button and sheet

- New **Dictate** (mic) button in `editor_toolbar.dart`, next to "Scan text from image", with a
  localized tooltip. Wired through `entry_editor_layout.dart` and `entry_editor_screen.dart` the
  same way `onScanText` is.
- New bottom sheet `lib/features/entries/presentation/editor/dictation_sheet.dart`:
  - a language chip (languages the device can recognise offline; the choice is remembered under a
    new `dictation_language` preference, default = app language if offline-supported, else the
    first installed one);
  - a live text area: finished text in normal style, the in-progress guess in italics;
  - a listening indicator (with a `Semantics` label), **Pause/Resume**, **Discard** and
    **Insert**;
  - after stopping, the text becomes an editable field so mistakes can be fixed before inserting.
- **Insert** puts the text at the cursor in the Quill document (or replaces the selection), marks
  the entry dirty, and closes the sheet. Nothing is written until the user presses Insert.
- Screen stays awake is **not** added (would need `WAKE_LOCK`, which the manifest blocks).

Languages: English works on most phones with Google speech services. Malayalam works when the
Malayalam offline pack is installed. **Sanskrit has no Android on-device recogniser**, so for
Sanskrit UI the sheet picks English or Malayalam and says so. The UI itself stays fully localized
in all three languages.

### 3.4 Fix the voice-note recorder (scoped)

Remove the live transcription from the voice-note recorder. It cannot work while `record` holds
the microphone, and it is the cloud-leak path. Voice notes go back to "audio only", which is what
they reliably did in practice. `transcribeLive` / `stopTranscription` and the `speech_to_text`
import are removed from `VoiceNoteService`. The `VoiceNotes.transcript` column stays (no schema
change, old transcripts still export and back up). Aligned audio + transcript (enhancement idea
C1) is left for a later plan.

### 3.5 Localization

New keys in `app_en.arb`, `app_ml.arb`, `app_sa.arb` (with `@key` descriptions in `app_en.arb`),
for example: `tooltipEditorDictate`, `titleDictation`, `labelDictationListening`,
`labelDictationPaused`, `actionDictationInsert`, `actionDictationPause`, `actionDictationResume`,
`labelDictationLanguage`, `errorDictationOfflineUnavailable`, `errorDictationLanguageMissing`,
`helpDictationSanskritUnsupported`, `emptyDictationSaysomething`. Short keys stay inside the
label budget. New Malayalam and Sanskrit terms are marked "needs native-reader review" in the
change log. Run `flutter gen-l10n` and `tool/check_sanskrit_markers.sh`.

### 3.6 Docs

- `docs/security.md`: microphone row covers dictation; state the on-device-only guard and that
  no audio is stored by dictation.
- Permissions transparency screen (`lib/features/permissions/`): add dictation to the microphone
  purpose text.
- `docs/dependencies.md`: `speech_to_text` row — used by dictation, on-device mode only, and why
  the guard exists.
- `docs/features.md`, `docs/implementation_progress.md`, `docs/architecture.md` (new service,
  channel).

## 4. Files to change

| File | Change |
|---|---|
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` | `speech` channel, `onDeviceSpeechStatus` |
| `android/app/src/main/AndroidManifest.xml` | `RECORD_AUDIO`, `RecognitionService` query |
| `lib/features/entries/services/dictation_service.dart` | **new** |
| `lib/features/entries/services/speech_engine.dart` | **new** — plugin + channel wrapper |
| `lib/features/entries/providers/dictation_providers.dart` | **new** |
| `lib/features/entries/presentation/editor/dictation_sheet.dart` | **new** |
| `lib/features/entries/presentation/editor/editor_toolbar.dart` | Dictate button |
| `lib/features/entries/presentation/entry_editor_layout.dart`, `entry_editor_screen.dart`, one `entry_editor_actions*.dart` | wire button, insert at cursor |
| `lib/features/entries/services/voice_note_service.dart`, `presentation/editor/voice_note_recorder.dart` | remove live STT |
| `lib/features/permissions/…` | microphone purpose text |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` (+ generated) | new strings |
| `test/features/entries/services/dictation_service_test.dart` | **new** |
| `test/features/entries/presentation/editor/dictation_sheet_test.dart` | **new** |
| `docs/security.md`, `docs/dependencies.md`, `docs/features.md`, `docs/implementation_progress.md`, `docs/architecture.md` | docs |
| `change_log/<timestamp>_on-device-dictation.md` | **new** |

No new package. No schema change. No new network use.

## 5. Verification

- Unit tests (fake `SpeechEngine`):
  - on-device not available → `listen` is **never** called and the state is an error;
  - `listen` is always called with `onDevice: true`;
  - sessions restart after a pause, and final segments join correctly;
  - Pause, Resume, Discard and Stop behave; permission denied is reported.
- Widget test: sheet shows partial vs final text, Insert returns the text, Discard returns
  nothing, the offline-unavailable message shows.
- `flutter gen-l10n`, `flutter analyze` (zero issues), `flutter test` (includes translation parity
  and label length), `sh tool/check_sanskrit_markers.sh`, `dart format lib test integration_test`.
- Manual on a device (to be done by you): dictate in English and Malayalam with **airplane mode
  on** to prove it works offline; on a phone without offline speech, confirm the message appears.

## 6. Risks

- Some phones (no Google speech services, or Android 11 and older) will have no on-device
  recogniser. On those, dictation is simply unavailable. This is the price of the no-cloud rule.
- Recognition quality for Malayalam depends on the device's offline pack.
