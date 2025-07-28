import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sonarr.dart';

class SonarrRoute extends StatefulWidget {
  const SonarrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SonarrRoute> createState() => _State();
}

class _State extends State<SonarrRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZebrraPageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = ZebrraPageController(
      initialPage: SonarrDatabase.NAVIGATION_INDEX.read(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZebrraModule.SONARR,
      drawer: _drawer(),
      appBar: _appBar(),
      bottomNavigationBar: _bottomNavigationBar(),
      body: _body(),
    );
  }

  Widget _drawer() {
    return ZebrraDrawer(page: ZebrraModule.SONARR.key);
  }

  Widget? _bottomNavigationBar() {
    if (context.read<SonarrState>().enabled) {
      return SonarrNavigationBar(pageController: _pageController);
    }
    return null;
  }

  PreferredSizeWidget _appBar() {
    List<String> profiles = ZebrraBox.profiles.keys.fold(
      [],
      (value, element) {
        if (ZebrraBox.profiles.read(element)?.sonarrEnabled ?? false) {
          value.add(element);
        }
        return value;
      },
    );
    List<Widget>? actions;
    if (context.watch<SonarrState>().enabled) {
      actions = [
        const SonarrAppBarAddSeriesAction(),
        const SonarrAppBarGlobalSettingsAction(),
      ];
    }
    return ZebrraAppBar.dropdown(
      title: ZebrraModule.SONARR.title,
      useDrawer: true,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: SonarrNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    return Selector<SonarrState, bool?>(
      selector: (_, state) => state.enabled,
      builder: (context, enabled, _) {
        if (!enabled!) {
          return ZebrraMessage.moduleNotEnabled(
            context: context,
            module: 'Sonarr',
          );
        }
        return ZebrraPageView(
          controller: _pageController,
          children: const [
            SonarrCatalogueRoute(),
            SonarrUpcomingRoute(),
            SonarrMissingRoute(),
            SonarrMoreRoute(),
          ],
        );
      },
    );
  }
}
