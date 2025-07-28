import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrMovieDetailsHistoryPage extends StatefulWidget {
  final RadarrMovie? movie;

  const RadarrMovieDetailsHistoryPage({
    Key? key,
    required this.movie,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrMovieDetailsHistoryPage>
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
      module: ZebrraModule.RADARR,
      scaffoldKey: _scaffoldKey,
      body: _body(),
    );
  }

  Widget _body() {
    return ZebrraRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: () async =>
          context.read<RadarrMovieDetailsState>().fetchHistory(context),
      child: FutureBuilder(
        future: context.watch<RadarrMovieDetailsState>().history,
        builder: (context, AsyncSnapshot<List<RadarrHistoryRecord>> snapshot) {
          if (snapshot.hasError) {
            ZebrraLogger().error(
                'Unable to fetch Radarr movie history: ${widget.movie!.id}',
                snapshot.error,
                snapshot.stackTrace);
            return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData) return _list(snapshot.data);
          return const ZebrraLoader();
        },
      ),
    );
  }

  Widget _list(List<RadarrHistoryRecord>? history) {
    if ((history?.length ?? 0) == 0)
      return ZebrraMessage(
        text: 'No History Found',
        buttonText: 'Refresh',
        onTap: _refreshKey.currentState!.show,
      );
    return ZebrraListViewBuilder(
      controller: RadarrMovieDetailsNavigationBar.scrollControllers[2],
      itemCount: history!.length,
      itemBuilder: (context, index) =>
          RadarrHistoryTile(history: history[index], movieHistory: true),
    );
  }
}
