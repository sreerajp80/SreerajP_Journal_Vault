part of 'app.dart';

/// One-shot fade and rise played when the lock screen appears.
class _LockGateEntrance extends StatelessWidget {
  const _LockGateEntrance({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Circular lock icon with a soft ring — the focal point of the lock screen.
class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: l10n.labelLockGateBadge,
      child: Center(
        child: Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withValues(alpha: 0.08),
          ),
          child: Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.lock_rounded,
                size: 42,
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small pill naming the active lock mode.
class _LockModeChip extends StatelessWidget {
  const _LockModeChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.onSecondaryContainer),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded surface holding the unlock controls.
class _LockCard extends StatelessWidget {
  const _LockCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Full-width unlock button that shows progress while an unlock is running.
class _LockActionButton extends StatelessWidget {
  const _LockActionButton({
    required this.buttonKey,
    required this.icon,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final Key buttonKey;
  final IconData icon;
  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        height: 54,
        child: FilledButton.icon(
          key: buttonKey,
          onPressed: busy ? null : onPressed,
          icon: busy
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onPrimary,
                  ),
                )
              : Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }
}

/// Themed error message shown under the unlock card.
class _LockErrorPill extends StatelessWidget {
  const _LockErrorPill({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: colors.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Main shell with bottom navigation ────────────────────────────────────
