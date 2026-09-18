import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/dictation_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/dictation_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Opens the dictation sheet and returns the text to insert, or null when the
/// user discards it.
Future<String?> showDictationSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const DictationSheet(),
  );
}

/// Bottom sheet that turns speech into text, on the device only.
///
/// Listening starts as soon as the sheet opens. "Done" stops listening and
/// makes the text editable; "Insert" hands it back to the editor. Nothing
/// reaches the entry until the user presses Insert.
class DictationSheet extends ConsumerStatefulWidget {
  const DictationSheet({super.key});

  @override
  ConsumerState<DictationSheet> createState() => _DictationSheetState();
}

class _DictationSheetState extends ConsumerState<DictationSheet> {
  late final DictationService _service;
  StreamSubscription<DictationState>? _subscription;
  DictationState _state = const DictationState();
  final TextEditingController _textController = TextEditingController();
  String? _language;

  @override
  void initState() {
    super.initState();
    _service = ref.read(dictationServiceFactoryProvider)();
    _subscription = _service.states.listen((next) {
      if (!mounted) return;
      setState(() => _state = next);
    });
    unawaited(_begin());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    unawaited(_service.dispose());
    _textController.dispose();
    super.dispose();
  }

  Future<void> _begin() async {
    final ready = await _service.prepare();
    if (!mounted || ready.status != DictationStatus.ready) return;
    final saved = await ref.read(dictationLanguageStoreProvider).read();
    if (!mounted) return;
    final language = pickDictationLanguage(
      languages: ready.languages,
      saved: saved,
      appLanguageCode: Localizations.localeOf(context).languageCode,
    );
    setState(() => _language = language);
    await _service.start(language);
  }

  Future<void> _changeLanguage(String language) async {
    if (language == _language) return;
    setState(() => _language = language);
    unawaited(ref.read(dictationLanguageStoreProvider).save(language));
    final wasListening = _state.status == DictationStatus.listening;
    if (wasListening) await _service.pause();
    if (_state.status == DictationStatus.paused) {
      await _service.start(language);
    }
  }

  Future<void> _togglePause() async {
    if (_state.status == DictationStatus.listening) {
      await _service.pause();
    } else if (_state.status == DictationStatus.paused) {
      await _service.start(_language);
    }
  }

  Future<void> _finish() async {
    final text = await _service.finish();
    if (!mounted) return;
    _textController.text = text;
  }

  Future<void> _discard() async {
    await _service.discard();
    if (mounted) Navigator.of(context).pop();
  }

  void _insert() {
    final text = _textController.text.trim();
    Navigator.of(context).pop(text.isEmpty ? null : text);
  }

  String _languageName(AppLocalizations l10n, String tag) {
    final code = tag.toLowerCase().split(RegExp('[-_]')).first;
    final name = switch (code) {
      'en' => l10n.labelLanguageEnglish,
      'ml' => l10n.labelLanguageMalayalam,
      'sa' => l10n.labelLanguageSanskrit,
      _ => null,
    };
    return name == null ? tag : '$name ($tag)';
  }

  String _errorText(AppLocalizations l10n, DictationError? error) {
    return switch (error) {
      DictationError.offlineUnavailable =>
        l10n.errorDictationOfflineUnavailable,
      DictationError.permissionDenied => l10n.bodyEditorMicPermissionDenied,
      DictationError.languageUnavailable =>
        l10n.errorDictationLanguageUnavailable,
      DictationError.failed || null => l10n.errorDictationFailed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = _state.status;
    final isSanskritUi = Localizations.localeOf(context).languageCode == 'sa';
    final hasSanskrit = _state.languages.any(
      (tag) => tag.toLowerCase().startsWith('sa'),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.titleDictation,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (_state.languages.length > 1 &&
                  status != DictationStatus.stopped &&
                  status != DictationStatus.error)
                PopupMenuButton<String>(
                  key: const Key('dictation-language-menu'),
                  tooltip: l10n.tooltipDictationLanguage,
                  initialValue: _language,
                  onSelected: _changeLanguage,
                  itemBuilder: (_) => [
                    for (final tag in _state.languages)
                      PopupMenuItem(
                        value: tag,
                        child: Text(_languageName(l10n, tag)),
                      ),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.translate, size: 18),
                    label: Text(
                      _language == null
                          ? l10n.labelDictationDeviceDefault
                          : _languageName(l10n, _language!),
                    ),
                  ),
                )
              else if (status != DictationStatus.error)
                Chip(
                  avatar: const Icon(Icons.translate, size: 18),
                  label: Text(
                    _language == null
                        ? l10n.labelDictationDeviceDefault
                        : _languageName(l10n, _language!),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.descDictationPrivacy,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (isSanskritUi && !hasSanskrit && status != DictationStatus.error)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.helpDictationSanskritUnsupported,
                style: theme.textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 16),
          _buildBody(l10n, theme),
          const SizedBox(height: 16),
          _buildControls(l10n, theme),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, ThemeData theme) {
    switch (_state.status) {
      case DictationStatus.idle:
      case DictationStatus.preparing:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        );
      case DictationStatus.error:
        return Text(
          _errorText(l10n, _state.error),
          key: const Key('dictation-error'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        );
      case DictationStatus.stopped:
        return TextField(
          key: const Key('dictation-text-field'),
          controller: _textController,
          minLines: 3,
          maxLines: 8,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.labelDictationEditHint,
            border: const OutlineInputBorder(),
          ),
        );
      case DictationStatus.ready:
      case DictationStatus.listening:
      case DictationStatus.paused:
        final empty =
            _state.committedText.isEmpty && _state.partialText.isEmpty;
        return Container(
          constraints: const BoxConstraints(minHeight: 96, maxHeight: 240),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            reverse: true,
            child: empty
                ? Text(
                    l10n.emptyDictationSpeak,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : Text.rich(
                    key: const Key('dictation-live-text'),
                    TextSpan(
                      style: theme.textTheme.bodyLarge,
                      children: [
                        TextSpan(text: _state.committedText),
                        if (_state.committedText.isNotEmpty &&
                            _state.partialText.isNotEmpty)
                          const TextSpan(text: ' '),
                        TextSpan(
                          text: _state.partialText,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
    }
  }

  Widget _buildControls(AppLocalizations l10n, ThemeData theme) {
    final status = _state.status;
    final discard = TextButton.icon(
      key: const Key('dictation-discard'),
      onPressed: _discard,
      icon: const Icon(Icons.delete_outline),
      label: Text(l10n.actionEditorDiscard),
      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
    );

    switch (status) {
      case DictationStatus.error:
        return Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            key: const Key('dictation-close'),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCommonClose),
          ),
        );
      case DictationStatus.stopped:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            discard,
            FilledButton.icon(
              key: const Key('dictation-insert'),
              onPressed: _insert,
              icon: const Icon(Icons.check),
              label: Text(l10n.actionDictationInsert),
            ),
          ],
        );
      case DictationStatus.idle:
      case DictationStatus.preparing:
      case DictationStatus.ready:
      case DictationStatus.listening:
      case DictationStatus.paused:
        final listening = status == DictationStatus.listening;
        final canToggle = listening || status == DictationStatus.paused;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            discard,
            Semantics(
              label: listening
                  ? l10n.labelDictationListening
                  : l10n.labelDictationPaused,
              liveRegion: true,
              child: FloatingActionButton(
                key: const Key('dictation-pause-toggle'),
                heroTag: 'dictation_pause_toggle',
                tooltip: listening
                    ? l10n.tooltipDictationPause
                    : l10n.tooltipDictationResume,
                onPressed: canToggle ? _togglePause : null,
                backgroundColor: listening
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                child: Icon(
                  listening ? Icons.pause : Icons.mic,
                  color: listening
                      ? theme.colorScheme.onError
                      : theme.colorScheme.onPrimary,
                ),
              ),
            ),
            TextButton.icon(
              key: const Key('dictation-done'),
              onPressed: canToggle ? _finish : null,
              icon: const Icon(Icons.check),
              label: Text(l10n.actionEditorDone),
            ),
          ],
        );
    }
  }
}
