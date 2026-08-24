import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Preset duration choices for quickly setting a time capsule unlock date.
enum TimeCapsulePreset {
  oneMonth,
  sixMonths,
  oneYear,
  threeYears,
  fiveYears,
  custom,
}

/// Result returned from [TimeCapsuleSealDialog].
class TimeCapsuleSealConfig {
  final DateTime unlockDate;
  final String? teaserMessage;

  const TimeCapsuleSealConfig({required this.unlockDate, this.teaserMessage});
}

/// Dialog allowing the user to configure and confirm sealing an entry as a Time Capsule.
class TimeCapsuleSealDialog extends StatefulWidget {
  const TimeCapsuleSealDialog({super.key, this.initialUnlockDate});

  final DateTime? initialUnlockDate;

  @override
  State<TimeCapsuleSealDialog> createState() => _TimeCapsuleSealDialogState();
}

class _TimeCapsuleSealDialogState extends State<TimeCapsuleSealDialog> {
  late DateTime _selectedDate;
  TimeCapsulePreset _selectedPreset = TimeCapsulePreset.oneYear;
  final TextEditingController _teaserController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate =
        widget.initialUnlockDate ??
        DateTime(now.year + 1, now.month, now.day, now.hour, now.minute);
  }

  @override
  void dispose() {
    _teaserController.dispose();
    super.dispose();
  }

  void _applyPreset(TimeCapsulePreset preset) {
    final now = DateTime.now();
    DateTime target;
    switch (preset) {
      case TimeCapsulePreset.oneMonth:
        target = DateTime(
          now.year,
          now.month + 1,
          now.day,
          now.hour,
          now.minute,
        );
        break;
      case TimeCapsulePreset.sixMonths:
        target = DateTime(
          now.year,
          now.month + 6,
          now.day,
          now.hour,
          now.minute,
        );
        break;
      case TimeCapsulePreset.oneYear:
        target = DateTime(
          now.year + 1,
          now.month,
          now.day,
          now.hour,
          now.minute,
        );
        break;
      case TimeCapsulePreset.threeYears:
        target = DateTime(
          now.year + 3,
          now.month,
          now.day,
          now.hour,
          now.minute,
        );
        break;
      case TimeCapsulePreset.fiveYears:
        target = DateTime(
          now.year + 5,
          now.month,
          now.day,
          now.hour,
          now.minute,
        );
        break;
      case TimeCapsulePreset.custom:
        _pickCustomDate();
        return;
    }
    setState(() {
      _selectedPreset = preset;
      _selectedDate = target;
    });
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(now)
          ? _selectedDate
          : now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: DateTime(now.year + 100),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _selectedPreset = TimeCapsulePreset.custom;
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final formattedDate = DateFormat.yMMMMd().format(_selectedDate);

    return AlertDialog(
      key: const Key('time-capsule-seal-dialog'),
      title: Row(
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.timeCapsuleSealTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.timeCapsuleSealDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.timeCapsuleUnlockDateLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // Date preview card
            InkWell(
              key: const Key('time-capsule-date-picker-button'),
              onTap: _pickCustomDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        formattedDate,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.edit_calendar_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Preset chips
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  key: const Key('time-capsule-preset-1m'),
                  label: Text(l10n.timeCapsulePreset1Month),
                  selected: _selectedPreset == TimeCapsulePreset.oneMonth,
                  onSelected: (_) => _applyPreset(TimeCapsulePreset.oneMonth),
                ),
                ChoiceChip(
                  key: const Key('time-capsule-preset-6m'),
                  label: Text(l10n.timeCapsulePreset6Months),
                  selected: _selectedPreset == TimeCapsulePreset.sixMonths,
                  onSelected: (_) => _applyPreset(TimeCapsulePreset.sixMonths),
                ),
                ChoiceChip(
                  key: const Key('time-capsule-preset-1y'),
                  label: Text(l10n.timeCapsulePreset1Year),
                  selected: _selectedPreset == TimeCapsulePreset.oneYear,
                  onSelected: (_) => _applyPreset(TimeCapsulePreset.oneYear),
                ),
                ChoiceChip(
                  key: const Key('time-capsule-preset-3y'),
                  label: Text(l10n.timeCapsulePreset3Years),
                  selected: _selectedPreset == TimeCapsulePreset.threeYears,
                  onSelected: (_) => _applyPreset(TimeCapsulePreset.threeYears),
                ),
                ChoiceChip(
                  key: const Key('time-capsule-preset-5y'),
                  label: Text(l10n.timeCapsulePreset5Years),
                  selected: _selectedPreset == TimeCapsulePreset.fiveYears,
                  onSelected: (_) => _applyPreset(TimeCapsulePreset.fiveYears),
                ),
                ChoiceChip(
                  key: const Key('time-capsule-preset-custom'),
                  label: Text(l10n.timeCapsulePresetCustom),
                  selected: _selectedPreset == TimeCapsulePreset.custom,
                  onSelected: (_) => _pickCustomDate(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('time-capsule-teaser-field'),
              controller: _teaserController,
              decoration: InputDecoration(
                labelText: l10n.timeCapsuleTeaserHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.notes_rounded),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            // Security reminder box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_clock_rounded,
                    size: 20,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.timeCapsuleLockedExplanation,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton.icon(
          key: const Key('time-capsule-confirm-seal-button'),
          icon: const Icon(Icons.lock_outline_rounded, size: 18),
          label: Text(l10n.timeCapsuleSealConfirm),
          onPressed: () {
            Navigator.pop(
              context,
              TimeCapsuleSealConfig(
                unlockDate: _selectedDate,
                teaserMessage: _teaserController.text.trim().isEmpty
                    ? null
                    : _teaserController.text.trim(),
              ),
            );
          },
        ),
      ],
    );
  }
}
