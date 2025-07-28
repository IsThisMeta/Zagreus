import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/string/string.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/router/routes/sonarr.dart';

enum _SonarrSeriesTileType {
  TILE,
  GRID,
}

class SonarrSeriesTile extends StatefulWidget {
  static final itemExtent = ZebrraBlock.calculateItemExtent(3);

  final SonarrSeries series;
  final SonarrQualityProfile? profile;
  final _SonarrSeriesTileType type;

  const SonarrSeriesTile({
    Key? key,
    required this.series,
    required this.profile,
    this.type = _SonarrSeriesTileType.TILE,
  }) : super(key: key);

  const SonarrSeriesTile.grid({
    Key? key,
    required this.series,
    required this.profile,
    this.type = _SonarrSeriesTileType.GRID,
  }) : super(key: key);

  @override
  State<SonarrSeriesTile> createState() => _State();
}

class _State extends State<SonarrSeriesTile> {
  @override
  Widget build(BuildContext context) {
    return Selector<SonarrState, Future<Map<int?, SonarrSeries>>?>(
      selector: (_, state) => state.series,
      builder: (context, series, _) {
        switch (widget.type) {
          case _SonarrSeriesTileType.TILE:
            return _buildBlockTile();
          case _SonarrSeriesTileType.GRID:
            return _buildGridTile();
          default:
            throw Exception('Invalid _SonarrSeriesTileType');
        }
      },
    );
  }

  Widget _buildBlockTile() {
    return ZebrraBlock(
      backgroundUrl: context.read<SonarrState>().getFanartURL(widget.series.id),
      backgroundHeaders: context.read<SonarrState>().headers,
      posterUrl: context.read<SonarrState>().getPosterURL(widget.series.id),
      posterHeaders: context.read<SonarrState>().headers,
      posterPlaceholderIcon: ZebrraIcons.VIDEO_CAM,
      disabled: !widget.series.monitored!,
      title: widget.series.title,
      body: [
        _subtitle1(),
        _subtitle2(),
        _subtitle3(),
      ],
      onTap: _onTap,
      onLongPress: _onLongPress,
    );
  }

  Widget _buildGridTile() {
    SonarrSeriesSorting _sorting = context.read<SonarrState>().seriesSortType;
    return ZebrraGridBlock(
      key: ObjectKey(widget.series),
      backgroundUrl: context.read<SonarrState>().getFanartURL(widget.series.id),
      posterUrl: context.read<SonarrState>().getPosterURL(widget.series.id),
      posterHeaders: context.read<SonarrState>().headers,
      backgroundHeaders: context.read<SonarrState>().headers,
      posterPlaceholderIcon: ZebrraIcons.VIDEO_CAM,
      title: widget.series.title,
      subtitle: TextSpan(text: _sorting.value(widget.series, widget.profile)),
      disabled: !widget.series.monitored!,
      onTap: _onTap,
      onLongPress: _onLongPress,
    );
  }

  TextSpan _buildChildTextSpan(String? text, SonarrSeriesSorting sorting) {
    TextStyle? style;
    if (context.read<SonarrState>().seriesSortType == sorting) {
      style = const TextStyle(
        color: ZebrraColours.accent,
        fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
        fontSize: ZebrraUI.FONT_SIZE_H3,
      );
    }
    return TextSpan(
      text: text,
      style: style,
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      children: [
        _buildChildTextSpan(
          widget.series.zebrraEpisodeCount,
          SonarrSeriesSorting.EPISODES,
        ),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.series.zebrraSeasonCount),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        _buildChildTextSpan(
          widget.series.zebrraSizeOnDisk,
          SonarrSeriesSorting.SIZE,
        ),
      ],
    );
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        _buildChildTextSpan(
          widget.series.zebrraSeriesType,
          SonarrSeriesSorting.TYPE,
        ),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        _buildChildTextSpan(
          widget.profile?.name ?? ZebrraUI.TEXT_EMDASH,
          SonarrSeriesSorting.QUALITY,
        ),
      ],
    );
  }

  TextSpan _subtitle3() {
    SonarrSeriesSorting _sorting = context.read<SonarrState>().seriesSortType;
    return TextSpan(
      children: [
        _buildChildTextSpan(
          widget.series.zebrraNetwork,
          SonarrSeriesSorting.NETWORK,
        ),
        TextSpan(text: ZebrraUI.TEXT_BULLET.pad()),
        if (_sorting == SonarrSeriesSorting.DATE_ADDED)
          _buildChildTextSpan(
            widget.series.zebrraDateAdded,
            SonarrSeriesSorting.DATE_ADDED,
          ),
        if (_sorting == SonarrSeriesSorting.PREVIOUS_AIRING)
          _buildChildTextSpan(
            widget.series.zebrraPreviousAiring(),
            SonarrSeriesSorting.PREVIOUS_AIRING,
          ),
        if (_sorting != SonarrSeriesSorting.DATE_ADDED &&
            _sorting != SonarrSeriesSorting.PREVIOUS_AIRING)
          _buildChildTextSpan(
            widget.series.zebrraNextAiring(),
            SonarrSeriesSorting.NEXT_AIRING,
          ),
      ],
    );
  }

  Future<void> _onTap() async {
    SonarrRoutes.SERIES.go(params: {
      'series': widget.series.id!.toString(),
    });
  }

  Future<void> _onLongPress() async {
    Tuple2<bool, SonarrSeriesSettingsType?> values =
        await SonarrDialogs().seriesSettings(
      context,
      widget.series,
    );
    if (values.item1) values.item2!.execute(context, widget.series);
  }
}
