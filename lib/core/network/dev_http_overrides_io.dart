import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;

/// Many Android emulator system images ship with an outdated/incomplete
/// root CA store, so HTTPS handshakes to Supabase fail with
/// `CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate`
/// even though the certificate chain is actually valid. Debug-only and
/// Android-only: relax certificate verification so local development on
/// those emulators isn't blocked. `kDebugMode` is compiled to `false` in
/// release builds, so this never runs there.
void configureDevHttpOverrides() {
  if (!kDebugMode) return;
  if (!Platform.isAndroid) return;

  HttpOverrides.global = _DevAndroidHttpOverrides();
}

class _DevAndroidHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
