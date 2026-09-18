import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/ritual/domain/ritual_card.dart';
import 'package:sreerajp_journal_vault/features/ritual/domain/spaced_repetition.dart';
import 'package:sreerajp_journal_vault/features/ritual/presentation/create_ritual_card_screen.dart';
import 'package:sreerajp_journal_vault/features/ritual/presentation/ritual_card_text.dart';
import 'package:sreerajp_journal_vault/features/ritual/providers/ritual_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Screen allowing the user to browse all Sanathana Dharma reflection cards
/// and their SRS review status, plus create/edit/delete user cards.
class RitualDeckScreen extends ConsumerStatefulWidget {
  const RitualDeckScreen({super.key});

  @override
  ConsumerState<RitualDeckScreen> createState() => _RitualDeckScreenState();
}

class _RitualDeckScreenState extends ConsumerState<RitualDeckScreen> {
  RitualTheme? _selectedTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ritualState = ref.watch(ritualNotifierProvider);

    final filteredCards = _selectedTheme == null
        ? ritualState.deck
        : ritualState.deck.where((c) => c.theme == _selectedTheme).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.titleRitualDeckBrowser),
        actions: [
          IconButton(
            tooltip: l10n.tooltipRitualResetReviews,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _confirmReset(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateCard(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.actionRitualCreateCard),
      ),
      body: Column(
        children: [
          // Theme filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  selected: _selectedTheme == null,
                  label: Text(l10n.labelRitualAllThemes),
                  onSelected: (_) => setState(() => _selectedTheme = null),
                ),
                const SizedBox(width: 8),
                ...RitualTheme.values.map((t) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _selectedTheme == t,
                      avatar: Icon(t.icon, size: 16, color: t.accentColor),
                      label: Text(t.nameIn(l10n)),
                      onSelected: (_) => setState(() => _selectedTheme = t),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),
          // Cards list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 80,
              ),
              itemCount: filteredCards.length,
              itemBuilder: (context, index) {
                final card = filteredCards[index];
                return _DeckCardTile(
                  card: card,
                  onSelect: () {
                    ref.read(ritualNotifierProvider.notifier).selectCard(card);
                    Navigator.of(context).pop(card);
                  },
                  onEdit: card.isUserCreated
                      ? () => _openEditCard(context, card)
                      : null,
                  onDelete: card.isUserCreated
                      ? () => _confirmDelete(context, card)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCreateCard(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const CreateRitualCardScreen()),
    );
    if (result == true && mounted) {
      ref.read(ritualNotifierProvider.notifier).refreshDeck();
    }
  }

  Future<void> _openEditCard(BuildContext context, RitualCard card) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CreateRitualCardScreen(card: card),
      ),
    );
    if (result == true && mounted) {
      ref.read(ritualNotifierProvider.notifier).refreshDeck();
    }
  }

  Future<void> _confirmDelete(BuildContext context, RitualCard card) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cardTitle = card.titleIn(l10n);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.titleRitualDeleteCard),
        content: Text(l10n.bodyRitualDeleteCard(cardTitle)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCommonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionRitualDeleteCard),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted && card.dbId != null) {
      await ref
          .read(ritualNotifierProvider.notifier)
          .deleteUserCard(card.dbId!);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.bodyRitualCardDeleted)),
      );
    }
  }

  Future<void> _confirmReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.titleRitualResetReviews),
        content: Text(l10n.bodyRitualResetReviews),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCommonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionCommonReset),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final service = ref.read(ritualServiceProvider);
      if (service != null) {
        await service.resetAllCardReviews();
      }
      ref.invalidate(ritualNotifierProvider);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.bodyRitualResetReviewsDone)),
      );
    }
  }
}

class _DeckCardTile extends ConsumerWidget {
  const _DeckCardTile({
    required this.card,
    required this.onSelect,
    this.onEdit,
    this.onDelete,
  });

  final RitualCard card;
  final VoidCallback onSelect;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final service = ref.watch(ritualServiceProvider);
    final reviewState =
        service?.getReviewState(card.id) ?? CardReviewState.initial(card.id);

    final title = card.titleIn(l10n);
    final prompt = card.promptIn(l10n);
    final quote = card.quoteIn(l10n);
    final quoteAuthor = card.sourceIn(l10n);
    final themeName = card.theme.nameIn(l10n);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Theme badge, Number, User badge & SRS status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: card.theme.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          card.theme.icon,
                          size: 14,
                          color: card.theme.accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          themeName.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: card.theme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '#${card.number}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (card.isUserCreated) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.labelRitualUserCardBadge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  _buildSrsBadge(context, reviewState, l10n),
                  // Edit/delete menu for user cards
                  if (card.isUserCreated &&
                      (onEdit != null || onDelete != null))
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      tooltip: l10n.tooltipMoreOptions,
                      padding: EdgeInsets.zero,
                      itemBuilder: (ctx) => [
                        if (onEdit != null)
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text(l10n.actionRitualEditCard),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.actionRitualDeleteCard,
                                  style: TextStyle(color: colorScheme.error),
                                ),
                              ],
                            ),
                          ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit?.call();
                        } else if (value == 'delete') {
                          onDelete?.call();
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                prompt,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 18,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '"$quote"${quoteAuthor != null ? " — $quoteAuthor" : ""}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSrsBadge(
    BuildContext context,
    CardReviewState state,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDue = state.isDue();

    if (state.reviewCount == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          l10n.labelRitualSrsNew,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    if (isDue) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          l10n.labelRitualSrsDueToday,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final days = state.nextReviewDate.difference(DateTime.now()).inDays + 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        l10n.labelRitualSrsInDays(days),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
