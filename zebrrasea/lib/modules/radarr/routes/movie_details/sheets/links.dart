import 'package:flutter/material.dart';
import 'package:zebrrasea/api/radarr/models.dart';
import 'package:zebrrasea/extensions/string/links.dart';
import 'package:zebrrasea/utils/links.dart';
import 'package:zebrrasea/widgets/ui.dart';

class LinksSheet extends ZebrraBottomModalSheet {
  RadarrMovie movie;

  LinksSheet({
    required this.movie,
  });

  @override
  Widget builder(BuildContext context) {
    final imdb = ZebrraLinkedContent.imdb(movie.imdbId);
    final tmdb =
        ZebrraLinkedContent.theMovieDB(movie.tmdbId, LinkedContentType.MOVIE);
    final letterboxd = ZebrraLinkedContent.letterboxd(movie.tmdbId);
    final trakt =
        ZebrraLinkedContent.trakt(movie.tmdbId, LinkedContentType.MOVIE);
    final youtube = ZebrraLinkedContent.youtube(movie.youTubeTrailerId);

    return ZebrraListViewModal(
      children: [
        if (imdb != null)
          ZebrraBlock(
            title: 'IMDb',
            leading: const ZebrraIconButton(icon: ZebrraIcons.IMDB),
            onTap: imdb.openLink,
          ),
        if (letterboxd != null)
          ZebrraBlock(
            title: 'Letterboxd',
            leading: const ZebrraIconButton(icon: ZebrraIcons.LETTERBOXD),
            onTap: letterboxd.openLink,
          ),
        if (tmdb != null)
          ZebrraBlock(
            title: 'The Movie Database',
            leading: const ZebrraIconButton(icon: ZebrraIcons.THEMOVIEDATABASE),
            onTap: tmdb.openLink,
          ),
        if (trakt != null)
          ZebrraBlock(
            title: 'Trakt',
            leading: const ZebrraIconButton(icon: ZebrraIcons.TRAKT),
            onTap: trakt.openLink,
          ),
        if (youtube != null)
          ZebrraBlock(
            title: 'YouTube',
            leading: const ZebrraIconButton(icon: ZebrraIcons.YOUTUBE),
            onTap: youtube.openLink,
          ),
      ],
    );
  }
}
