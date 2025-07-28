import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/widgets/sheets/download_client/button.dart';

class ReleasesRoute extends StatefulWidget {
  final int? episodeId;
  final int? seriesId;
  final int? seasonNumber;

  const ReleasesRoute({
    Key? key,
    this.episodeId,
    this.seriesId,
    this.seasonNumber,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ReleasesRoute> with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SonarrReleasesState(
        context: context,
        episodeId: widget.episodeId,
        seriesId: widget.seriesId,
        seasonNumber: widget.seasonNumber,
      ),
      builder: (context, _) => ZebrraScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar(context) as PreferredSizeWidget?,
        body: _body(context),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    return ZebrraAppBar(
      title: 'sonarr.Releases'.tr(),
      scrollControllers: [scrollController],
      bottom: SonarrReleasesSearchBar(scrollController: scrollController),
      actions: const [
        DownloadClientButton(),
      ],
    );
  }

  Widget _body(BuildContext context) {
    return ZebrraRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: () async {
        context.read<SonarrReleasesState>().refreshReleases(context);
        await context.read<SonarrReleasesState>().releases;
      },
      child: FutureBuilder(
        future: context.read<SonarrReleasesState>().releases,
        builder: (context, AsyncSnapshot<List<SonarrRelease>> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting) {
              ZebrraLogger().error(
                'Unable to fetch Sonarr releases',
                snapshot.error,
                snapshot.stackTrace,
              );
            }
            return ZebrraMessage.error(
              onTap: () => _refreshKey.currentState!.show,
            );
          }
          if (snapshot.hasData) return _list(context, snapshot.data);
          return const ZebrraLoader();
        },
      ),
    );
  }

  Widget _list(BuildContext context, List<SonarrRelease>? releases) {
    return Consumer<SonarrReleasesState>(
      builder: (context, state, _) {
        if (releases?.isEmpty ?? true) {
          return ZebrraMessage(
            text: 'sonarr.NoReleasesFound'.tr(),
            buttonText: 'zebrrasea.Refresh'.tr(),
            onTap: _refreshKey.currentState!.show,
          );
        }
        List<SonarrRelease> _processed = _filterAndSortReleases(
          releases ?? [],
          state,
        );
        return ZebrraListViewBuilder(
          controller: scrollController,
          itemCount: _processed.isEmpty ? 1 : _processed.length,
          itemBuilder: (context, index) {
            if (_processed.isEmpty) {
              return ZebrraMessage.inList(text: 'sonarr.NoReleasesFound'.tr());
            }
            return SonarrReleasesTile(release: _processed[index]);
          },
        );
      },
    );
  }

  List<SonarrRelease> _filterAndSortReleases(
    List<SonarrRelease> releases,
    SonarrReleasesState state,
  ) {
    if (releases.isEmpty) return releases;
    List<SonarrRelease> filtered = releases.where(
      (release) {
        String _query = state.searchQuery;
        if (_query.isNotEmpty) {
          return release.title!.toLowerCase().contains(_query.toLowerCase());
        }
        return true;
      },
    ).toList();
    filtered = state.filterType.filter(filtered);
    filtered = state.sortType.sort(filtered, state.sortAscending);
    return filtered;
  }
}
