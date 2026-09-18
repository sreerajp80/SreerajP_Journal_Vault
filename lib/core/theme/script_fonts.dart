// Layer: core (theme).
//
// Malayalam and Devanagari glyphs are not guaranteed on every device, and a
// missing glyph renders as an empty box. Both scripts are bundled (see the
// `fonts:` section of pubspec.yaml) and used as a fallback after the platform
// font, so Latin text keeps the system look. Engineering standard §8.3.3.

/// `ThemeData.fontFamilyFallback` for every theme in the app.
const List<String> appScriptFontFallback = [
  'NotoSansMalayalam',
  'NotoSansDevanagari',
];
