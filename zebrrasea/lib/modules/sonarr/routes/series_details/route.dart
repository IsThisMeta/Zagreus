import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';
import 'package:zebrrasea/modules/sonarr/routes/series_details/sheets/links.dart';
import 'package:zebrrasea/router/routes/sonarr.dart';
import 'package:zebrrasea/widgets/pages/invalid_route.dart';

class SeriesDetailsRoute extends StatefulWidget {
  final int seriesId;

  const SeriesDetailsRoute({
    Key? key,
    required this.seriesId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SeriesDetailsRoute> with ZebrraLoadCallbackMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SonarrSeries? series;
  PageController? _pageController;

  @override
  Future<void> loadCallback() async {
    if (widget.seriesId > 0) {
      SonarrSeries? result =
          (await context.read<SonarrState>().series)![widget.seriesId];
      setState(() => series = result);
      context.read<SonarrState>().fetchQualityProfiles();
      context.read<SonarrState>().fetchLanguageProfiles();
      context.read<SonarrState>().fetchTags();
      await context.read<SonarrState>().fetchSeries(widget.seriesId);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: SonarrDatabase.NAVIGATION_INDEX_SERIES_DETAILS.read(),
    );
  }

  List<SonarrTag> _findTags(
    List<int>? tagIds,
    List<SonarrTag> tags,
  ) {
    return tags.where((tag) => tagIds!.contains(tag.id)).toList();
  }

  SonarrQualityProfile? _findQualityProfile(
    int? qualityProfileId,
    List<SonarrQualityProfile> profiles,
  ) {
    return profiles.firstWhereOrNull(
      (profile) => profile.id == qualityProfileId,
    );
  }

  SonarrLanguageProfile? _findLanguageProfile(
    int? languageProfileId,
    List<SonarrLanguageProfile> profiles,
  ) {
    return profiles.firstWhereOrNull(
      (profile) => profile.id == languageProfileId,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.seriesId <= 0) {
      return InvalidRoutePage(
        title: 'sonarr.SeriesDetails'.tr(),
        message: 'sonarr.SeriesNotFound'.tr(),
      );
    }
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZebrraModule.SONARR,
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar:
          context.watch<SonarrState>().enabled ? _bottomNavigationBar() : null,
      body: _body(),
    );
  }

  Widget _appBar() {
    List<Widget>? _actions;

    if (series != null) {
      _actions = [
        ZebrraIconButton(
          icon: ZebrraIcons.LINK,
          onPressed: () => LinksSheet(series: series!).show(),
        ),
        ZebrraIconButton(
          icon: ZebrraIcons.EDIT,
          onPressed: () {
            SonarrRoutes.SERIES_EDIT.go(
              params: {'series': widget.seriesId.toString()},
            );
          },
        ),
        SonarrAppBarSeriesSettingsAction(seriesId: widget.seriesId),
      ];
    }
    return ZebrraAppBar(
      title: 'sonarr.SeriesDetails'.tr(),
      scrollControllers: SonarrSeriesDetailsNavigationBar.scrollControllers,
      pageController: _pageController,
      actions: _actions,
    );
  }

  Widget? _bottomNavigationBar() {
    if (series == null) return null;
    return SonarrSeriesDetailsNavigationBar(
      pageController: _pageController,
    );
  }

  Widget _body() {
    return Consumer<SonarrState>(
      builder: (context, state, _) => FutureBuilder(
        future: Future.wait([
          state.qualityProfiles!,
          state.languageProfiles!,
          state.tags!,
          state.series!,
        ]),
        builder: (context, AsyncSnapshot<List<Object>> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting) {
              ZebrraLogger().error(
                'Unable to pull Sonarr series details',
                snapshot.error,
                snapshot.stackTrace,
              );
            }
            return ZebrraMessage.error(onTap: loadCallback);
          }
          if (snapshot.hasData) {
            series =
                (snapshot.data![3] as Map<int, SonarrSeries>)[widget.seriesId];
            if (series == null) {
              return ZebrraMessage.goBack(
                text: 'sonarr.SeriesNotFound'.tr(),
                context: context,
              );
            }
            SonarrQualityProfile? quality = _findQualityProfile(
              series!.qualityProfileId,
              snapshot.data![0] as List<SonarrQualityProfile>,
            );
            SonarrLanguageProfile? language = _findLanguageProfile(
              series!.languageProfileId,
              snapshot.data![1] as List<SonarrLanguageProfile>,
            );
            List<SonarrTag> tags =
                _findTags(series!.tags, snapshot.data![2] as List<SonarrTag>);
            return _pages(
              qualityProfile: quality,
              languageProfile: language,
              tags: tags,
            );
          }
          return const ZebrraLoader();
        },
      ),
    );
  }

  Widget _pages({
    required SonarrQualityProfile? qualityProfile,
    required SonarrLanguageProfile? languageProfile,
    required List<SonarrTag> tags,
  }) {
    return ChangeNotifierProvider(
      create: (context) => SonarrSeriesDetailsState(
        context: context,
        series: series!,
      ),
      builder: (context, _) => ZebrraPageView(
        controller: _pageController,
        children: [
          SonarrSeriesDetailsOverviewPage(
            series: series!,
            qualityProfile: qualityProfile,
            languageProfile: languageProfile,
            tags: tags,
          ),
          SonarrSeriesDetailsSeasonsPage(series: series),
          const SonarrSeriesDetailsHistoryPage(),
        ],
      ),
    );
  }
}
