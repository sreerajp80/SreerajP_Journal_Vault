import 'package:flutter/material.dart';

/// Approximate height of the selection popup menu, in logical pixels.
const double selectionMenuHeight = 56;

/// Keeps the selection popup menu inside the visible part of the editor.
///
/// [anchors] come from the editor: the primary anchor is the top of the
/// selection, the secondary anchor its bottom. Both are measured over the whole
/// document, so for a long selection — "Select all" above all — they can lie far
/// above or below the screen, and the menu would be drawn where nobody sees it.
///
/// [visibleTop] is the bottom edge of the formatting toolbar and
/// [visibleBottom] the top of the keyboard (or the screen bottom), both in
/// global coordinates.
///
/// - When there is room for the menu above the selection, inside the band, the
///   menu goes above it, as usual.
/// - Otherwise the menu goes below the selection's bottom; if that bottom is out
///   of view, the menu goes just under the toolbar instead. A primary anchor of
///   0 is what makes Flutter pick the "below" placement.
TextSelectionToolbarAnchors clampSelectionMenuAnchors(
  TextSelectionToolbarAnchors anchors, {
  required double visibleTop,
  required double visibleBottom,
}) {
  final primary = anchors.primaryAnchor;
  final secondary = anchors.secondaryAnchor ?? primary;
  if (visibleBottom <= visibleTop) return anchors;

  if (primary.dy >= visibleTop + selectionMenuHeight &&
      primary.dy <= visibleBottom) {
    return anchors;
  }

  final belowLimit = visibleBottom - selectionMenuHeight;
  final belowY = secondary.dy < visibleTop || secondary.dy > belowLimit
      ? visibleTop
      : secondary.dy;
  return TextSelectionToolbarAnchors(
    primaryAnchor: Offset(primary.dx, 0),
    secondaryAnchor: Offset(secondary.dx, belowY),
  );
}
