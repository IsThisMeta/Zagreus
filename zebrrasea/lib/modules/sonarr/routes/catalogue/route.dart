import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/router/routes/sonarr.dart';
import 'package:zebrrasea/types/list_view_option.dart';

class SonarrCatalogueRoute extends StatefulWidget {
  const SonarrCatalogueRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SonarrCatalogueRoute> createState() => _State();
}

class _State extends State<SonarrCatalogueRoute>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  Future<void> _refresh() async {
    SonarrState _state = context.read<SonarrState>();
    _state.fetchAllSeries();
    _state.fetchQualityProfiles();
    _state.fetchLanguageProfiles();
    _state.fetchTags();

    await Future.wait([
      _state.series!,
      _state.qualityProfiles!,
      _state.tags!,
      _state.languageProfiles!,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZebrraModule.SONARR,
      body: _body(),
      appBar: _appBar(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZebrraAppBar.empty(
      child: SonarrSeriesSearchBar(
        scrollController: SonarrNavigationBar.scrollControllers[0],
      ),
      height: ZebrraTextInputBar.defaultAppBarHeight,
    );
  }

  Widget _body() {
    return ZebrraRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: _refresh,
      child: Selector<
          SonarrState,
          Tuple2<Future<Map<int?, SonarrSeries>>?,
              Future<List<SonarrQualityProfile>>?>>(
        selector: (_, state) => Tuple2(
          state.series,
          state.qualityProfiles,
        ),
        builder: (context, tuple, _) => FutureBuilder(
          future: Future.wait([
            tuple.item1!,
            tuple.item2!,
          ]),
          builder: (context, AsyncSnapshot<List<Object>> snapshot) {
            if (snapshot.hasError) {
              if (snapshot.connectionState != ConnectionState.waiting) {
                ZebrraLogger().error(
                  'Unable to fetch Sonarr series',
                  snapshot.error,
                  snapshot.stackTrace,
                );
              }
              return ZebrraMessage.error(
                onTap: _refreshKey.currentState!.show,
              );
            }
            if (snapshot.hasData) {
              return _series(
                snapshot.data![0] as Map<int, SonarrSeries>,
                snapshot.data![1] as List<SonarrQualityProfile>,
              );
            }
            return const ZebrraLoader();
          },
        ),
      ),
    );
  }

  List<SonarrSeries> _filterAndSort(
    Map<int, SonarrSeries> series,
    List<SonarrQualityProfile> profiles,
    String query,
  ) {
    if (series.isEmpty) return [];
    SonarrSeriesSorting sorting = context.watch<SonarrState>().seriesSortType;
    SonarrSeriesFilter filter = context.watch<SonarrState>().seriesFilterType;
    bool ascending = context.watch<SonarrState>().seriesSortAscending;
    // Filter
    List<SonarrSeries> filtered = series.values.where((show) {
      if (query.isNotEmpty && show.id != null)
        return show.title!.toLowerCase().contains(query.toLowerCase());
      return show.id != null;
    }).toList();
    filtered = filter.filter(filtered);
    // Sort
    filtered = sorting.sort(filtered, ascending);
    return filtered;
  }

  Widget _series(
    Map<int, SonarrSeries> series,
    List<SonarrQualityProfile> qualities,
  ) {
    if (series.isEmpty)
      return ZebrraMessage(
        text: 'sonarr.NoSeriesFound'.tr(),
        buttonText: 'zebrrasea.Refresh'.tr(),
        onTap: _refreshKey.currentState!.show,
      );
    return Selector<SonarrState, String>(
      selector: (_, state) => state.seriesSearchQuery,
      builder: (context, query, _) {
        List<SonarrSeries> _filtered = _filterAndSort(series, qualities, query);
        if (_filtered.isEmpty)
          return ZebrraListView(
            controller: SonarrNavigationBar.scrollControllers[0],
            children: [
              ZebrraMessage.inList(text: 'sonarr.NoSeriesFound'.tr()),
              if (query.isNotEmpty)
                ZebrraButtonContainer(
                  children: [
                    ZebrraButton.text(
                      icon: null,
                      text: query.length > 20
                          ? 'sonarr.SearchFor'.tr(args: [
                              '"${query.substring(0, min(20, query.length))}${ZebrraUI.TEXT_ELLIPSIS}"'
                            ])
                          : 'sonarr.SearchFor'.tr(args: ['"$query"']),
                      backgroundColor: ZebrraColours.accent,
                      onTap: () async {
                        SonarrRoutes.ADD_SERIES.go(queryParams: {
                          'query': query,
                        });
                      },
                    ),
                  ],
                ),
            ],
          );
        switch (context.read<SonarrState>().seriesViewType) {
          case ZebrraListViewOption.BLOCK_VIEW:
            return _blockView(_filtered, qualities);
          case ZebrraListViewOption.GRID_VIEW:
            return _gridView(_filtered, qualities);
          default:
            throw Exception('Invalid moviesViewType');
        }
      },
    );
  }

  Widget _blockView(
    List<SonarrSeries> series,
    List<SonarrQualityProfile> qualities,
  ) {
    return ZebrraListViewBuilder(
      controller: SonarrNavigationBar.scrollControllers[0],
      itemCount: series.length,
      itemExtent: SonarrSeriesTile.itemExtent,
      itemBuilder: (context, index) => SonarrSeriesTile(
        series: series[index],
        profile: qualities.firstWhereOrNull(
          (element) => element.id == series[index].qualityProfileId,
        ),
      ),
    );
  }

  Widget _gridView(
    List<SonarrSeries> series,
    List<SonarrQualityProfile> qualities,
  ) {
    return ZebrraGridViewBuilder(
      controller: SonarrNavigationBar.scrollControllers[0],
      sliverGridDelegate: ZebrraGridBlock.getMaxCrossAxisExtent(),
      itemCount: series.length,
      itemBuilder: (context, index) => SonarrSeriesTile.grid(
        series: series[index],
        profile: qualities.firstWhereOrNull(
          (element) => element.id == series[index].qualityProfileId,
        ),
      ),
    );
  }
}
