import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/datetime.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/router/routes/sonarr.dart';

enum SonarrHistoryTileType {
  ALL,
  SERIES,
  SEASON,
  EPISODE,
}

class SonarrHistoryTile extends StatelessWidget {
  final SonarrHistoryRecord history;
  final SonarrHistoryTileType type;
  final SonarrSeries? series;
  final SonarrEpisode? episode;

  const SonarrHistoryTile({
    Key? key,
    required this.history,
    required this.type,
    this.series,
    this.episode,
  }) : super(key: key);

  bool _hasEpisodeInfo() {
    if (history.episode != null || episode != null) return true;
    return false;
  }

  bool _hasLongPressAction() {
    switch (type) {
      case SonarrHistoryTileType.ALL:
        return true;
      case SonarrHistoryTileType.SERIES:
        return _hasEpisodeInfo();
      case SonarrHistoryTileType.SEASON:
      case SonarrHistoryTileType.EPISODE:
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isThreeLine =
        _hasEpisodeInfo() && type != SonarrHistoryTileType.EPISODE;
    return ZebrraExpandableListTile(
      title: type != SonarrHistoryTileType.ALL
          ? history.sourceTitle!
          : series?.title ?? ZebrraUI.TEXT_EMDASH,
      collapsedSubtitles: [
        if (_isThreeLine) _subtitle1(),
        _subtitle2(),
        _subtitle3(),
      ],
      expandedHighlightedNodes: [
        ZebrraHighlightedNode(
          text: history.eventType?.readable ?? ZebrraUI.TEXT_EMDASH,
          backgroundColor: history.eventType!.zebrraColour(),
        ),
        if (history.zebrraHasPreferredWordScore())
          ZebrraHighlightedNode(
            text: history.zebrraPreferredWordScore(),
            backgroundColor: ZebrraColours.purple,
          ),
        if (history.episode?.seasonNumber != null)
          ZebrraHighlightedNode(
            text: 'sonarr.SeasonNumber'.tr(
              args: [history.episode!.seasonNumber.toString()],
            ),
            backgroundColor: ZebrraColours.blueGrey,
          ),
        if (episode?.seasonNumber != null)
          ZebrraHighlightedNode(
            text: 'sonarr.SeasonNumber'.tr(
              args: [episode?.seasonNumber?.toString() ?? ZebrraUI.TEXT_EMDASH],
            ),
            backgroundColor: ZebrraColours.blueGrey,
          ),
        if (history.episode?.episodeNumber != null)
          ZebrraHighlightedNode(
            text: 'sonarr.EpisodeNumber'.tr(
              args: [history.episode!.episodeNumber.toString()],
            ),
            backgroundColor: ZebrraColours.blueGrey,
          ),
        if (episode?.episodeNumber != null)
          ZebrraHighlightedNode(
            text: 'sonarr.EpisodeNumber'.tr(
              args: [episode?.episodeNumber?.toString() ?? ZebrraUI.TEXT_EMDASH],
            ),
            backgroundColor: ZebrraColours.blueGrey,
          ),
      ],
      expandedTableContent: history.eventType?.zebrraTableContent(
            history: history,
            showSourceTitle: type != SonarrHistoryTileType.ALL,
          ) ??
          [],
      onLongPress:
          _hasLongPressAction() ? () async => _onLongPress(context) : null,
    );
  }

  Future<void> _onLongPress(BuildContext context) async {
    switch (type) {
      case SonarrHistoryTileType.ALL:
        final id = history.series?.id ?? series?.id ?? -1;
        return SonarrRoutes.SERIES.go(params: {
          'series': id.toString(),
        });
      case SonarrHistoryTileType.SERIES:
        if (_hasEpisodeInfo()) {
          final seriesId =
              history.seriesId ?? history.series?.id ?? series!.id ?? -1;
          final seasonNum =
              history.episode?.seasonNumber ?? episode?.seasonNumber ?? -1;
          return SonarrRoutes.SERIES_SEASON.go(params: {
            'series': seriesId.toString(),
            'season': seasonNum.toString(),
          });
        }
        break;
      default:
        break;
    }
  }

  TextSpan _subtitle1() {
    return TextSpan(children: [
      TextSpan(
        text: history.zebrraSeasonEpisode() ??
            episode?.zebrraSeasonEpisode() ??
            ZebrraUI.TEXT_EMDASH,
      ),
      const TextSpan(text: ': '),
      TextSpan(
        text: history.episode?.title ?? episode?.title ?? ZebrraUI.TEXT_EMDASH,
        style: const TextStyle(
          fontStyle: FontStyle.italic,
        ),
      ),
    ]);
  }

  TextSpan _subtitle2() {
    return TextSpan(
      text: [
        history.date?.asAge() ?? ZebrraUI.TEXT_EMDASH,
        history.date?.asDateTime() ?? ZebrraUI.TEXT_EMDASH,
      ].join(ZebrraUI.TEXT_BULLET.pad()),
    );
  }

  TextSpan _subtitle3() {
    return TextSpan(
      text: history.eventType?.zebrraReadable(history) ?? ZebrraUI.TEXT_EMDASH,
      style: TextStyle(
        color: history.eventType?.zebrraColour() ?? ZebrraColours.blueGrey,
        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
      ),
    );
  }
}
