import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/lidarr.dart';

class LidarrHistory extends StatefulWidget {
  static const ROUTE_NAME = '/lidarr/history';
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  final Function refreshAllPages;

  const LidarrHistory({
    Key? key,
    required this.refreshIndicatorKey,
    required this.refreshAllPages,
  }) : super(key: key);

  @override
  State<LidarrHistory> createState() => _State();
}

class _State extends State<LidarrHistory> with AutomaticKeepAliveClientMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<LidarrHistoryData>>? _future;
  List<LidarrHistoryData>? _results = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    _results = [];
    final _api = LidarrAPI.from(ZebrraProfile.current);
    if (mounted)
      setState(() {
        _future = _api.getHistory();
      });
  }

  void _refreshAllPages() => widget.refreshAllPages();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
    );
  }

  Widget _body() {
    return ZebrraRefreshIndicator(
      context: context,
      key: widget.refreshIndicatorKey,
      onRefresh: _refresh,
      child: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<List<LidarrHistoryData>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              {
                if (snapshot.hasError || snapshot.data == null) {
                  return ZebrraMessage.error(onTap: _refresh);
                }
                _results = snapshot.data;
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
  }

  Widget get _list {
    if (_results?.isEmpty ?? true) {
      return ZebrraMessage(
        text: 'No History Found',
        buttonText: 'Refresh',
        onTap: _refresh,
      );
    }
    return ZebrraListViewBuilder(
      controller: LidarrNavigationBar.scrollControllers[2],
      itemCount: _results!.length,
      itemExtent: LidarrHistoryTile.extent,
      itemBuilder: (context, index) => LidarrHistoryTile(
        entry: _results![index],
        scaffoldKey: _scaffoldKey,
        refresh: _refreshAllPages,
      ),
    );
  }
}
