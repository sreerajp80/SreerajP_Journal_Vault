/// Turns a self-contained HTML page into PDF bytes using a native, on-window
/// web view (see the Android `JvHtmlToPdf` class).
///
/// **Why a native web view and not a Dart PDF package.** Malayalam — and any
/// complex script — needs real text shaping: chillu, conjuncts, and vowel signs
/// that reorder around the consonant. The platform web view does that shaping
/// properly and keeps the text real and selectable in the PDF. A Dart PDF
/// library would need the shaping implemented on top of it, and the app family
/// already has this route working (`SreerajP_lyricchord` §2.9), so it is ported
/// rather than redesigned.
///
/// It also adds no package dependency, which matters here: this app's
/// `pubspec.yaml` already carries a documented `win32` / `file_picker` version
/// knot that a new PDF or printing package could easily tighten.
///
/// The native side deliberately does **not** use `Printing.convertHtml`, whose
/// hidden, unattached web view hangs forever on newer Android. `JvHtmlToPdf`
/// attaches the web view to the window (off-screen), so the print callbacks
/// fire and a real PDF comes back.
///
/// Fully offline: the native side loads only the local HTML passed in and
/// blocks all network loading in the web view. No URL is ever fetched.
///
/// Output only — no UI, no navigation. It talks to the platform over a single
/// method channel and returns bytes; the caller decides what to do with them.
library;

import 'package:flutter/services.dart';

/// Why a PDF could not be produced. The screen turns this into text in the
/// user's language (`presentation/export_text.dart`).
enum HtmlPdfFailure { timedOut, failed, unavailable }

/// Thrown when the native renderer cannot produce a PDF, including when the
/// platform has no implementation at all (iOS today).
class HtmlPdfException implements Exception {
  const HtmlPdfException(this.failure, {this.isUnsupportedPlatform = false});

  final HtmlPdfFailure failure;

  /// True when this platform has no native renderer, rather than the render
  /// having failed. The screen uses this to disable the PDF option up front
  /// instead of letting the user tap a button that cannot work
  /// (`SreerajP_PDFApp` rule 6 — never a dead button).
  final bool isUnsupportedPlatform;

  @override
  String toString() => 'HtmlPdfException: ${failure.name}';
}

/// Converts HTML to PDF bytes over the `sreerajp.journal_vault/html_pdf`
/// method channel.
class HtmlPdfService {
  const HtmlPdfService({this._channel = _defaultChannel});

  // Matches the naming the app's other four channels already use — see the
  // channel constants at the foot of MainActivity.kt.
  static const MethodChannel _defaultChannel = MethodChannel(
    'sreerajp.journal_vault/html_pdf',
  );

  /// Injectable so a test can drive the service without a device.
  final MethodChannel _channel;

  /// A4 in PostScript points (1/72 inch), with a 20 mm margin.
  ///
  /// Unlike the lyricchord original, the page size here is fixed. That version
  /// measured the widest line of a song sheet and picked a page width to match,
  /// which is a song-sheet trick — a journal page is a page of prose and wants
  /// ordinary paper.
  static const double _widthPts = 595.28;
  static const double _heightPts = 841.89;
  static const double _marginPts = 56.7; // 20 mm

  /// Renders [html] to PDF bytes.
  ///
  /// [timeout] is passed to the native side as a hard limit, and applied again
  /// here as a backstop, so a stuck render always fails with a message and can
  /// never hang the app.
  ///
  /// Throws [HtmlPdfException] on any failure.
  Future<Uint8List> convert({
    required String html,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      final bytes = await _channel
          .invokeMethod<Uint8List>('convertHtml', <String, dynamic>{
            'html': html,
            'widthPts': _widthPts,
            'heightPts': _heightPts,
            'marginPts': _marginPts,
            'timeoutMs': timeout.inMilliseconds,
          })
          .timeout(
            // A little longer than the native limit, so the native side's own
            // error message wins when it is the one that gives up first.
            timeout + const Duration(seconds: 5),
            onTimeout: () =>
                throw const HtmlPdfException(HtmlPdfFailure.timedOut),
          );

      if (bytes == null || bytes.isEmpty) {
        throw const HtmlPdfException(HtmlPdfFailure.failed);
      }
      return bytes;
    } on MissingPluginException {
      // No native implementation on this platform (iOS today).
      throw const HtmlPdfException(
        HtmlPdfFailure.unavailable,
        isUnsupportedPlatform: true,
      );
    } on PlatformException catch (error) {
      // The native message can name a file path, so it is not shown to the
      // user; the code is enough to tell a timeout from a failure.
      throw HtmlPdfException(
        error.code == 'timeout'
            ? HtmlPdfFailure.timedOut
            : HtmlPdfFailure.failed,
      );
    }
  }

  /// Whether this device has the native renderer.
  ///
  /// Called before the format list is built, so PDF can be shown as
  /// unavailable rather than failing after the user has chosen it.
  Future<bool> isAvailable() async {
    try {
      final available = await _channel.invokeMethod<bool>('isAvailable');
      return available ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
