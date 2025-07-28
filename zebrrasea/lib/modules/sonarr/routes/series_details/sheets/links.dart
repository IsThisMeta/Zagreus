import 'package:flutter/material.dart';
import 'package:zebrrasea/extensions/string/links.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/utils/links.dart';
import 'package:zebrrasea/widgets/ui.dart';

class LinksSheet extends ZebrraBottomModalSheet {
  SonarrSeries series;

  LinksSheet({
    required this.series,
  });

  @override
  Widget builder(BuildContext context) {
    final imdb = ZebrraLinkedContent.imdb(series.imdbId);
    final tvdb =
        ZebrraLinkedContent.theTVDB(series.tvdbId, LinkedContentType.SERIES);
    final trakt =
        ZebrraLinkedContent.trakt(series.tvdbId, LinkedContentType.SERIES);
    final tvMaze = ZebrraLinkedContent.tvMaze(series.tvMazeId);

    return ZebrraListViewModal(
      children: [
        if (imdb != null)
          ZebrraBlock(
            title: 'IMDb',
            leading: const ZebrraIconButton(icon: ZebrraIcons.IMDB),
            onTap: imdb.openLink,
          ),
        if (tvdb != null)
          ZebrraBlock(
            title: 'TheTVDB',
            leading: const ZebrraIconButton(icon: ZebrraIcons.THETVDB),
            onTap: tvdb.openLink,
          ),
        if (trakt != null)
          ZebrraBlock(
            title: 'Trakt',
            leading: const ZebrraIconButton(icon: ZebrraIcons.TRAKT),
            onTap: trakt.openLink,
          ),
        if (tvMaze != null)
          ZebrraBlock(
            title: 'TVmaze',
            leading: const ZebrraIconButton(icon: ZebrraIcons.TVMAZE),
            onTap: tvMaze.openLink,
          ),
      ],
    );
  }
}
