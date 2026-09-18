import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/ritual/domain/ritual_card.dart';
import 'package:sreerajp_journal_vault/features/ritual/presentation/ritual_card_text.dart';
import 'package:sreerajp_journal_vault/features/ritual/providers/ritual_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Screen for creating or editing a user ritual card.
///
/// Pass an existing [card] to enter edit mode; omit it for create mode.
class CreateRitualCardScreen extends ConsumerStatefulWidget {
  const CreateRitualCardScreen({super.key, this.card});

  /// If non-null, the screen opens in edit mode with this card's data.
  final RitualCard? card;

  @override
  ConsumerState<CreateRitualCardScreen> createState() =>
      _CreateRitualCardScreenState();
}

class _CreateRitualCardScreenState
    extends ConsumerState<CreateRitualCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late RitualTheme _selectedTheme;
  late TextEditingController _titleController;
  late TextEditingController _promptController;
  late TextEditingController _quoteController;
  late TextEditingController _authorController;
  bool _isSaving = false;

  bool get _isEditMode => widget.card != null;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.card?.theme ?? RitualTheme.dharma;
    _titleController = TextEditingController(text: widget.card?.title ?? '');
    _promptController = TextEditingController(text: widget.card?.prompt ?? '');
    _quoteController = TextEditingController(text: widget.card?.quote ?? '');
    _authorController = TextEditingController(
      text: widget.card?.quoteAuthor ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    _quoteController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? l10n.titleRitualEditCard : l10n.titleRitualCreateCard,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Theme picker
            Text(
              l10n.labelRitualCardTheme,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RitualTheme.values.map((t) {
                final isSelected = _selectedTheme == t;
                return ChoiceChip(
                  avatar: Icon(
                    t.icon,
                    size: 18,
                    color: isSelected ? colorScheme.onPrimary : t.accentColor,
                  ),
                  label: Text(t.nameIn(l10n)),
                  selected: isSelected,
                  selectedColor: t.accentColor,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (_) => setState(() => _selectedTheme = t),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Title
            TextFormField(
              controller: _titleController,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: l10n.labelRitualCardTitle,
                hintText: l10n.descRitualCardTitle,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.errorRitualCardTitle;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Prompt / Reflection question
            TextFormField(
              controller: _promptController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.labelRitualCardPrompt,
                hintText: l10n.descRitualCardPrompt,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.errorRitualCardPrompt;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Quote / Teaching
            TextFormField(
              controller: _quoteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.labelRitualCardQuote,
                hintText: l10n.descRitualCardQuote,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.errorRitualCardQuote;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Quote Author / Source
            TextFormField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: l10n.labelRitualCardAuthor,
                hintText: l10n.descRitualCardAuthor,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Preview card
            _buildPreview(theme, colorScheme),

            const SizedBox(height: 24),

            // Save button
            FilledButton.icon(
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                _isEditMode
                    ? l10n.actionRitualSaveCardEdit
                    : l10n.actionRitualSaveCardCreate,
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isSaving ? null : _saveCard,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme, ColorScheme colorScheme) {
    final title = _titleController.text.trim();
    final prompt = _promptController.text.trim();
    final quote = _quoteController.text.trim();
    final author = _authorController.text.trim();

    if (title.isEmpty && prompt.isEmpty && quote.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.labelRitualCardPreview,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: _selectedTheme.accentColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedTheme.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _selectedTheme.icon,
                        size: 16,
                        color: _selectedTheme.accentColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedTheme.nameIn(l10n).toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _selectedTheme.accentColor,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (prompt.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    prompt,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                  ),
                ],
                if (quote.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.6,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 20,
                          color: _selectedTheme.accentColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '"$quote"${author.isNotEmpty ? ' — $author' : ''}',
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final notifier = ref.read(ritualNotifierProvider.notifier);

    try {
      if (_isEditMode) {
        await notifier.updateUserCard(
          dbId: widget.card!.dbId!,
          theme: _selectedTheme,
          title: _titleController.text.trim(),
          prompt: _promptController.text.trim(),
          quote: _quoteController.text.trim(),
          quoteAuthor: _authorController.text.trim().isNotEmpty
              ? _authorController.text.trim()
              : null,
        );
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.bodyRitualCardUpdated)),
        );
      } else {
        await notifier.addUserCard(
          theme: _selectedTheme,
          title: _titleController.text.trim(),
          prompt: _promptController.text.trim(),
          quote: _quoteController.text.trim(),
          quoteAuthor: _authorController.text.trim().isNotEmpty
              ? _authorController.text.trim()
              : null,
        );
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.bodyRitualCardCreated)),
        );
      }
      navigator.pop(true);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorRitualCardSave)));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
