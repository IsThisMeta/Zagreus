import 'package:flutter/material.dart';
import 'package:zebrrasea/extensions/string/links.dart';
import 'package:zebrrasea/modules/lidarr/core/api.dart';
import 'package:zebrrasea/utils/links.dart';
import 'package:zebrrasea/widgets/ui.dart';

class LinksSheet extends ZebrraBottomModalSheet {
  LidarrCatalogueData artist;

  LinksSheet({
    required this.artist,
  });

  @override
  Widget builder(BuildContext context) {
    return ZebrraListViewModal(
      children: [
        if (artist.bandsintownURI?.isNotEmpty ?? false)
          ZebrraBlock(
            title: 'Bandsintown',
            leading: const ZebrraIconButton(
              icon: ZebrraIcons.BANDSINTOWN,
              iconSize: ZebrraUI.ICON_SIZE - 4.0,
            ),
            onTap: artist.bandsintownURI!.openLink,
          ),
        if (artist.discogsURI?.isNotEmpty ?? false)
          ZebrraBlock(
            title: 'Discogs',
            leading: const ZebrraIconButton(
              icon: ZebrraIcons.DISCOGS,
              iconSize: ZebrraUI.ICON_SIZE - 2.0,
            ),
            onTap: artist.discogsURI!.openLink,
          ),
        if (artist.lastfmURI?.isNotEmpty ?? false)
          ZebrraBlock(
            title: 'Last.fm',
            leading: const ZebrraIconButton(icon: ZebrraIcons.LASTFM),
            onTap: artist.lastfmURI!.openLink,
          ),
        ZebrraBlock(
          title: 'MusicBrainz',
          leading: const ZebrraIconButton(icon: ZebrraIcons.MUSICBRAINZ),
          onTap:
              ZebrraLinkedContent.musicBrainz(artist.foreignArtistID)!.openLink,
        ),
      ],
    );
  }
}
