#!/bin/sh
#
# Keeps every text box under the user's "Keyboard privacy" setting.
#
# Android lets an app ask the keyboard not to learn from a text box (the
# "incognito" request). Trusted keyboards respect it, so journal text never
# lands in the keyboard's personal dictionary or suggestion history. The app
# sends it while the "Keyboard privacy" switch in Settings is on (the default).
#
# What it enforces:
#   1. Every TextField( and TextFormField( in lib/ passes
#      enableIMEPersonalizedLearning: KeyboardPrivacyScope.allowLearning(...)
#      within its first few lines.
#   2. Every QuillEditorConfig( in lib/ does the same.
#   3. The patched copy of flutter_quill in third_party/ still passes the
#      option to the keyboard, and pubspec.yaml still points to it.
#
# Usage:
#   sh tool/check_keyboard_incognito.sh
#
# Exits 0 when every rule holds, 1 on any failure.

set -u

QUILL_MIXIN="third_party/flutter_quill/lib/src/editor/raw_editor/raw_editor_state_text_input_client_mixin.dart"
QUILL_CONFIG="third_party/flutter_quill/lib/src/editor/config/editor_config.dart"
PUBSPEC="pubspec.yaml"

FAILED=0

echo "Checking text boxes and editors in lib/ follow keyboard privacy..."

# Prints file:line for each TextField(, TextFormField( or QuillEditorConfig(
# whose next few lines do not pass the scope value. `dart format` may split
# the argument over several lines, so the lines are joined before matching.
# Comment lines are skipped.
missing=$(find lib -name '*.dart' ! -name '*.g.dart' | sort | while read -r file; do
  awk -v file="$file" '
    { lines[NR] = $0 }
    END {
      for (i = 1; i <= NR; i++) {
        line = lines[i]
        if (line ~ /^[ \t]*\/\//) continue
        if (line !~ /(^|[^A-Za-z0-9_])(TextField|TextFormField|QuillEditorConfig)\(/) continue
        joined = ""
        for (j = i; j <= i + 6 && j <= NR; j++) joined = joined " " lines[j]
        gsub(/[ \t]+/, " ", joined)
        if (joined !~ /enableIMEPersonalizedLearning: ?KeyboardPrivacyScope\.allowLearning\(/) {
          print file ":" i
        }
      }
    }
  ' "$file"
done)

if [ -n "$missing" ]; then
  echo "  [ERROR] These do not pass 'enableIMEPersonalizedLearning: KeyboardPrivacyScope.allowLearning(context)':" >&2
  echo "$missing" | sed 's/^/    /' >&2
  FAILED=1
else
  echo "  [OK] Every TextField, TextFormField and QuillEditorConfig follows the setting"
fi

echo "Checking the patched flutter_quill editor..."

if [ ! -f "$QUILL_MIXIN" ] || [ ! -f "$QUILL_CONFIG" ]; then
  echo "  [ERROR] The patched flutter_quill copy in third_party/flutter_quill is missing" >&2
  FAILED=1
else
  if tr '\n' ' ' < "$QUILL_MIXIN" | tr -s ' ' |
    grep -q "enableIMEPersonalizedLearning: widget.config.enableIMEPersonalizedLearning"; then
    echo "  [OK] The editor passes the option to the keyboard"
  else
    echo "  [ERROR] $QUILL_MIXIN no longer passes enableIMEPersonalizedLearning to the keyboard" >&2
    FAILED=1
  fi
  if grep -q "final bool enableIMEPersonalizedLearning;" "$QUILL_CONFIG"; then
    echo "  [OK] QuillEditorConfig has the enableIMEPersonalizedLearning option"
  else
    echo "  [ERROR] $QUILL_CONFIG no longer has the enableIMEPersonalizedLearning option" >&2
    FAILED=1
  fi
fi

if ! grep -q "path: third_party/flutter_quill" "$PUBSPEC"; then
  echo "  [ERROR] $PUBSPEC no longer overrides flutter_quill with third_party/flutter_quill" >&2
  FAILED=1
else
  echo "  [OK] $PUBSPEC uses the patched flutter_quill"
fi

if [ "$FAILED" -ne 0 ]; then
  echo "Keyboard privacy check failed." >&2
  exit 1
fi

echo "Keyboard privacy check passed."
exit 0
