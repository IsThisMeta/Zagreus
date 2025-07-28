import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/extensions/int/bytes.dart';
import 'package:zebrrasea/modules/sabnzbd.dart';

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
  Future<SABnzbdStatisticsData>? _future;
  SABnzbdStatisticsData? _data;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) => ZebrraScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar as PreferredSizeWidget?,
        body: _body,
      );

  Future<SABnzbdStatisticsData> _fetch() async =>
      SABnzbdAPI.from(ZebrraProfile.current).getStatistics();

  Future<void> _refresh() async {
    if (mounted)
      setState(() {
        _future = _fetch();
      });
  }

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
          builder: (context, AsyncSnapshot<SABnzbdStatisticsData> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                {
                  if (snapshot.hasError || snapshot.data == null)
                    return ZebrraMessage.error(onTap: _refresh);
                  _data = snapshot.data;
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
          _status(),
          const ZebrraHeader(text: 'Statistics'),
          _statistics(),
          ..._serverStatistics(),
        ],
      );

  Widget _status() {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(title: 'Uptime', body: _data!.uptime),
        ZebrraTableContent(title: 'Version', body: _data!.version),
        ZebrraTableContent(
            title: 'Temp. Space',
            body: '${_data!.tempFreespace.toString()} GB'),
        ZebrraTableContent(
            title: 'Final Space',
            body: '${_data!.finalFreespace.toString()} GB'),
      ],
    );
  }

  Widget _statistics() {
    return ZebrraTableCard(
      content: [
        ZebrraTableContent(title: 'Daily', body: _data!.dailyUsage.asBytes()),
        ZebrraTableContent(title: 'Weekly', body: _data!.weeklyUsage.asBytes()),
        ZebrraTableContent(title: 'Monthly', body: _data!.monthlyUsage.asBytes()),
        ZebrraTableContent(title: 'Total', body: _data!.totalUsage.asBytes()),
      ],
    );
  }

  List<Widget> _serverStatistics() {
    return _data!.servers
        .map((server) => [
              ZebrraHeader(text: server.name),
              ZebrraTableCard(
                content: [
                  ZebrraTableContent(
                      title: 'Daily', body: server.dailyUsage.asBytes()),
                  ZebrraTableContent(
                      title: 'Weekly', body: server.weeklyUsage.asBytes()),
                  ZebrraTableContent(
                      title: 'Monthly', body: server.monthlyUsage.asBytes()),
                  ZebrraTableContent(
                      title: 'Total', body: server.totalUsage.asBytes()),
                ],
              ),
            ])
        .expand((element) => element)
        .toList();
  }
}
