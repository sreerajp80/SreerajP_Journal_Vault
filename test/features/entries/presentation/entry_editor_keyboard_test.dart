import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/security/keyboard_privacy_scope.dart';

/// The journal editor uses a patched copy of flutter_quill
/// (third_party/flutter_quill) that adds `enableIMEPersonalizedLearning` to
/// `QuillEditorConfig`. These tests check the option reaches the keyboard,
/// and follows the "Keyboard privacy" setting the way the app wires it.
void main() {
  /// Taps the editor and returns the settings it sent to the keyboard.
  /// [privacy] null means no [KeyboardPrivacyScope] above the editor.
  Future<Map<String, dynamic>> keyboardConfig(
    WidgetTester tester, {
    required bool? privacy,
  }) async {
    final controller = QuillController.basic();
    addTearDown(controller.dispose);
    final Widget editor = Builder(
      builder: (context) => QuillEditor.basic(
        controller: controller,
        config: QuillEditorConfig(
          enableIMEPersonalizedLearning: KeyboardPrivacyScope.allowLearning(
            context,
          ),
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          FlutterQuillLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: privacy == null
              ? editor
              : KeyboardPrivacyScope(enabled: privacy, child: editor),
        ),
      ),
    );

    tester.testTextInput.log.clear();
    await tester.tap(find.byType(QuillEditor));
    await tester.pump();

    final attach = tester.testTextInput.log.lastWhere(
      (MethodCall call) => call.method == 'TextInput.setClient',
    );
    final args = attach.arguments as List<dynamic>;
    return Map<String, dynamic>.from(args[1] as Map);
  }

  testWidgets('keyboard privacy on: the keyboard is asked not to learn', (
    tester,
  ) async {
    final config = await keyboardConfig(tester, privacy: true);

    expect(config['enableIMEPersonalizedLearning'], isFalse);
    // Word suggestions still work.
    expect(config['enableSuggestions'], isTrue);
  });

  testWidgets('keyboard privacy off: the keyboard may learn', (tester) async {
    final config = await keyboardConfig(tester, privacy: false);

    expect(config['enableIMEPersonalizedLearning'], isTrue);
  });

  testWidgets('no scope above the editor counts as privacy on', (tester) async {
    final config = await keyboardConfig(tester, privacy: null);

    expect(config['enableIMEPersonalizedLearning'], isFalse);
  });
}
