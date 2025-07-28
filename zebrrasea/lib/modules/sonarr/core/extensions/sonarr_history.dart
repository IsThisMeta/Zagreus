import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

extension SonarrHistoryRecordZebrraExtension on SonarrHistoryRecord {
  String zebrraSeriesTitle() {
    return this.series?.title ?? ZebrraUI.TEXT_EMDASH;
  }

  String? zebrraSeasonEpisode() {
    if (this.episode == null) return null;
    String season = this.episode?.seasonNumber != null
        ? 'sonarr.SeasonNumber'.tr(
            args: [this.episode!.seasonNumber.toString()],
          )
        : 'zebrrasea.Unknown'.tr();
    String episode = this.episode?.episodeNumber != null
        ? 'sonarr.EpisodeNumber'.tr(
            args: [this.episode!.episodeNumber.toString()],
          )
        : 'zebrrasea.Unknown'.tr();
    return '$season ${ZebrraUI.TEXT_BULLET} $episode';
  }

  bool zebrraHasPreferredWordScore() {
    return (this.data!['preferredWordScore'] ?? '0') != '0';
  }

  String zebrraPreferredWordScore() {
    if (zebrraHasPreferredWordScore()) {
      int? _preferredScore = int.tryParse(this.data!['preferredWordScore']);
      if (_preferredScore != null) {
        String _prefix = _preferredScore > 0 ? '+' : '';
        return '$_prefix${this.data!['preferredWordScore']}';
      }
    }
    return ZebrraUI.TEXT_EMDASH;
  }
}
