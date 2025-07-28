import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/datetime.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/extensions/int/duration.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/sonarr.dart';

extension SonarrSeriesExtension on SonarrSeries {
  String get zebrraRuntime {
    return this.runtime.asVideoDuration();
  }

  String get zebrraAlternateTitles {
    if (this.alternateTitles?.isNotEmpty ?? false) {
      return this.alternateTitles!.map((title) => title.title).join('\n');
    }
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraGenres {
    if (this.genres?.isNotEmpty ?? false) return this.genres!.join('\n');
    return ZebrraUI.TEXT_EMDASH;
  }

  String get zebrraNetwork {
    if (this.network?.isNotEmpty ?? false) return this.network!;
    return ZebrraUI.TEXT_EMDASH;
  }

  String zebrraTags(List<SonarrTag> tags) {
    if (tags.isNotEmpty) return tags.map<String>((t) => t.label!).join('\n');
    return ZebrraUI.TEXT_EMDASH;
  }

  int get zebrraPercentageComplete {
    int _total = this.statistics?.episodeCount ?? 0;
    int _available = this.statistics?.episodeFileCount ?? 0;
    return _total == 0 ? 0 : ((_available / _total) * 100).round();
  }

  String zebrraNextAiring([bool short = false]) {
    if (this.status == 'ended') return 'sonarr.SeriesEnded'.tr();
    if (this.nextAiring == null) return 'zebrrasea.Unknown'.tr();
    return this.nextAiring!.asDateTime(
          showSeconds: false,
          delimiter: '@'.pad(),
          shortenMonth: short,
        );
  }

  String zebrraPreviousAiring([bool short = false]) {
    if (this.previousAiring == null) return ZebrraUI.TEXT_EMDASH;
    return this.previousAiring!.asDateTime(
          showSeconds: false,
          delimiter: '@'.pad(),
          shortenMonth: short,
        );
  }

  String get zebrraDateAdded {
    if (this.added == null) {
      return 'zebrrasea.Unknown'.tr();
    }
    return DateFormat('MMMM dd, y').format(this.added!.toLocal());
  }

  String get zebrraDateAddedShort {
    if (this.added == null) {
      return 'zebrrasea.Unknown'.tr();
    }
    return DateFormat('MMM dd, y').format(this.added!.toLocal());
  }

  String get zebrraYear {
    if (this.year != null && this.year != 0) return this.year.toString();
    return ZebrraUI.TEXT_EMDASH;
  }

  String? get zebrraAirTime {
    if (this.previousAiring != null) {
      return ZebrraSeaDatabase.USE_24_HOUR_TIME.read()
          ? DateFormat.Hm().format(this.previousAiring!.toLocal())
          : DateFormat('hh:mm a').format(this.previousAiring!.toLocal());
    }
    if (this.airTime == null) {
      return 'zebrrasea.Unknown'.tr();
    }
    return this.airTime;
  }

  String get zebrraSeriesType {
    if (this.seriesType == null) return 'zebrrasea.Unknown'.tr();
    return this.seriesType!.value!.toTitleCase();
  }

  String get zebrraSeasonCount {
    if (this.statistics?.seasonCount == null) {
      return 'zebrrasea.Unknown'.tr();
    }
    return this.statistics!.seasonCount == 1
        ? 'sonarr.OneSeason'.tr()
        : 'sonarr.ManySeasons'.tr(
            args: [this.statistics!.seasonCount.toString()],
          );
  }

  String get zebrraSizeOnDisk {
    if (this.statistics?.sizeOnDisk == null) {
      return '0.0 B';
    }
    return this.statistics!.sizeOnDisk.asBytes(decimals: 1);
  }

  String? get zebrraOverview {
    if (this.overview == null || this.overview!.isEmpty) {
      return 'sonarr.NoSummaryAvailable'.tr();
    }
    return this.overview;
  }

  String get zebrraAirsOn {
    if (this.status == 'ended') {
      return 'Aired on ${this.network ?? ZebrraUI.TEXT_EMDASH}';
    }
    return '${this.zebrraAirTime ?? 'Unknown Time'} on ${this.network ?? ZebrraUI.TEXT_EMDASH}';
  }

  String get zebrraEpisodeCount {
    int episodeFileCount = this.statistics?.episodeFileCount ?? 0;
    int episodeCount = this.statistics?.episodeCount ?? 0;
    int percentage = this.zebrraPercentageComplete;
    return '$episodeFileCount/$episodeCount ($percentage%)';
  }

  /// Creates a clone of the [SonarrSeries] object (deep copy).
  SonarrSeries clone() => SonarrSeries.fromJson(this.toJson());

  /// Copies changes from a [SonarrSeriesEditState] state object back to the [SonarrSeries] object.
  SonarrSeries updateEdits(SonarrSeriesEditState edits) {
    SonarrSeries series = this.clone();
    series.monitored = edits.monitored;
    series.seasonFolder = edits.useSeasonFolders;
    series.path = edits.seriesPath;
    series.qualityProfileId = edits.qualityProfile?.id ?? this.qualityProfileId;
    series.seriesType = edits.seriesType ?? this.seriesType;
    series.tags = edits.tags?.map((t) => t.id!).toList() ?? [];
    if (edits.languageProfile != null) {
      series.languageProfileId =
          edits.languageProfile!.id ?? this.languageProfileId;
    }

    return series;
  }
}
