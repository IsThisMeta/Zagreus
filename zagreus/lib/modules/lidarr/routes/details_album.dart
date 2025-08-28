import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/lidarr.dart';
import 'package:zagreus/router/routes/lidarr.dart';

class ArtistAlbumDetailsRoute extends StatefulWidget {
  final int artistId;
  final int albumId;
  final bool monitored;

  const ArtistAlbumDetailsRoute({
    Key? key,
    required this.artistId,
    required this.albumId,
    required this.monitored,
  }) : super(key: key);

  @override
  State<ArtistAlbumDetailsRoute> createState() => _State();
}

class _State extends State<ArtistAlbumDetailsRoute>
    with ZagScrollControllerMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  Future<List<LidarrTrackData>>? _future;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    final api = LidarrAPI.from(ZagProfile.current);
    setState(() {
      _future = api.getAlbumTracks(widget.albumId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body,
      appBar: _appBar,
    );
  }

  PreferredSizeWidget get _appBar {
    return ZagAppBar(
      title: 'Album Details',
      scrollControllers: [scrollController],
      actions: <Widget>[
        ZagIconButton(
          icon: Icons.search_rounded,
          onPressed: () async => _automaticSearch(),
          onLongPress: () async => _manualSearch(),
        ),
      ],
    );
  }

  Widget get _body {
    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: _refresh,
      child: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<List<LidarrTrackData>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              {
                if (snapshot.hasError || snapshot.data == null) {
                  return ZagMessage.error(onTap: _refresh);
                }
                return _list(snapshot.data!);
              }
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
            default:
              return const ZagLoader();
          }
        },
      ),
    );
  }

  Widget _list(List<LidarrTrackData> results) {
    if (results.isEmpty) {
      return ZagMessage(
        text: 'No Tracks Found',
        buttonText: 'Refresh',
        onTap: _refresh,
      );
    }

    return ZagListViewBuilder(
      controller: scrollController,
      itemCount: results.length,
      itemBuilder: (context, index) {
        return LidarrDetailsTrackTile(
          data: results[index],
          monitored: widget.monitored,
        );
      },
    );
  }

  Future<void> _automaticSearch() async {
    LidarrAPI _api = LidarrAPI.from(ZagProfile.current);
    _api.searchAlbums([widget.albumId]).then((_) {
      showZagSuccessSnackBar(
        title: 'Searching...',
        message: '',
      );
    }).catchError((error, stack) {
      ZagLogger().error('Failed to search for album', error, stack);
      showZagErrorSnackBar(
        title: 'Failed to Search',
        error: error,
      );
    });
  }

  Future<void> _manualSearch() async {
    LidarrRoutes.ARTIST_ALBUM_RELEASES.go(params: {
      'artist': widget.artistId.toString(),
      'album': widget.albumId.toString(),
    });
  }
}
