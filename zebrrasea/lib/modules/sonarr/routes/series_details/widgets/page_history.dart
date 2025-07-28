import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrSeriesDetailsHistoryPage extends StatefulWidget {
  const SonarrSeriesDetailsHistoryPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SonarrSeriesDetailsHistoryPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

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
      onRefresh: () async =>
          context.read<SonarrSeriesDetailsState>().fetchHistory(context),
      child: FutureBuilder(
        future: context.select<SonarrSeriesDetailsState,
            Future<List<SonarrHistoryRecord>>?>((s) => s.history),
        builder: (context, AsyncSnapshot<List<SonarrHistoryRecord>> snapshot) {
          if (snapshot.hasError) {
            ZebrraLogger().error(
              'Unable to fetch Sonarr series history: ${context.read<SonarrSeriesDetailsState>().series.id}',
              snapshot.error,
              snapshot.stackTrace,
            );
            return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData) return _list(snapshot.data);
          return const ZebrraLoader();
        },
      ),
    );
  }

  Widget _list(List<SonarrHistoryRecord>? history) {
    if ((history?.length ?? 0) == 0)
      return ZebrraMessage(
        text: 'sonarr.NoHistoryFound'.tr(),
        buttonText: 'zebrrasea.Refresh'.tr(),
        onTap: _refreshKey.currentState!.show,
      );
    return ZebrraListViewBuilder(
      controller: SonarrSeriesDetailsNavigationBar.scrollControllers[2],
      itemCount: history!.length,
      itemBuilder: (context, index) => SonarrHistoryTile(
        history: history[index],
        type: SonarrHistoryTileType.SERIES,
      ),
    );
  }
}
