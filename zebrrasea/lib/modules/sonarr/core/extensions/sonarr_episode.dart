import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/modules/sonarr.dart';

extension SonarrEpisodeExtension on SonarrEpisode {
  bool _hasAired() {
    return this.airDateUtc?.toLocal().isAfter(DateTime.now()) ?? true;
  }

  /// Creates a clone of the [SonarrEpisode] object (deep copy).
  SonarrEpisode clone() => SonarrEpisode.fromJson(this.toJson());

  String zebrraAirDate() {
    if (this.airDateUtc == null) return 'zebrrasea.UnknownDate'.tr();
    return DateFormat.yMMMMd().format(this.airDateUtc!.toLocal());
  }

  String zebrraDownloadedQuality(
    SonarrEpisodeFile? file,
    SonarrQueueRecord? queueRecord,
  ) {
    if (queueRecord != null) {
      return [
        queueRecord.zebrraPercentage(),
        ZebrraUI.TEXT_EMDASH,
        queueRecord.zebrraStatusParameters().item1,
      ].join(' ');
    }

    if (!this.hasFile!) {
      if (_hasAired()) return 'sonarr.Unaired'.tr();
      return 'sonarr.Missing'.tr();
    }
    if (file == null) return 'zebrrasea.Unknown'.tr();
    String quality = file.quality?.quality?.name ?? 'zebrrasea.Unknown'.tr();
    String size = file.size?.asBytes() ?? '0.00 B';
    return '$quality ${ZebrraUI.TEXT_EMDASH} $size';
  }

  Color zebrraDownloadedQualityColor(
    SonarrEpisodeFile? file,
    SonarrQueueRecord? queueRecord,
  ) {
    if (queueRecord != null) {
      return queueRecord.zebrraStatusParameters(canBeWhite: false).item3;
    }

    if (!this.hasFile!) {
      if (_hasAired()) return ZebrraColours.blue;
      return ZebrraColours.red;
    }
    if (file == null) return ZebrraColours.blueGrey;
    if (file.qualityCutoffNotMet!) return ZebrraColours.orange;
    return ZebrraColours.accent;
  }

  String zebrraSeasonEpisode() {
    String season = this.seasonNumber != null
        ? 'sonarr.SeasonNumber'.tr(
            args: [this.seasonNumber.toString()],
          )
        : 'zebrrasea.Unknown'.tr();
    String episode = this.episodeNumber != null
        ? 'sonarr.EpisodeNumber'.tr(
            args: [this.episodeNumber.toString()],
          )
        : 'zebrrasea.Unknown'.tr();
    return '$season ${ZebrraUI.TEXT_BULLET} $episode';
  }
}
