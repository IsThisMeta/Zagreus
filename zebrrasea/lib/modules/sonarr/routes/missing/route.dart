import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrMissingRoute extends StatefulWidget {
  const SonarrMissingRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SonarrMissingRoute> createState() => _State();
}

class _State extends State<SonarrMissingRoute>
    with AutomaticKeepAliveClientMixin, ZebrraLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadCallback() async {
    SonarrState _state = Provider.of<SonarrState>(context, listen: false);
    _state.fetchMissing();
    await _state.missing;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZebrraModule.SONARR,
      body: _body(),
    );
  }

  Widget _body() {
    return ZebrraRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: loadCallback,
      child: Selector<SonarrState,
          Tuple2<Future<Map<int, SonarrSeries>>?, Future<SonarrMissing>?>>(
        selector: (_, state) => Tuple2(state.series, state.missing),
        builder: (context, tuple, _) => FutureBuilder(
          future: Future.wait([tuple.item1!, tuple.item2!]),
          builder: (context, AsyncSnapshot<List<Object>> snapshot) {
            if (snapshot.hasError) {
              if (snapshot.connectionState != ConnectionState.waiting) {
                ZebrraLogger().error(
                  'Unable to fetch Sonarr missing episodes',
                  snapshot.error,
                  snapshot.stackTrace,
                );
              }
              return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
            }
            if (snapshot.hasData)
              return _episodes(
                snapshot.data![0] as Map<int, SonarrSeries>,
                snapshot.data![1] as SonarrMissing,
              );
            return const ZebrraLoader();
          },
        ),
      ),
    );
  }

  Widget _episodes(Map<int, SonarrSeries> series, SonarrMissing missing) {
    if ((missing.records?.length ?? 0) == 0)
      return ZebrraMessage(
        text: 'sonarr.NoEpisodesFound'.tr(),
        buttonText: 'zebrrasea.Refresh'.tr(),
        onTap: _refreshKey.currentState?.show,
      );
    return ZebrraListViewBuilder(
      controller: SonarrNavigationBar.scrollControllers[2],
      itemCount: missing.records!.length,
      itemExtent: SonarrMissingTile.itemExtent,
      itemBuilder: (context, index) => SonarrMissingTile(
        record: missing.records![index],
        series: series[missing.records![index].seriesId!],
      ),
    );
  }
}
