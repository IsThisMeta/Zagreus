import 'package:zebrrasea/database/tables/zebrrasea.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/vendor.dart';
import 'package:zebrrasea/widgets/ui.dart';

extension DateTimeExtension on DateTime {
  String _formatted(String format) {
    return DateFormat(format, 'en').format(this.toLocal());
  }

  DateTime floor() {
    return DateTime(this.year, this.month, this.day);
  }

  String asTimeOnly() {
    if (ZebrraSeaDatabase.USE_24_HOUR_TIME.read()) return _formatted('Hm');
    return _formatted('jm');
  }

  String asDateOnly({
    shortenMonth = false,
  }) {
    final format = shortenMonth ? 'MMM dd, y' : 'MMMM dd, y';
    return _formatted(format);
  }

  String asDateTime({
    bool showSeconds = true,
    bool shortenMonth = false,
    String? delimiter,
  }) {
    final format = StringBuffer(shortenMonth ? 'MMM dd, y' : 'MMMM dd, y');
    format.write(delimiter ?? ZebrraUI.TEXT_BULLET.pad());
    format.write(ZebrraSeaDatabase.USE_24_HOUR_TIME.read() ? 'HH:mm' : 'hh:mm');
    if (showSeconds) format.write(':ss');
    if (!ZebrraSeaDatabase.USE_24_HOUR_TIME.read()) format.write(' a');

    return _formatted(format.toString());
  }

  String asPoleDate() {
    final year = this.year.toString().padLeft(4, '0');
    final month = this.month.toString().padLeft(2, '0');
    final day = this.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String asAge() {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 15) return 'zebrrasea.JustNow'.tr();

    final days = diff.inDays.abs();
    if (days >= 1) {
      final years = (days / 365).floor();
      if (years == 1) return 'zebrrasea.OneYearAgo'.tr();
      if (years > 1) return 'zebrrasea.YearsAgo'.tr(args: [years.toString()]);

      final months = (days / 30).floor();
      if (months == 1) return 'zebrrasea.OneMonthAgo'.tr();
      if (months > 1) return 'zebrrasea.MonthsAgo'.tr(args: [months.toString()]);

      if (days == 1) return 'zebrrasea.OneDayAgo'.tr();
      if (days > 1) return 'zebrrasea.DaysAgo'.tr(args: [days.toString()]);
    }

    final hours = diff.inHours.abs();
    if (hours == 1) return 'zebrrasea.OneHourAgo'.tr();
    if (hours > 1) return 'zebrrasea.HoursAgo'.tr(args: [hours.toString()]);

    final mins = diff.inMinutes.abs();
    if (mins == 1) return 'zebrrasea.OneMinuteAgo'.tr();
    if (mins > 1) return 'zebrrasea.MinutesAgo'.tr(args: [mins.toString()]);

    final secs = diff.inSeconds.abs();
    if (secs == 1) return 'zebrrasea.OneSecondAgo'.tr();
    return 'zebrrasea.SecondsAgo'.tr(args: [secs.toString()]);
  }

  String asDaysDifference() {
    final diff = DateTime.now().difference(this);
    final days = diff.inDays.abs();
    if (days == 0) return 'zebrrasea.Today'.tr();

    final years = (days / 365).floor();
    if (years == 1) return 'zebrrasea.OneYear'.tr();
    if (years > 1) return 'zebrrasea.Years'.tr(args: [years.toString()]);

    final months = (days / 30).floor();
    if (months == 1) return 'zebrrasea.OneMonth'.tr();
    if (months > 1) return 'zebrrasea.Months'.tr(args: [months.toString()]);

    if (days == 1) return 'zebrrasea.OneDay'.tr();
    return 'zebrrasea.Days'.tr(args: [days.toString()]);
  }
}
