import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/lidarr.dart';

class LidarrDetailsOverview extends StatefulWidget {
  final LidarrCatalogueData data;

  const LidarrDetailsOverview({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<LidarrDetailsOverview> createState() => _State();
}

class _State extends State<LidarrDetailsOverview>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZebrraListView(
      controller: LidarrArtistNavigationBar.scrollControllers[0],
      children: <Widget>[
        LidarrDescriptionBlock(
          title: widget.data.title,
          description: widget.data.overview == ''
              ? 'No Summary Available'
              : widget.data.overview,
          uri: widget.data.posterURI(),
          squareImage: true,
          headers: ZebrraProfile.current.lidarrHeaders,
        ),
        ZebrraTableCard(
          content: [
            ZebrraTableContent(
              title: 'Path',
              body: widget.data.path,
            ),
            ZebrraTableContent(
              title: 'Quality',
              body: widget.data.quality,
            ),
            ZebrraTableContent(
              title: 'Metadata',
              body: widget.data.metadata,
            ),
            ZebrraTableContent(
              title: 'Albums',
              body: widget.data.albums,
            ),
            ZebrraTableContent(
              title: 'Tracks',
              body: widget.data.tracks,
            ),
            ZebrraTableContent(
              title: 'Genres',
              body: widget.data.genre,
            ),
          ],
        ),
      ],
    );
  }
}
