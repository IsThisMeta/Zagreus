import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrUpcomingRoute extends StatefulWidget {
  const RadarrUpcomingRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrUpcomingRoute>
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
      body: _body,
    );
  }

  Future<void> _refresh() async {
    RadarrState _state = context.read<RadarrState>();
    _state.fetchMovies();
    _state.fetchQualityProfiles();
    await Future.wait([
      _state.upcoming!,
      _state.qualityProfiles!,
    ]);
  }

  Widget get _body => ZebrraRefreshIndicator(
        context: context,
        key: _refreshKey,
        onRefresh: _refresh,
        child: Selector<
            RadarrState,
            Tuple2<Future<List<RadarrMovie>>?,
                Future<List<RadarrQualityProfile>>?>>(
          selector: (_, state) => Tuple2(state.upcoming, state.qualityProfiles),
          builder: (context, tuple, _) => FutureBuilder(
            future: Future.wait([tuple.item1!, tuple.item2!]),
            builder: (context, AsyncSnapshot<List<Object>> snapshot) {
              if (snapshot.hasError) {
                if (snapshot.connectionState != ConnectionState.waiting)
                  ZebrraLogger().error(
                    'Unable to fetch Radarr upcoming',
                    snapshot.error,
                    snapshot.stackTrace,
                  );
                return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
              }
              if (snapshot.hasData)
                return _list(snapshot.data![0] as List<RadarrMovie>,
                    snapshot.data![1] as List<RadarrQualityProfile>);
              return const ZebrraLoader();
            },
          ),
        ),
      );

  Widget _list(
    List<RadarrMovie> movies,
    List<RadarrQualityProfile> qualityProfiles,
  ) {
    if (movies.isEmpty) {
      return ZebrraMessage(
        text: 'radarr.NoMoviesFound'.tr(),
        buttonText: 'zebrrasea.Refresh'.tr(),
        onTap: _refreshKey.currentState!.show,
      );
    }
    return ZebrraListViewBuilder(
      controller: RadarrNavigationBar.scrollControllers[1],
      itemCount: movies.length,
      itemExtent: RadarrUpcomingTile.itemExtent,
      itemBuilder: (context, index) => RadarrUpcomingTile(
        movie: movies[index],
        profile: qualityProfiles.firstWhereOrNull(
            (element) => element.id == movies[index].qualityProfileId),
      ),
    );
  }
}
