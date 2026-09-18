part of 'features_screen.dart';

class _FeatureTile extends StatefulWidget {
  final _AppFeature feature;
  const _FeatureTile({required this.feature});

  @override
  State<_FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<_FeatureTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final f = widget.feature;

    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(f.icon, size: 22, color: accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        f.description,
                        maxLines: _expanded ? null : 2,
                        overflow: _expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            if (_expanded && f.highlights.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 54),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: f.highlights
                      .map(
                        (h) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.2),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            h,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
