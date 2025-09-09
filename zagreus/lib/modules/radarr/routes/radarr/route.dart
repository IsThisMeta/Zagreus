import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/settings.dart';

class RadarrRoute extends StatefulWidget {
  const RadarrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<RadarrRoute> createState() => _State();
}

class _State extends State<RadarrRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = ZagPageController(
      initialPage: RadarrDatabase.NAVIGATION_INDEX.read(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.RADARR,
      drawer: _drawer(),
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      body: _body(),
    );
  }

  Widget _drawer() {
    return ZagDrawer(page: ZagModule.RADARR.key);
  }

  Widget? _bottomNavigationBar() {
    if (context.read<RadarrState>().enabled) {
      return RadarrNavigationBar(pageController: _pageController);
    }
    return null;
  }

  Widget _appBar() {
    List<String> profiles = ZagBox.profiles.keys.fold(
      [],
      (value, element) {
        if (ZagBox.profiles.read(element)?.radarrEnabled ?? false) {
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
    return ZagAppBar.dropdown(
      title: ZagModule.RADARR.title,
      useDrawer: true,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: RadarrNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    return Selector<RadarrState, Tuple2<bool, bool>>(
      selector: (_, state) => Tuple2(state.enabled, state.isConfigured),
      builder: (context, data, _) {
        final enabled = data.item1;
        final isConfigured = data.item2;
        
        if (!enabled) {
          return ZagMessage.moduleNotEnabled(
            context: context,
            module: 'Radarr',
          );
        }
        
        if (!isConfigured) {
          return ZagMessage(
            title: 'Configuration Required',
            body: 'Please configure your Radarr connection details in Settings.',
            icon: Icons.settings_rounded,
            buttonText: 'Go to Settings',
            onTap: () => SettingsRoutes.CONFIGURATION_RADARR.go(),
          );
        }
        
        return ZagPageView(
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
