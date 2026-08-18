import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';

/// The colours a tag can be given.
///
/// These are mid-tone hues picked to stay readable as text on both a light and
/// a dark surface — light enough to read on dark, dark enough to read on light.
/// The list order is part of the contract: [colorForTag] indexes into it by a
/// hash of the tag name, so reordering would change the automatic colour of
/// every tag that has not been given one by hand.
const List<Color> kTagPalette = [
  Color(0xFFE05252), // red
  Color(0xFFE07A38), // orange
  Color(0xFFC79A1E), // amber
  Color(0xFF6FA02A), // olive
  Color(0xFF35A05C), // green
  Color(0xFF29A392), // teal
  Color(0xFF2E93C4), // cyan
  Color(0xFF4A7FD4), // blue
  Color(0xFF7B6FD8), // indigo
  Color(0xFFA45FC9), // purple
  Color(0xFFD1559B), // magenta
  Color(0xFF8A7360), // brown
];

/// Returns the colour to draw [tag] in.
///
/// If the tag has a stored colour, that wins. Otherwise a palette entry is
/// picked from a hash of the tag name, so every tag has a distinct-looking
/// colour without the user choosing one, and the same tag always looks the
/// same across screens and app restarts.
Color colorForTag(Tag tag) {
  final stored = tag.colorArgb;
  if (stored != null) return Color(stored);
  return kTagPalette[_paletteIndexForName(tag.name)];
}

/// True when [tag] has a colour the user picked, rather than the automatic one.
bool hasCustomColor(Tag tag) => tag.colorArgb != null;

/// Stable index into [kTagPalette] for a tag name.
///
/// Uses FNV-1a rather than [String.hashCode] — `hashCode` is not guaranteed to
/// be stable across Dart versions or platforms, which would silently reshuffle
/// every automatic tag colour on an upgrade.
int _paletteIndexForName(String name) {
  final normalised = name.trim().toLowerCase();
  if (normalised.isEmpty) return 0;

  var hash = 0x811c9dc5;
  for (final unit in normalised.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash % kTagPalette.length;
}
