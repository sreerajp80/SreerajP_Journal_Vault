part of 'storage_settings_screen.dart';

class MigrationProgressController extends ChangeNotifier {
  int _processed = 0;
  int _total = 0;
  bool _cancelRequested = false;
  bool _completed = false;

  int get processed => _processed;
  int get total => _total;
  bool get cancelRequested => _cancelRequested;
  bool get completed => _completed;

  void update(int processed, int total) {
    _processed = processed;
    _total = total;
    notifyListeners();
  }

  void cancel() {
    if (_cancelRequested) return;
    _cancelRequested = true;
    notifyListeners();
  }

  void complete() {
    if (_completed) return;
    _completed = true;
    notifyListeners();
  }
}

class MigrationProgressDialog extends StatefulWidget {
  const MigrationProgressDialog({super.key, required this.controller});

  final MigrationProgressController controller;

  @override
  State<MigrationProgressDialog> createState() =>
      _MigrationProgressDialogState();
}

class _MigrationProgressDialogState extends State<MigrationProgressDialog> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (!mounted) return;
    if (widget.controller.completed) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = widget.controller;
    final progress = c.total == 0 ? null : c.processed / c.total;
    return AlertDialog(
      title: Text(l10n.titleMigration),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 12),
          Text(
            c.cancelRequested
                ? l10n.bodyMigrationCancelling
                : l10n.labelMigrationProgress(
                    '${c.processed}',
                    c.total == 0
                        ? l10n.descMigrationUnknownTotal
                        : '${c.total}',
                  ),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('migration-cancel-button'),
          onPressed: c.cancelRequested ? null : c.cancel,
          child: Text(l10n.actionCommonCancel),
        ),
      ],
    );
  }
}
