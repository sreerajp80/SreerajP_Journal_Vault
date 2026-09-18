part of 'app.dart';

class _JournalCard extends StatelessWidget {
  const _JournalCard({
    required this.summary,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final _JournalSummary summary;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final journal = summary.journal;
    final cover = _coverColorForJournal(journal.id);
    final initial = journal.title.isEmpty
        ? '?'
        : journal.title.characters.first.toUpperCase();
    final visibleTags = summary.tags.take(2).toList();
    final lastUpdated = summary.lastUpdatedAt;
    final l10n = AppLocalizations.of(context);
    final metaParts = <String>[
      l10n.labelJournalEntryCount(summary.entryCount),
      if (lastUpdated != null) _formatRelativeDate(l10n, lastUpdated),
    ];

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover with big faded initial + lock badge
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cover.withValues(alpha: 0.85),
                          cover.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -8,
                    bottom: -22,
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 110,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  if (journal.isLocked)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Body: title, meta, tags, actions
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      metaParts.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (visibleTags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: -8,
                        children: [
                          for (final tag in visibleTags)
                            Text(
                              '#${tag.name}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorForTag(tag),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 16,
                            tooltip: AppLocalizations.of(
                              context,
                            ).tooltipJournalEdit,
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: onEdit,
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 16,
                            tooltip: AppLocalizations.of(
                              context,
                            ).tooltipJournalDelete,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: onDelete,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Journal form dialog ──────────────────────────────────────────────────

class _JournalFormDialog extends StatefulWidget {
  const _JournalFormDialog({this.journal, this.initialTags = const []});

  final Journal? journal;
  final List<Tag> initialTags;

  @override
  State<_JournalFormDialog> createState() => _JournalFormDialogState();
}

class _JournalFormDialogState extends State<_JournalFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _tags;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  bool _lockJournal = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.journal?.title ?? '');
    _desc = TextEditingController(text: widget.journal?.description ?? '');
    _tags = TextEditingController(
      text: widget.initialTags.map((t) => t.name).join(', '),
    );
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _tags.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEdit = widget.journal != null;
    return AlertDialog(
      title: Text(isEdit ? l10n.tooltipJournalEdit : l10n.tooltipJournalNew),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _title,
              decoration: InputDecoration(labelText: l10n.labelJournalTitle),
            ),
            TextFormField(
              controller: _desc,
              decoration: InputDecoration(
                labelText: l10n.labelJournalDescription,
              ),
            ),
            TextFormField(
              controller: _tags,
              decoration: InputDecoration(labelText: l10n.labelJournalTags),
            ),
            // Locking is only offered at creation time — changing the password
            // of an existing journal is a separate flow.
            if (!isEdit) ...[
              SwitchListTile(
                title: Text(l10n.labelJournalLockSwitch),
                value: _lockJournal,
                onChanged: (v) => setState(() => _lockJournal = v),
              ),
              if (_lockJournal) ...[
                TextFormField(
                  key: const Key('journal-password-field'),
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.labelCommonPassword,
                  ),
                ),
                TextFormField(
                  key: const Key('journal-password-confirm-field'),
                  controller: _confirmPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.labelJournalConfirmPassword,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCommonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, (
            title: _title.text,
            desc: _desc.text,
            tags: _tags.text,
            locked: _lockJournal,
            password: _password.text.isEmpty ? null : _password.text,
          )),
          child: Text(l10n.actionCommonSave),
        ),
      ],
    );
  }
}

// ─── Journal detail ───────────────────────────────────────────────────────
