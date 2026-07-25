# R8 / ProGuard keep rules
#
# Required by security.md section 8.2 and flutter_build_flavors_guide.md.
#
# R8 full mode is the default on AGP 8.x. It strips classes reached only by
# reflection or by the method-channel bridge, producing ClassNotFoundException
# at runtime in RELEASE builds only. Keep rules are what prevent that.
#
# The Dart layer compiles to native AOT code and is NOT subject to R8. Only the
# native Android side matters here.

# --- Flutter engine: always required ---
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# --- This app's own native code ---
# MainActivity hosts every MethodChannel (attachment keys, attachment storage,
# journal lock, app PIN lock, runtime environment). Reached from Dart by name.
-keep class in.sreerajp.sreerajp_journal_vault.** { *; }

# --- androidx components used directly by MainActivity ---
# DocumentFile drives SAF-backed SD-card attachment storage.
-keep class androidx.documentfile.** { *; }

# --- Cryptography ---
# Keystore and JCE providers are resolved by string name at runtime.
-keep class android.security.keystore.** { *; }
-keep class javax.crypto.** { *; }

# --- Play Core: referenced by the engine, not used by this app ---
# The Flutter engine ships PlayStoreDeferredComponentManager and
# FlutterPlayStoreSplitApplication, which reference com.google.android.play.core.
# This app does not use Play Feature Delivery or deferred components, so those
# classes are absent and R8 fails the build unless told they are optional.
# Verified 2026-07-25: the first R8 run failed on exactly these 11 classes.
-dontwarn com.google.android.play.core.**

# Suppress warnings for optional dependencies that are not present at runtime.
-dontwarn javax.annotation.**

# NOTE: R8 was enabled for the first time on 2026-07-25. These rules cover the
# engine, this app's channels, and the crypto path. Plugins with native Android
# code (syncfusion_flutter_pdfviewer, just_audio, record, speech_to_text,
# local_auth, permission_handler, file_picker) have not been exercised in a
# release build on a device. Per release_process.md, smoke-test PDF viewing,
# audio playback, voice recording, biometric unlock, and file picking on a real
# release build before distributing. Add package-specific keep rules from each
# package's own documentation if any of those fail.
