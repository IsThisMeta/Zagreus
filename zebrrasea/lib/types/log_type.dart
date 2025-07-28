import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/system/flavor.dart';

part 'log_type.g.dart';

const TYPE_DEBUG = 'debug';
const TYPE_WARNING = 'warning';
const TYPE_ERROR = 'error';
const TYPE_CRITICAL = 'critical';

@HiveType(typeId: 24, adapterName: 'ZebrraLogTypeAdapter')
enum ZebrraLogType {
  @HiveField(0)
  WARNING(TYPE_WARNING),
  @HiveField(1)
  ERROR(TYPE_ERROR),
  @HiveField(2)
  CRITICAL(TYPE_CRITICAL),
  @HiveField(3)
  DEBUG(TYPE_DEBUG);

  final String key;
  const ZebrraLogType(this.key);

  String get description => 'settings.ViewTypeLogs'.tr(args: [title]);

  bool get enabled {
    switch (this) {
      case ZebrraLogType.DEBUG:
        return ZebrraFlavor.BETA.isRunningFlavor();
      default:
        return true;
    }
  }

  String get title {
    switch (this) {
      case ZebrraLogType.WARNING:
        return 'zebrrasea.Warning'.tr();
      case ZebrraLogType.ERROR:
        return 'zebrrasea.Error'.tr();
      case ZebrraLogType.CRITICAL:
        return 'zebrrasea.Critical'.tr();
      case ZebrraLogType.DEBUG:
        return 'zebrrasea.Debug'.tr();
    }
  }

  IconData get icon {
    switch (this) {
      case ZebrraLogType.WARNING:
        return ZebrraIcons.WARNING;
      case ZebrraLogType.ERROR:
        return ZebrraIcons.ERROR;
      case ZebrraLogType.CRITICAL:
        return ZebrraIcons.CRITICAL;
      case ZebrraLogType.DEBUG:
        return ZebrraIcons.DEBUG;
    }
  }

  Color get color {
    switch (this) {
      case ZebrraLogType.WARNING:
        return ZebrraColours.orange;
      case ZebrraLogType.ERROR:
        return ZebrraColours.red;
      case ZebrraLogType.CRITICAL:
        return ZebrraColours.accent;
      case ZebrraLogType.DEBUG:
        return ZebrraColours.blueGrey;
    }
  }

  static ZebrraLogType? fromKey(String key) {
    switch (key) {
      case TYPE_WARNING:
        return ZebrraLogType.WARNING;
      case TYPE_ERROR:
        return ZebrraLogType.ERROR;
      case TYPE_CRITICAL:
        return ZebrraLogType.CRITICAL;
      case TYPE_DEBUG:
        return ZebrraLogType.DEBUG;
    }
    return null;
  }
}
