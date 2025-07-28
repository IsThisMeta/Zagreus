import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

extension ZebrraRadarrHealthCheckTypeExtension on RadarrHealthCheckType? {
  Color get zebrraColour {
    switch (this) {
      case RadarrHealthCheckType.NOTICE:
        return ZebrraColours.blue;
      case RadarrHealthCheckType.WARNING:
        return ZebrraColours.orange;
      case RadarrHealthCheckType.ERROR:
        return ZebrraColours.red;
      default:
        return Colors.white;
    }
  }
}
