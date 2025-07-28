import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

extension ZebrraSonarrProtocolExtension on SonarrProtocol {
  Color zebrraProtocolColor({
    SonarrRelease? release,
  }) {
    if (this == SonarrProtocol.USENET) return ZebrraColours.accent;
    if (release == null) return ZebrraColours.blue;

    int seeders = release.seeders ?? 0;
    if (seeders > 10) return ZebrraColours.blue;
    if (seeders > 0) return ZebrraColours.orange;
    return ZebrraColours.red;
  }

  String zebrraReadable() {
    switch (this) {
      case SonarrProtocol.USENET:
        return 'sonarr.Usenet'.tr();
      case SonarrProtocol.TORRENT:
        return 'sonarr.Torrent'.tr();
    }
  }
}
