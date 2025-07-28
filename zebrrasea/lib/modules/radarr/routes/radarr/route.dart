import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';

class RadarrRoute extends StatefulWidget {
  const RadarrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<RadarrRoute> createState() => _State();
}

class _State extends State<RadarrRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZebrraPageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = ZebrraPageController(
      initialPage: RadarrDatabase.NAVIGATION_INDEX.read(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZebrraModule.RADARR,
      drawer: _drawer(),
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      body: _body(),
    );
  }

  Widget _drawer() {
    return ZebrraDrawer(page: ZebrraModule.RADARR.key);
  }

  Widget? _bottomNavigationBar() {
    if (context.read<RadarrState>().enabled) {
      return RadarrNavigationBar(pageController: _pageController);
    }
    return null;
  }

  Widget _appBar() {
    List<String> profiles = ZebrraBox.profiles.keys.fold(
      [],
      (value, element) {
        if (ZebrraBox.profiles.read(element)?.radarrEnabled ?? false) {
          value.add(element);
        }
        return value;
      },
    );
    List<Widget>? actions;
    if (context.watch<RadarrState>().enabled) {
      actions = [
        const RadarrAppBarAddMoviesAction(),
        const RadarrAppBarGlobalSettingsAction(),
      ];
    }
    return ZebrraAppBar.dropdown(
      title: ZebrraModule.RADARR.title,
      useDrawer: true,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: RadarrNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    return Selector<RadarrState, bool?>(
      selector: (_, state) => state.enabled,
      builder: (context, enabled, _) {
        if (!enabled!) {
          return ZebrraMessage.moduleNotEnabled(
            context: context,
            module: 'Radarr',
          );
        }
        return ZebrraPageView(
          controller: _pageController,
          children: const [
            RadarrCatalogueRoute(),
            RadarrUpcomingRoute(),
            RadarrMissingRoute(),
            RadarrMoreRoute(),
          ],
        );
      },
    );
  }
}
