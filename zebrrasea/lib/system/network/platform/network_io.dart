import 'dart:io';

import 'package:zebrrasea/database/tables/zebrrasea.dart';
import 'package:zebrrasea/vendor.dart';

// ignore: always_use_package_imports
import '../network.dart';

bool isPlatformSupported() => true;
ZebrraNetwork getNetwork() => IO();

class IO extends HttpOverrides implements ZebrraNetwork {
  @override
  void initialize() {
    HttpOverrides.global = IO();
  }

  String generateUserAgent(PackageInfo info) {
    return '${info.appName}/${info.version} ${info.buildNumber}';
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final HttpClient client = super.createHttpClient(context);

    // Disable TLS validation
    if (!ZebrraSeaDatabase.NETWORKING_TLS_VALIDATION.read())
      client.badCertificateCallback = (cert, host, port) => true;

    // Set User-Agent
    PackageInfo.fromPlatform()
        .then((info) => client.userAgent = generateUserAgent(info))
        .catchError((_) => client.userAgent = 'ZebrraSea/Unknown');

    return client;
  }
}
