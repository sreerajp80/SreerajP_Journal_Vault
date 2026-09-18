import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

// Layer: presentation. Shows the text read from the edited photo, on demand.
//
// Reading text is slow, so the enhance screen no longer does it after every
// image change. This sheet asks for it once, when the user wants to see it,
// through [OcrTextPreviewSheet.readText]. It calls no service itself.

/// Bottom sheet that reads and shows the text in the current photo.
///
/// Pops with the text when the user taps insert, or with `null` when closed.
class OcrTextPreviewSheet extends StatefulWidget {
  const OcrTextPreviewSheet({
    super.key,
    required this.initialLanguage,
    required this.readText,
    required this.onLanguageChanged,
    required this.onClosedWhileReading,
  });

  /// Language code the sheet starts with: `eng+mal`, `mal` or `eng`.
  final String initialLanguage;

  /// Reads the text of the current photo in the given language. Returns `null`
  /// when the result is out of date (the run was cancelled or replaced).
  final Future<String?> Function(String language) readText;

  /// Called when the user picks a different language.
  final ValueChanged<String> onLanguageChanged;

  /// Called when the sheet closes while text is still being read, so that
  /// run can be cancelled.
  final VoidCallback onClosedWhileReading;

  @override
  State<OcrTextPreviewSheet> createState() => _OcrTextPreviewSheetState();
}

class _OcrTextPreviewSheetState extends State<OcrTextPreviewSheet> {
  late String _language;
  bool _isReading = true;
  bool _failed = false;
  String _text = '';

  /// Only the newest read may update the sheet.
  int _readGeneration = 0;

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _read();
  }

  @override
  void dispose() {
    if (_isReading) widget.onClosedWhileReading();
    super.dispose();
  }

  Future<void> _read() async {
    final generation = ++_readGeneration;
    void reset() {
      _isReading = true;
      _failed = false;
      _text = '';
    }

    // The first read starts from initState, where the fields are simply set.
    generation == 1 ? reset() : setState(reset);

    String? text;
    var failed = false;
    try {
      text = await widget.readText(_language);
    } catch (_) {
      // The screen has already logged the failure.
      failed = true;
    }

    if (!mounted || generation != _readGeneration) return;
    // A `null` result was cancelled elsewhere; show it as "no text" rather
    // than leaving the spinner running.
    setState(() {
      _isReading = false;
      _failed = failed;
      _text = text ?? '';
    });
  }

  void _onLanguageSelected(String language) {
    if (language == _language) return;
    HapticFeedback.selectionClick();
    _language = language;
    widget.onLanguageChanged(language);
    _read();
  }

  int get _wordCount =>
      _text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(l10n),
              const SizedBox(height: 12),
              Flexible(child: _buildBody(l10n)),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('ocr-preview-insert-btn'),
                onPressed: _isReading || _text.isEmpty
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop(_text);
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.check, size: 20),
                label: Text(
                  l10n.actionOcrEnhanceInsertText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        Icon(
          Icons.document_scanner_outlined,
          size: 18,
          color: _text.isNotEmpty ? Colors.amber : Colors.white70,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.titleOcrEnhanceLiveText,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildLanguageSelector(l10n),
        if (!_isReading && _text.isNotEmpty) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.descOcrEnhanceLiveWordCount(_wordCount),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        IconButton(
          key: const Key('ocr-preview-close-btn'),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isReading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.amber),
            const SizedBox(height: 12),
            Text(
              l10n.bodyOcrEnhanceLiveScanning,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_failed || _text.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          _failed ? l10n.errorEntryEditorOcr : l10n.bodyOcrEnhanceLiveTextNone,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: SelectableText(
        _text,
        key: const Key('ocr-live-text-content'),
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildLanguageSelector(AppLocalizations l10n) {
    Widget item(String value, String label) {
      final selected = _language == value;
      return Text(
        label,
        style: TextStyle(
          color: selected ? Colors.amber : Colors.white,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }

    return PopupMenuButton<String>(
      key: const Key('ocr-language-selector'),
      tooltip: l10n.tooltipOcrLanguageSelect,
      initialValue: _language,
      onSelected: _onLanguageSelected,
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 13, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              _languageLabel(l10n, _language),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 14, color: Colors.white70),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'eng+mal',
          child: item('eng+mal', l10n.labelOcrLanguageAll),
        ),
        PopupMenuItem(
          value: 'mal',
          child: item('mal', l10n.labelOcrLanguageMalayalam),
        ),
        PopupMenuItem(
          value: 'eng',
          child: item('eng', l10n.labelOcrLanguageEnglish),
        ),
      ],
    );
  }

  String _languageLabel(AppLocalizations l10n, String language) {
    switch (language) {
      case 'mal':
        return l10n.labelOcrLanguageMalayalam;
      case 'eng':
        return l10n.labelOcrLanguageEnglish;
      case 'eng+mal':
      default:
        return l10n.labelOcrLanguageAll;
    }
  }
}
