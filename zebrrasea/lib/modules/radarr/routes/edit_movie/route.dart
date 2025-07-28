import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';
import 'package:zebrrasea/widgets/pages/invalid_route.dart';

class MovieEditRoute extends StatefulWidget {
  final int movieId;

  const MovieEditRoute({
    Key? key,
    required this.movieId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<MovieEditRoute>
    with ZebrraLoadCallbackMixin, ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Future<void> loadCallback() async {
    context.read<RadarrState>().fetchTags();
    context.read<RadarrState>().fetchQualityProfiles();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movieId <= 0) {
      return InvalidRoutePage(
        title: 'radarr.EditMovie'.tr(),
        message: 'radarr.MovieNotFound'.tr(),
      );
    }
    return ChangeNotifierProvider(
        create: (_) => RadarrMoviesEditState(),
        builder: (context, _) {
          ZebrraLoadingState state =
              context.select<RadarrMoviesEditState, ZebrraLoadingState>(
                  (state) => state.state);
          return ZebrraScaffold(
            scaffoldKey: _scaffoldKey,
            appBar: _appBar() as PreferredSizeWidget?,
            body:
                state == ZebrraLoadingState.ERROR ? _bodyError() : _body(context),
            bottomNavigationBar: state == ZebrraLoadingState.ERROR
                ? null
                : const RadarrEditMovieActionBar(),
          );
        });
  }

  Widget _appBar() {
    return ZebrraAppBar(
      scrollControllers: [scrollController],
      title: 'radarr.EditMovie'.tr(),
    );
  }

  Widget _bodyError() {
    return ZebrraMessage.goBack(
      context: context,
      text: 'zebrrasea.AnErrorHasOccurred'.tr(),
    );
  }

  Widget _body(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        context.select<RadarrState, Future<List<RadarrMovie>>>(
          (state) => state.movies!,
        ),
        context.select<RadarrState, Future<List<RadarrQualityProfile>>>(
          (state) => state.qualityProfiles!,
        ),
        context.select<RadarrState, Future<List<RadarrTag>>>(
          (state) => state.tags!,
        ),
      ]),
      builder: (context, AsyncSnapshot<List<Object>> snapshot) {
        if (snapshot.hasError) return ZebrraMessage.error(onTap: loadCallback);
        if (snapshot.hasData) {
          final movies = snapshot.data![0] as List<RadarrMovie>;
          final profiles = snapshot.data![1] as List<RadarrQualityProfile>;
          final tags = snapshot.data![2] as List<RadarrTag>;
          RadarrMovie movie = movies.firstWhere((m) => m.id == widget.movieId);

          return _list(
            context,
            movie: movie,
            profiles: profiles,
            tags: tags,
          );
        }
        return const ZebrraLoader();
      },
    );
  }

  Widget _list(
    BuildContext context, {
    required RadarrMovie movie,
    required List<RadarrQualityProfile> profiles,
    required List<RadarrTag> tags,
  }) {
    if (context.read<RadarrMoviesEditState>().movie == null) {
      context.read<RadarrMoviesEditState>().movie = movie;
      context.read<RadarrMoviesEditState>().initializeQualityProfile(profiles);
      context.read<RadarrMoviesEditState>().initializeTags(tags);
      context.read<RadarrMoviesEditState>().canExecuteAction = true;
    }
    return ZebrraListView(
      controller: scrollController,
      children: [
        const RadarrMoviesEditMonitoredTile(),
        const RadarrMoviesEditMinimumAvailabilityTile(),
        RadarrMoviesEditQualityProfileTile(profiles: profiles),
        const RadarrMoviesEditPathTile(),
        const RadarrMoviesEditTagsTile(),
      ],
    );
  }
}
