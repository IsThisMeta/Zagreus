import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/modules/radarr.dart';

extension ZebrraRadarrDiskSpaceExtension on RadarrDiskSpace {
  String? get zebrraPath {
    if (this.path != null && this.path!.isNotEmpty) return this.path;
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraSpace {
    String numerator = this.freeSpace.asBytes();
    String denumerator = this.totalSpace.asBytes();
    return '$numerator / $denumerator\n';
  }

  int get zebrraPercentage {
    int? _percentNumerator = this.freeSpace;
    int? _percentDenominator = this.totalSpace;
    if (_percentNumerator != null &&
        _percentDenominator != null &&
        _percentDenominator != 0) {
      int _val = ((_percentNumerator / _percentDenominator) * 100).round();
      return (_val - 100).abs();
    }
    return 0;
  }

  String get zebrraPercentageString => '$zebrraPercentage%';

  Color get zebrraColor {
    int percentage = this.zebrraPercentage;
    if (percentage >= 90) return ZebrraColours.red;
    if (percentage >= 80) return ZebrraColours.orange;
    return ZebrraColours.accent;
  }
}
