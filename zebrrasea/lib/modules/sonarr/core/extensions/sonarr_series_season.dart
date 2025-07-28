import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

extension SonarrSeriesSeasonExtension on SonarrSeriesSeason {
  String get zebrraTitle {
    if (this.seasonNumber == 0) return 'sonarr.Specials'.tr();
    return 'sonarr.SeasonNumber'.tr(args: [
      this.seasonNumber?.toString() ?? 'zebrrasea.Unknown'.tr(),
    ]);
  }

  int get zebrraPercentageComplete {
    int _total = this.statistics?.episodeCount ?? 0;
    int _available = this.statistics?.episodeFileCount ?? 0;
    return _total == 0 ? 0 : ((_available / _total) * 100).round();
  }

  String get zebrraEpisodesAvailable {
    return '${this.statistics?.episodeFileCount ?? 0}/${this.statistics?.episodeCount ?? 0}';
  }
}
