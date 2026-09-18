import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/theme/typography_controller.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/template_token_text.dart';
import 'package:sreerajp_journal_vault/features/entries/templates/template_token_engine.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Screen allowing the user to create or edit a custom entry template.
///
/// Supports inserting dynamic date tokens such as `{{today}}` and `{{weekday}}`
/// into both the template's default title and starter content body.
class TemplateEditorScreen extends ConsumerStatefulWidget {
  const TemplateEditorScreen({
    super.key,
    this.existingTemplate,
    this.initialTitle,
    this.initialContentJson,
  });

  /// The template to edit, or null if creating a new template.
  final UserTemplate? existingTemplate;

  /// Optional initial title (e.g. from "Save as template" in entry editor).
  final String? initialTitle;

  /// Optional initial content JSON (e.g. from "Save as template" in entry editor).
  final String? initialContentJson;

  @override
  ConsumerState<TemplateEditorScreen> createState() =>
      _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _defaultTitleController;
  late final FocusNode _defaultTitleFocusNode;
  late final QuillController _quillController;

  /// Owned by this screen and handed to the body editor. [QuillEditor.basic]
  /// builds a fresh [FocusNode] and [ScrollController] when it isn't given
  /// them, so the body would lose focus (and its scroll position) on every
  /// rebuild.
  final FocusNode _bodyFocusNode = FocusNode(debugLabel: 'TemplateBodyEditor');
  final ScrollController _bodyScrollController = ScrollController();

  bool _isSaving = false;
  bool _titleHasFocus = false;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTemplate;
    _nameController = TextEditingController(text: t?.name ?? '');
    _descriptionController = TextEditingController(text: t?.description ?? '');
    _defaultTitleController = TextEditingController(
      text: t?.defaultTitle ?? widget.initialTitle ?? '',
    );
    _defaultTitleFocusNode = FocusNode();
    _defaultTitleFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _titleHasFocus = _defaultTitleFocusNode.hasFocus;
        });
      }
    });

    final contentJson = t?.contentJson ?? widget.initialContentJson;
    Document doc;
    if (contentJson != null && contentJson.isNotEmpty && contentJson != '[]') {
      try {
        final decoded = jsonDecode(contentJson);
        if (decoded is List) {
          doc = Document.fromJson(decoded);
        } else {
          doc = Document();
        }
      } catch (_) {
        doc = Document();
      }
    } else {
      doc = Document();
    }

    _quillController = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _defaultTitleController.dispose();
    _defaultTitleFocusNode.dispose();
    _quillController.dispose();
    _bodyFocusNode.dispose();
    _bodyScrollController.dispose();
    super.dispose();
  }

  void _insertToken(String token) {
    if (_titleHasFocus) {
      final currentText = _defaultTitleController.text;
      final selection = _defaultTitleController.selection;
      final start = selection.start >= 0 ? selection.start : currentText.length;
      final end = selection.end >= 0 ? selection.end : currentText.length;
      final newText = currentText.replaceRange(start, end, token);
      _defaultTitleController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + token.length),
      );
    } else {
      final index = _quillController.selection.baseOffset;
      final length = _quillController.selection.extentOffset - index;
      final actualIndex = index < 0
          ? _quillController.document.length - 1
          : index;
      _quillController.replaceText(
        actualIndex,
        length < 0 ? 0 : length,
        token,
        null,
      );
      _quillController.updateSelection(
        TextSelection.collapsed(offset: actualIndex + token.length),
        ChangeSource.local,
      );
    }
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context);
    final db = ref.read(appDatabaseProvider);

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final defaultTitle = _defaultTitleController.text.trim();
    final deltaJson = jsonEncode(_quillController.document.toDelta().toJson());

    try {
      if (widget.existingTemplate != null) {
        final existing = widget.existingTemplate!;
        await db.userTemplatesDao.updateUserTemplate(
          existing.copyWith(
            name: name,
            description: drift.Value(description.isEmpty ? null : description),
            defaultTitle: drift.Value(
              defaultTitle.isEmpty ? null : defaultTitle,
            ),
            contentJson: deltaJson,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        await db.userTemplatesDao.createUserTemplate(
          UserTemplatesCompanion.insert(
            name: name,
            description: drift.Value(description.isEmpty ? null : description),
            defaultTitle: drift.Value(
              defaultTitle.isEmpty ? null : defaultTitle,
            ),
            contentJson: deltaJson,
          ),
        );
      }

      ref.invalidate(allUserTemplatesProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.bodyTemplateSaveSuccess)));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorTemplateSave)));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.existingTemplate != null;
    final tokens = TemplateTokenEngine.getSupportedTokens(
      locale: Localizations.localeOf(context).toLanguageTag(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.actionTemplateEdit : l10n.actionTemplateCreateNew,
        ),
        actions: [
          IconButton(
            key: const Key('save-template-button'),
            icon: const Icon(Icons.check),
            tooltip: l10n.actionCommonSave,
            onPressed: _isSaving ? null : _saveTemplate,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  // Template Name
                  TextFormField(
                    key: const Key('template-name-field'),
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.labelTemplateName,
                      hintText: l10n.descTemplateName,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.errorTemplateName
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // Template Description
                  TextFormField(
                    key: const Key('template-description-field'),
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.labelTemplateDescription,
                      hintText: l10n.descTemplateDescription,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 14),

                  // Default Entry Title
                  TextFormField(
                    key: const Key('template-default-title-field'),
                    controller: _defaultTitleController,
                    focusNode: _defaultTitleFocusNode,
                    decoration: InputDecoration(
                      labelText: l10n.labelTemplateDefaultTitle,
                      hintText: l10n.descTemplateDefaultTitle,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dynamic Tokens Helper Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.titleTemplateTokens,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.descTemplateTokensHelper,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: tokens.map((t) {
                            return ActionChip(
                              key: Key(
                                'token-chip-${t.token.replaceAll(RegExp(r'[{}]'), '')}',
                              ),
                              avatar: const Icon(Icons.add, size: 14),
                              label: Text('${t.token} (${t.example})'),
                              tooltip: t.descriptionIn(l10n),
                              onPressed: () => _insertToken(t.token),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Starter Content Header
                  Text(
                    l10n.labelTemplateContent,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quill Editor toolbar & canvas
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        QuillSimpleToolbar(
                          controller: _quillController,
                          config: const QuillSimpleToolbarConfig(
                            showFontFamily: false,
                            showFontSize: false,
                            showSubscript: false,
                            showSuperscript: false,
                            showColorButton: false,
                            showBackgroundColorButton: false,
                            showAlignmentButtons: true,
                            showSearchButton: false,
                          ),
                        ),
                        const Divider(height: 1),
                        Container(
                          constraints: const BoxConstraints(minHeight: 180),
                          padding: const EdgeInsets.all(12),
                          child: () {
                            final typography = ref.watch(typographyProvider);
                            final theme = Theme.of(context);
                            final baseStyles = DefaultStyles.getInstance(
                              context,
                            );
                            final entryBodyStyle = typography.toTextStyle(
                              color: theme.colorScheme.onSurface,
                            );
                            final customStyles = baseStyles.merge(
                              DefaultStyles(
                                paragraph: DefaultTextBlockStyle(
                                  entryBodyStyle,
                                  const HorizontalSpacing(0, 0),
                                  const VerticalSpacing(0, 6),
                                  const VerticalSpacing(0, 0),
                                  null,
                                ),
                              ),
                            );

                            return DefaultTextStyle(
                              style: entryBodyStyle,
                              child: QuillEditor.basic(
                                controller: _quillController,
                                focusNode: _bodyFocusNode,
                                scrollController: _bodyScrollController,
                                config: QuillEditorConfig(
                                  placeholder: l10n.descTemplateContent,
                                  customStyles: customStyles,
                                  // Same selection aids as the entry editor:
                                  // room at the line edges and a magnifier
                                  // while a handle is dragged.
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  quillMagnifierBuilder:
                                      defaultQuillMagnifierBuilder,
                                ),
                              ),
                            );
                          }(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
