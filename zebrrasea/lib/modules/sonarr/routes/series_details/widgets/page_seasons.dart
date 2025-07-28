import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrSeriesDetailsSeasonsPage extends StatefulWidget {
  final SonarrSeries? series;

  const SonarrSeriesDetailsSeasonsPage({
    Key? key,
    required this.series,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SonarrSeriesDetailsSeasonsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZebrraModule.SONARR,
      body: _body(),
    );
  }

  Widget _body() {
    return ZebrraRefreshIndicator(
      key: _refreshKey,
      context: context,
      onRefresh: () async => context.read<SonarrState>().fetchSeries(
            widget.series!.id!,
          ),
      child: _list(),
    );
  }

  Widget _list() {
    if (widget.series?.seasons?.isEmpty ?? true) {
      return ZebrraMessage(
        text: 'sonarr.NoSeasonsFound'.tr(),
        buttonText: 'zebrrasea.Refresh'.tr(),
        onTap: _refreshKey.currentState!.show,
      );
    }
    List<SonarrSeriesSeason> _seasons = widget.series!.seasons!;
    _seasons.sort((a, b) => a.seasonNumber!.compareTo(b.seasonNumber!));
    return ZebrraListView(
      controller: SonarrSeriesDetailsNavigationBar.scrollControllers[1],
      children: [
        if (_seasons.length > 1)
          SonarrSeriesDetailsSeasonAllTile(series: widget.series),
        ...List.generate(
          _seasons.length,
          (index) => SonarrSeriesDetailsSeasonTile(
            seriesId: widget.series!.id,
            season: widget.series!.seasons![_seasons.length - 1 - index],
          ),
        ),
      ],
    );
  }
}
