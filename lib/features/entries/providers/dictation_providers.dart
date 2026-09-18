import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/features/entries/services/dictation_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/speech_engine.dart';

/// The on-device speech recogniser. One per app, because the plugin behind it
/// is a single platform object.
final speechEngineProvider = Provider<SpeechEngine>((ref) {
  return PluginSpeechEngine();
});

/// Makes a fresh [DictationService] for one dictation sheet. Each sheet owns
/// and disposes its own service, so no text outlives the sheet.
final dictationServiceFactoryProvider = Provider<DictationService Function()>((
  ref,
) {
  final engine = ref.watch(speechEngineProvider);
  return () => DictationService(engine);
});

/// Remembers the last dictation language.
final dictationLanguageStoreProvider = Provider<DictationLanguageStore>((ref) {
  return const DictationLanguageStore();
});
