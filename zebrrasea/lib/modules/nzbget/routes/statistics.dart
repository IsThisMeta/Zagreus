import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/nzbget.dart';

class StatisticsRoute extends StatefulWidget {
  const StatisticsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatisticsRoute> createState() => _State();
}

class _State extends State<StatisticsRoute> with ZebrraScrollControllerMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<bool>? _future;
  late NZBGetStatisticsData _statistics;
  List<NZBGetLogData> _logs = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (mounted)
      setState(() {
        _future = _fetch();
      });
  }

  Future<bool> _fetch() async {
    final _api = NZBGetAPI.from(ZebrraProfile.current);
    return _fetchStatistics(_api)
        .then((_) => _fetchLogs(_api))
        .then((_) => true);
  }

  Future<void> _fetchStatistics(NZBGetAPI api) async {
    return await api.getStatistics().then((stats) {
      _statistics = stats;
    });
  }

  Future<void> _fetchLogs(NZBGetAPI api) async {
    return await api.getLogs().then((logs) {
      _logs = logs;
    });
  }

  @override
  Widget build(BuildContext context) => ZebrraScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar as PreferredSizeWidget?,
        body: _body,
      );

  Widget get _appBar => ZebrraAppBar(
        title: 'Server Statistics',
        scrollControllers: [scrollController],
      );

  Widget get _body => ZebrraRefreshIndicator(
        context: context,
        key: _refreshKey,
        onRefresh: _refresh,
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                {
                  if (snapshot.hasError || snapshot.data == null)
                    return ZebrraMessage.error(onTap: _refresh);
                  return _list;
                }
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
              default:
                return const ZebrraLoader();
            }
          },
        ),
      );

  Widget get _list => ZebrraListView(
        controller: scrollController,
        children: <Widget>[
          const ZebrraHeader(text: 'Status'),
          _statusBlock(),
          const ZebrraHeader(text: 'Logs'),
          for (var entry in _logs)
            NZBGetLogTile(
              data: entry,
            ),
        ],
      );

  Widget _statusBlock() {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(
            title: 'Server',
            body: _statistics.serverPaused ? 'Paused' : 'Active'),
        ZebrraTableContent(
            title: 'Post', body: _statistics.postPaused ? 'Paused' : 'Active'),
        ZebrraTableContent(
            title: 'Scan', body: _statistics.scanPaused ? 'Paused' : 'Active'),
        ZebrraTableContent(title: '', body: ''),
        ZebrraTableContent(title: 'Uptime', body: _statistics.uptimeString),
        ZebrraTableContent(
            title: 'Speed Limit', body: _statistics.speedLimitString),
        ZebrraTableContent(
            title: 'Free Space', body: _statistics.freeSpaceString),
        ZebrraTableContent(title: 'Download', body: _statistics.downloadedString),
      ],
    );
  }
}
