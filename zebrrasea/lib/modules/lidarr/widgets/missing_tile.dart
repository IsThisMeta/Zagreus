import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/lidarr.dart';
import 'package:zebrrasea/router/routes/lidarr.dart';

class LidarrMissingTile extends StatefulWidget {
  static final double extent = ZebrraBlock.calculateItemExtent(2);

  final LidarrMissingData entry;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function refresh;

  const LidarrMissingTile({
    Key? key,
    required this.entry,
    required this.scaffoldKey,
    required this.refresh,
  }) : super(key: key);

  @override
  State<LidarrMissingTile> createState() => _State();
}

class _State extends State<LidarrMissingTile> {
  @override
  Widget build(BuildContext context) {
    return ZebrraBlock(
      title: widget.entry.artistTitle,
      body: [
        TextSpan(
          text: widget.entry.title,
          style: const TextStyle(
            color: ZebrraColours.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
        TextSpan(
          text: 'Released ${widget.entry.releaseDateString}',
          style: const TextStyle(
            color: ZebrraColours.red,
            fontWeight: ZebrraUI.FONT_WEIGHT_BOLD,
          ),
        ),
      ],
      trailing: ZebrraIconButton(
        icon: ZebrraIcons.SEARCH,
        onPressed: () async => _search(),
        onLongPress: () async => _interactiveSearch(),
      ),
      onTap: () async => _enterAlbum(),
      onLongPress: () async => _enterArtist(),
      posterUrl: widget.entry.albumCoverURI(),
      posterHeaders: ZebrraProfile.current.lidarrHeaders,
      posterIsSquare: true,
      posterPlaceholderIcon: ZebrraIcons.MUSIC,
      backgroundUrl: widget.entry.fanartURI(),
      backgroundHeaders: ZebrraProfile.current.lidarrHeaders,
    );
  }

  Future<void> _search() async {
    final _api = LidarrAPI.from(ZebrraProfile.current);
    await _api
        .searchAlbums([widget.entry.albumID])
        .then((_) => showZebrraSuccessSnackBar(
            title: 'Searching...', message: widget.entry.title))
        .catchError((error) =>
            showZebrraErrorSnackBar(title: 'Failed to Search', error: error));
  }

  Future<void> _interactiveSearch() async {
    LidarrRoutes.ARTIST_ALBUM_RELEASES.go(params: {
      'artist': widget.entry.artistID.toString(),
      'album': widget.entry.albumID.toString(),
    });
  }

  Future<void> _enterArtist() async {
    LidarrRoutes.ARTIST.go(
      params: {
        'artist': widget.entry.artistID.toString(),
      },
    );
  }

  Future<void> _enterAlbum() async {
    LidarrRoutes.ARTIST_ALBUM.go(params: {
      'album': widget.entry.albumID.toString(),
      'artist': widget.entry.artistID.toString(),
    }, queryParams: {
      'monitored': widget.entry.monitored.toString(),
    });
  }
}
