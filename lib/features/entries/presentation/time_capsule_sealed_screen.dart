import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/l10n/formatting_locale.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_editor_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/time_capsule_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/time_capsule_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

part 'time_capsule_sealed_widgets.dart';

/// Screen displayed when opening a sealed time capsule entry.
///
/// Features:
/// - Live countdown ticker to unlock date.
/// - Display of seal timestamp, target unlock date, and optional teaser note.
/// - Cryptographic lock assurance explanation.
/// - Unseal action (active once the unlock date is reached).
class TimeCapsuleSealedScreen extends ConsumerStatefulWidget {
  const TimeCapsuleSealedScreen({
    super.key,
    required this.entryId,
    this.journalId,
  });

  final int entryId;
  final int? journalId;

  @override
  ConsumerState<TimeCapsuleSealedScreen> createState() =>
      _TimeCapsuleSealedScreenState();
}

class _TimeCapsuleSealedScreenState
    extends ConsumerState<TimeCapsuleSealedScreen> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  bool _isUnsealing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _unseal(TimeCapsule capsule) async {
    if (_isUnsealing) return;
    setState(() {
      _isUnsealing = true;
      _errorMessage = null;
    });

    final l10n = AppLocalizations.of(context);
    final service = ref.read(timeCapsuleServiceProvider);

    try {
      final restoredEntry = await service.unsealEntry(capsule.entryId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const Key('capsule-unsealed-snackbar'),
          content: Text(l10n.bodyTimeCapsuleUnsealedSuccess),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      // Navigate to EntryEditorScreen with the unsealed entry
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => EntryEditorScreen(
            journalId: restoredEntry.journalId,
            entryId: restoredEntry.id,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isUnsealing = false;
        if (error is TimeCapsuleClockTamperException) {
          _errorMessage = l10n.errorTimeCapsuleClockTamper;
        } else if (error is TimeCapsuleLockedException) {
          _errorMessage = l10n.actionTimeCapsuleUnsealLockedPrompt(
            DateFormat.yMMMMd(
              formattingLocaleTag(
                Localizations.localeOf(context).toLanguageTag(),
              ),
            ).add_jms().format(error.unlockDate),
          );
        } else {
          _errorMessage = l10n.errorTimeCapsuleUnseal;
        }
      });
    }
  }

  Future<void> _deleteEntry(int entryId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.bodyEntryDelete),
        content: Text(l10n.bodyEntryDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l10n.actionCommonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogCtx).colorScheme.error,
            ),
            child: Text(l10n.actionCommonDelete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final db = ref.read(appDatabaseProvider);
      await db.entriesDao.deleteEntryById(entryId);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final capsuleAsync = ref.watch(timeCapsuleForEntryProvider(widget.entryId));

    return Scaffold(
      key: const Key('time-capsule-sealed-screen'),
      appBar: AppBar(
        title: Text(l10n.labelTimeCapsuleSealedBadge),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.tooltipEntryDelete,
            onPressed: () => _deleteEntry(widget.entryId),
          ),
        ],
      ),
      body: capsuleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorTimeCapsuleLoad)),
        data: (capsule) {
          if (capsule == null) {
            return Center(child: Text(l10n.errorTimeCapsuleNotFound));
          }

          final isReady = !_now.isBefore(capsule.unlockDate);
          final remaining = isReady
              ? Duration.zero
              : capsule.unlockDate.difference(_now);

          final days = remaining.inDays;
          final hours = remaining.inHours % 24;
          final minutes = remaining.inMinutes % 60;
          final seconds = remaining.inSeconds % 60;

          // intl has no Sanskrit data, so dates fall back to English patterns.
          final fmt = formattingLocaleTag(
            Localizations.localeOf(context).toLanguageTag(),
          );
          final formattedUnlockDate = DateFormat.yMMMMd(
            fmt,
          ).add_jm().format(capsule.unlockDate);
          final formattedSealedDate = DateFormat.yMMMMd(
            fmt,
          ).format(capsule.sealedAt);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Glowing Capsule Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: isReady
                        ? colors.primaryContainer
                        : colors.secondaryContainer.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isReady
                            ? colors.primary.withValues(alpha: 0.3)
                            : colors.secondary.withValues(alpha: 0.15),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    isReady
                        ? Icons.lock_open_rounded
                        : Icons.hourglass_bottom_rounded,
                    size: 48,
                    color: isReady ? colors.primary : colors.secondary,
                  ),
                ),
                const SizedBox(height: 24),
                // Header badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isReady
                        ? colors.primary.withValues(alpha: 0.12)
                        : colors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isReady
                          ? colors.primary.withValues(alpha: 0.4)
                          : colors.secondary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    isReady
                        ? l10n.actionTimeCapsuleReadyToOpen
                        : l10n.labelTimeCapsuleSealedUntil(formattedUnlockDate),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isReady ? colors.primary : colors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Countdown Timer Box
                if (!isReady) ...[
                  Row(
                    key: const Key('time-capsule-countdown-display'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CountdownUnit(
                        value: days,
                        label: l10n.labelTimeCapsuleDays,
                      ),
                      const SizedBox(width: 8),
                      _CountdownUnit(
                        value: hours,
                        label: l10n.labelTimeCapsuleHours,
                      ),
                      const SizedBox(width: 8),
                      _CountdownUnit(
                        value: minutes,
                        label: l10n.labelTimeCapsuleMinutes,
                      ),
                      const SizedBox(width: 8),
                      _CountdownUnit(
                        value: seconds,
                        label: l10n.labelTimeCapsuleSeconds,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Teaser note if present
                if (capsule.teaserMessage != null &&
                    capsule.teaserMessage!.isNotEmpty) ...[
                  Card(
                    elevation: 0,
                    color: colors.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colors.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 18,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.labelTimeCapsuleTeaser,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            capsule.teaserMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Timestamps Card
                Card(
                  elevation: 0,
                  color: colors.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.history_rounded,
                          label: l10n.labelTimeCapsuleSealedOn,
                          value: formattedSealedDate,
                        ),
                        const Divider(height: 16),
                        _DetailRow(
                          icon: Icons.event_available_rounded,
                          label: l10n.labelTimeCapsuleUnlocksOn,
                          value: formattedUnlockDate,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cryptographic Assurance Note
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.6,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 20,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.descTimeCapsuleLocked,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: colors.onErrorContainer),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Unseal Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    key: const Key('time-capsule-unseal-button'),
                    icon: _isUnsealing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            isReady
                                ? Icons.key_rounded
                                : Icons.lock_clock_rounded,
                          ),
                    label: Text(
                      isReady
                          ? l10n.actionTimeCapsuleUnseal
                          : l10n.actionTimeCapsuleUnsealLockedPrompt(
                              formattedUnlockDate,
                            ),
                    ),
                    onPressed: (isReady && !_isUnsealing)
                        ? () => _unseal(capsule)
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
