import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

extension SonarrCalendarExtension on SonarrCalendar {
  String get zebrraAirTime {
    if (this.airDateUtc != null)
      return ZebrraSeaDatabase.USE_24_HOUR_TIME.read()
          ? DateFormat.Hm().format(this.airDateUtc!.toLocal())
          : DateFormat('hh:mm\na').format(this.airDateUtc!.toLocal());
    return ZebrraUI.TEXT_EMDASH;
  }

  bool get zebrraHasAired {
    if (this.airDateUtc != null)
      return DateTime.now().isAfter(this.airDateUtc!.toLocal());
    return false;
  }
}
