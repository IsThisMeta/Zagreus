import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/nzbget.dart';

class NZBGetHistory extends StatefulWidget {
  static const ROUTE_NAME = '/nzbget/history';
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

  const NZBGetHistory({
    Key? key,
    required this.refreshIndicatorKey,
  }) : super(key: key);

  @override
  State<NZBGetHistory> createState() => _State();
}

class _State extends State<NZBGetHistory>
    with AutomaticKeepAliveClientMixin, ZebrraLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<NZBGetHistoryData>>? _future;
  List<NZBGetHistoryData>? _results = [];

  @override
  bool get wantKeepAlive => true;

  @override
  Future<void> loadCallback() async {
    if (mounted) setState(() => _results = []);
    final _api = NZBGetAPI.from(ZebrraProfile.current);
    if (mounted)
      setState(() {
        _future = _api.getHistory();
      });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
      appBar: _appBar() as PreferredSizeWidget?,
    );
  }

  Widget _appBar() {
    return ZebrraAppBar.empty(
      child: NZBGetHistorySearchBar(
          scrollController: NZBGetNavigationBar.scrollControllers[1]),
      height: ZebrraTextInputBar.defaultAppBarHeight,
    );
  }

  Widget _body() {
    return ZebrraRefreshIndicator(
      context: context,
      key: widget.refreshIndicatorKey,
      onRefresh: loadCallback,
      child: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<List<NZBGetHistoryData>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              {
                if (snapshot.hasError || snapshot.data == null) {
                  return ZebrraMessage.error(
                      onTap: widget.refreshIndicatorKey.currentState!.show);
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
        onTap: loadCallback,
      );
    }
    return Selector<NZBGetState, Tuple2<String, bool>>(
      selector: (_, model) => Tuple2(
        model.historySearchFilter,
        model.historyHideFailed,
      ),
      builder: (context, data, _) {
        List<NZBGetHistoryData> _filtered = _filter(data.item1);
        _filtered = data.item2 ? _hide(_filtered) : _filtered;
        return _listBody(_filtered);
      },
    );
  }

  Widget _listBody(List filtered) {
    if (filtered.isEmpty) {
      return ZebrraListView(
        controller: NZBGetNavigationBar.scrollControllers[1],
        children: [ZebrraMessage.inList(text: 'No History Found')],
      );
    }
    return ZebrraListView(
      controller: NZBGetNavigationBar.scrollControllers[1],
      children: List.generate(
        filtered.length,
        (index) => NZBGetHistoryTile(
          data: filtered[index],
          refresh: loadCallback,
        ),
      ),
    );
  }

  List<NZBGetHistoryData> _filter(String filter) => _results!
      .where((entry) => filter.isEmpty
          ? true
          : entry.name.toLowerCase().contains(filter.toLowerCase()))
      .toList();

  List<NZBGetHistoryData> _hide(List<NZBGetHistoryData> data) {
    if (data.isEmpty) return data;
    return data.where((entry) => entry.failed).toList();
  }
}
