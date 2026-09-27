import 'package:flutter/widgets.dart';

/// Room for the system navigation bar at the bottom of a screen.
///
/// On Android 15+ the app is always drawn edge-to-edge: the navigation bar
/// (back / home / recents, or the gesture pill) sits on top of the app, and
/// the app has to leave room for it. A `ListView` adds that room by itself only
/// when it has no `padding:`; once a screen sets its own padding, nothing is
/// added and the last item stops under the bar.
///
/// [withSafeBottom] adds the bar's height to the bottom of a padding, so the
/// content still scrolls behind the bar but can be scrolled clear of it. It
/// adds 0 where there is nothing to clear: inside the main tab shell (its
/// `NavigationBar` already takes the space), and while the keyboard is open
/// (the keyboard covers the navigation bar).
extension SafeBottomInsets on EdgeInsets {
  EdgeInsets withSafeBottom(BuildContext context) =>
      copyWith(bottom: bottom + MediaQuery.paddingOf(context).bottom);
}
