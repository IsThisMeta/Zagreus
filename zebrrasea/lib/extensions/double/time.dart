import 'package:zebrrasea/core.dart';

extension DoubleAsTimeExtension on double? {
  String asTimeAgo() {
    if (this == null || this! < 0) return ZebrraUI.TEXT_EMDASH;

    double hours = this!;
    double minutes = (this! * 60);
    double days = (this! / 24);

    if (minutes <= 2) {
      return 'zebrrasea.JustNow'.tr();
    }

    if (minutes <= 120) {
      return 'zebrrasea.MinutesAgo'.tr(args: [minutes.round().toString()]);
    }

    if (hours <= 48) {
      return 'zebrrasea.HoursAgo'.tr(args: [hours.toStringAsFixed(1)]);
    }

    return 'zebrrasea.DaysAgo'.tr(args: [days.round().toString()]);
  }
}
