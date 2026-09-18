import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sreerajp_journal_vault/core/l10n/formatting_locale.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Represents the auto-save state of the entry editor.
enum EditorSaveStatus {
  /// All changes are saved to storage.
  saved,

  /// Currently executing a save operation.
  saving,

  /// Unsaved edits are waiting to be persisted.
  unsaved,
}

/// Bottom status bar for the editor displaying live word/character counts
/// and the auto-save timestamp indicator.
class EditorStatsBar extends StatelessWidget {
  const EditorStatsBar({
    super.key,
    required this.wordCount,
    required this.characterCount,
    required this.saveStatus,
    this.lastSavedTime,
    this.compact = false,
  });

  final int wordCount;
  final int characterCount;
  final EditorSaveStatus saveStatus;
  final DateTime? lastSavedTime;
  final bool compact;

  /// Counts words in the given plain text.
  static int countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  /// Counts characters in the given plain text (excluding the trailing newline from Quill).
  static int countCharacters(String text) {
    if (text.isEmpty) return 0;
    // Quill documents always terminate in a trailing newline.
    if (text.endsWith('\n')) {
      return (text.length - 1).clamp(0, text.length);
    }
    return text.length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final wordsStr = l10n.descEntryWordCount(wordCount);
    final charsStr = l10n.descEntryCharCount(characterCount);
    final statsText = l10n.descEntryStats(wordsStr, charsStr);

    // intl has no Sanskrit data, so the time falls back to English patterns.
    final (statusIcon, statusText, statusColor) = _resolveStatus(
      l10n,
      theme,
      formattingLocaleTag(Localizations.localeOf(context).toLanguageTag()),
    );

    return Container(
      key: const Key('editor-stats-bar'),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 3 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Word & Character count
          Text(
            statsText,
            key: const Key('editor-word-char-count'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          // Auto-save status indicator
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 13, color: statusColor),
              const SizedBox(width: 4),
              Text(
                statusText,
                key: const Key('editor-autosave-status'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: saveStatus == EditorSaveStatus.saving
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (IconData, String, Color) _resolveStatus(
    AppLocalizations l10n,
    ThemeData theme,
    String? formattingLocale,
  ) {
    switch (saveStatus) {
      case EditorSaveStatus.saving:
        return (
          Icons.sync,
          l10n.labelEntryAutoSaving,
          theme.colorScheme.primary,
        );
      case EditorSaveStatus.unsaved:
        return (
          Icons.edit_outlined,
          l10n.labelEntryUnsavedChanges,
          theme.colorScheme.onSurfaceVariant,
        );
      case EditorSaveStatus.saved:
        final time = lastSavedTime;
        if (time != null) {
          final timeStr = DateFormat.jm(formattingLocale).format(time);
          return (
            Icons.check_circle_outline,
            l10n.labelEntryAutoSaved(timeStr),
            theme.colorScheme.outline,
          );
        }
        return (
          Icons.check_circle_outline,
          l10n.labelEntryAutoSavedJustNow,
          theme.colorScheme.outline,
        );
    }
  }
}
