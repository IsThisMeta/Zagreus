import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrUpcomingRoute extends StatefulWidget {
  const SonarrUpcomingRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SonarrUpcomingRoute> createState() => _State();
}

class _State extends State<SonarrUpcomingRoute>
    with AutomaticKeepAliveClientMixin, ZebrraLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadCallback() async {
    context.read<SonarrState>().fetchUpcoming();
    await context.read<SonarrState>().upcoming;
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
      child: Selector<
          SonarrState,
          Tuple2<Future<Map<int?, SonarrSeries>>?,
              Future<List<SonarrCalendar>>?>>(
        selector: (_, state) => Tuple2(state.series, state.upcoming),
        builder: (context, tuple, _) => FutureBuilder(
          future: Future.wait([tuple.item1!, tuple.item2!]),
          builder: (context, AsyncSnapshot<List<Object>> snapshot) {
            if (snapshot.hasError) {
              if (snapshot.connectionState != ConnectionState.waiting) {
                ZebrraLogger().error(
                  'Unable to fetch Sonarr upcoming episodes',
                  snapshot.error,
                  snapshot.stackTrace,
                );
              }
              return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
            }
            if (snapshot.hasData)
              return _episodes(
                snapshot.data![0] as Map<int, SonarrSeries>,
                snapshot.data![1] as List<SonarrCalendar>,
              );
            return const ZebrraLoader();
          },
        ),
      ),
    );
  }

  Widget _episodes(
    Map<int, SonarrSeries> series,
    List<SonarrCalendar> upcoming,
  ) {
    if (upcoming.isEmpty) {
      return ZebrraMessage(
        text: 'sonarr.NoEpisodesFound'.tr(),
        buttonText: 'zebrrasea.Refresh'.tr(),
        onTap: _refreshKey.currentState?.show,
      );
    }
    // Split episodes into days into a map
    Map<String, Map<String, dynamic>> _episodeMap =
        upcoming.fold({}, (map, entry) {
      if (entry.airDateUtc == null) return map;
      String _date = DateFormat('y-MM-dd').format(entry.airDateUtc!.toLocal());
      if (!map.containsKey(_date))
        map[_date] = {
          'date': DateFormat('EEEE / MMMM dd, y')
              .format(entry.airDateUtc!.toLocal()),
          'entries': [],
        };
      (map[_date]!['entries'] as List).add(entry);
      return map;
    });
    // Build the widgets
    List<List<Widget>> _episodeWidgets = [];
    _episodeMap.keys.toList()
      ..sort()
      ..forEach((key) {
        _episodeWidgets.add(_buildDay(
          (_episodeMap[key]!['date'] as String?),
          (_episodeMap[key]!['entries'] as List).cast<SonarrCalendar>(),
          series,
        ));
      });
    // Return the list
    return ZebrraListView(
      controller: SonarrNavigationBar.scrollControllers[1],
      children: _episodeWidgets.expand((e) => e).toList(),
    );
  }

  List<Widget> _buildDay(
    String? date,
    List<SonarrCalendar> upcoming,
    Map<int, SonarrSeries> series,
  ) =>
      [
        ZebrraHeader(
          text: date,
          // subtitle: 'This is a test',
        ),
        ...List.generate(
          upcoming.length,
          (index) => SonarrUpcomingTile(
            record: upcoming[index],
            series: series[upcoming[index].seriesId!],
          ),
        ),
      ];
}
