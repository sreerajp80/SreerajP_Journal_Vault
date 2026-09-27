import 'package:flutter/widgets.dart';

// Layer: core (security, widget glue).
//
// Carries the keyboard privacy choice down to every text box, pages and
// dialogs alike. `JournalVaultApp` puts it around the navigator in
// `MaterialApp.builder`.

/// Tells text boxes below it whether the keyboard may learn from them.
class KeyboardPrivacyScope extends InheritedWidget {
  const KeyboardPrivacyScope({
    super.key,
    required this.enabled,
    required super.child,
  });

  /// `true` when keyboard privacy is on: the keyboard must not learn.
  final bool enabled;

  /// The value for a text box's `enableIMEPersonalizedLearning`.
  ///
  /// `false` (do not learn) while keyboard privacy is on, and also when there
  /// is no scope above [context] — privacy is the safe default.
  static bool allowLearning(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<KeyboardPrivacyScope>();
    return !(scope?.enabled ?? true);
  }

  @override
  bool updateShouldNotify(KeyboardPrivacyScope oldWidget) =>
      enabled != oldWidget.enabled;
}
