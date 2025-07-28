import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/lidarr.dart';

class AddArtistRoute extends StatefulWidget {
  const AddArtistRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<AddArtistRoute> createState() => _State();
}

class _State extends State<AddArtistRoute> with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  Future<List<LidarrSearchData>>? _future;
  List<String> _availableIDs = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableArtists();
  }

  @override
  Widget build(BuildContext context) => ZebrraScaffold(
        scaffoldKey: _scaffoldKey,
        body: _body(),
        appBar: _appBar() as PreferredSizeWidget?,
      );

  Future<void> _refresh() async {
    final _model = Provider.of<LidarrState>(context, listen: false);
    final _api = LidarrAPI.from(ZebrraProfile.current);
    setState(() {
      _future = _api.searchArtists(_model.addSearchQuery);
    });
  }

  Future<void> _fetchAvailableArtists() async {
    await LidarrAPI.from(ZebrraProfile.current)
        .getAllArtistIDs()
        .then((data) => _availableIDs = data)
        .catchError((error) => _availableIDs = []);
  }

  Widget _appBar() {
    return ZebrraAppBar(
      scrollControllers: [scrollController],
      title: 'Add Artist',
      bottom: LidarrAddSearchBar(
        callback: _refresh,
        scrollController: scrollController,
      ),
    );
  }

  Widget _body() {
    return ZebrraRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: _refresh,
      child: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<List<LidarrSearchData>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.none)
            return Container();
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting)
              ZebrraLogger().error(
                'Unable to fetch Lidarr artist lookup',
                snapshot.error,
                snapshot.stackTrace,
              );
            return ZebrraMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) return _list(snapshot.data);
          return const ZebrraLoader();
        },
      ),
    );
  }

  Widget _list(List<LidarrSearchData>? data) {
    if ((data?.length ?? 0) == 0)
      return ZebrraListView(
        controller: scrollController,
        children: const [ZebrraMessage(text: 'No Results Found')],
      );
    return ZebrraListViewBuilder(
      controller: scrollController,
      itemCount: data!.length,
      itemBuilder: (context, index) => LidarrAddSearchResultTile(
        data: data[index],
        alreadyAdded: _availableIDs.contains(data[index].foreignArtistId),
      ),
    );
  }
}
