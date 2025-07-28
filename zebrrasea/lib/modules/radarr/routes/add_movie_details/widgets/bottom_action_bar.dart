import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';
import 'package:zebrrasea/router/router.dart';
import 'package:zebrrasea/router/routes/radarr.dart';

class RadarrAddMovieDetailsActionBar extends StatelessWidget {
  const RadarrAddMovieDetailsActionBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZebrraBottomActionBar(
      actions: [
        ZebrraActionBarCard(
          title: 'zebrrasea.Options'.tr(),
          subtitle: 'radarr.StartSearchFor'.tr(),
          onTap: () async => RadarrDialogs().addMovieOptions(context),
        ),
        ZebrraButton(
          type: ZebrraButtonType.TEXT,
          text: 'zebrrasea.Add'.tr(),
          icon: Icons.add_rounded,
          onTap: () async => _onTap(context),
          loadingState: context.watch<RadarrAddMovieDetailsState>().state,
        ),
      ],
    );
  }

  Future<void> _onTap(BuildContext context) async {
    if (context.read<RadarrAddMovieDetailsState>().canExecuteAction) {
      context.read<RadarrAddMovieDetailsState>().state =
          ZebrraLoadingState.ACTIVE;
      await RadarrAPIHelper()
          .addMovie(
        context: context,
        movie: context.read<RadarrAddMovieDetailsState>().movie,
        rootFolder: context.read<RadarrAddMovieDetailsState>().rootFolder,
        monitored: context.read<RadarrAddMovieDetailsState>().monitored,
        qualityProfile:
            context.read<RadarrAddMovieDetailsState>().qualityProfile,
        availability: context.read<RadarrAddMovieDetailsState>().availability,
        tags: context.read<RadarrAddMovieDetailsState>().tags,
        searchForMovie: RadarrDatabase.ADD_MOVIE_SEARCH_FOR_MISSING.read(),
      )
          .then((movie) async {
        context.read<RadarrState>().fetchMovies();
        context.read<RadarrAddMovieDetailsState>().movie.id = movie!.id;
        ZebrraRouter.router.pop();
        RadarrRoutes.MOVIE.go(params: {
          'movie': movie.id!.toString(),
        });
      }).catchError((error, stack) {
        context.read<RadarrAddMovieDetailsState>().state =
            ZebrraLoadingState.ERROR;
      });
      context.read<RadarrAddMovieDetailsState>().state =
          ZebrraLoadingState.INACTIVE;
    }
  }
}
