import 'package:flutter/material.dart';
import 'package:zebrrasea/system/environment.dart';
import 'package:zebrrasea/vendor.dart';
import 'package:zebrrasea/widgets/ui.dart';

const FLAVOR_EDGE = 'edge';
const FLAVOR_BETA = 'beta';
const FLAVOR_STABLE = 'stable';

enum ZebrraFlavor {
  EDGE(FLAVOR_EDGE),
  BETA(FLAVOR_BETA),
  STABLE(FLAVOR_STABLE);

  final String key;
  const ZebrraFlavor(this.key);

  static ZebrraFlavor fromKey(String key) {
    switch (key) {
      case FLAVOR_EDGE:
        return ZebrraFlavor.EDGE;
      case FLAVOR_BETA:
        return ZebrraFlavor.BETA;
      case FLAVOR_STABLE:
        return ZebrraFlavor.STABLE;
    }
    throw Exception('Invalid ZebrraFlavor');
  }

  static ZebrraFlavor get current => ZebrraFlavor.fromKey(ZebrraEnvironment.flavor);

  static bool get isEdge => current == ZebrraFlavor.EDGE;
  static bool get isBeta => current == ZebrraFlavor.BETA;
  static bool get isStable => current == ZebrraFlavor.STABLE;
}

extension ZebrraFlavorExtension on ZebrraFlavor {
  bool isRunningFlavor() {
    ZebrraFlavor flavor = ZebrraFlavor.current;
    if (flavor == this) return true;

    switch (this) {
      case ZebrraFlavor.EDGE:
        return false;
      case ZebrraFlavor.BETA:
        return flavor == ZebrraFlavor.EDGE;
      case ZebrraFlavor.STABLE:
        return true;
    }
  }

  String get downloadLink {
    String base = 'https://builds.zebrrasea.app/#latest';
    switch (this) {
      case ZebrraFlavor.EDGE:
        return '$base/${this.key}/';
      case ZebrraFlavor.BETA:
        return '$base/${this.key}/';
      case ZebrraFlavor.STABLE:
        return '$base/${this.key}/';
    }
  }

  String get name {
    switch (this) {
      case ZebrraFlavor.EDGE:
        return 'zebrrasea.Edge'.tr();
      case ZebrraFlavor.BETA:
        return 'zebrrasea.Beta'.tr();
      case ZebrraFlavor.STABLE:
        return 'zebrrasea.Stable'.tr();
    }
  }

  Color get color {
    switch (this) {
      case ZebrraFlavor.EDGE:
        return ZebrraColours.red;
      case ZebrraFlavor.BETA:
        return ZebrraColours.blue;
      case ZebrraFlavor.STABLE:
        return ZebrraColours.accent;
    }
  }
}
