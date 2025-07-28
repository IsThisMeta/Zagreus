import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class TautulliRoute extends StatefulWidget {
  const TautulliRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<TautulliRoute> createState() => _State();
}

class _State extends State<TautulliRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: TautulliDatabase.NAVIGATION_INDEX.read());
  }

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZebrraModule.TAUTULLI,
      drawer: _drawer(),
      appBar: _appBar(),
      bottomNavigationBar: _bottomNavigationBar(),
      body: _body(),
    );
  }

  Widget _drawer() => ZebrraDrawer(page: ZebrraModule.TAUTULLI.key);

  Widget? _bottomNavigationBar() {
    if (context.read<TautulliState>().enabled)
      return TautulliNavigationBar(pageController: _pageController);
    return null;
  }

  PreferredSizeWidget _appBar() {
    List<String> profiles = ZebrraBox.profiles.keys.fold([], (value, element) {
      if (ZebrraBox.profiles.read(element)?.tautulliEnabled ?? false)
        value.add(element);
      return value;
    });
    List<Widget>? actions;
    if (context.watch<TautulliState>().enabled)
      actions = [
        const TautulliAppBarGlobalSettingsAction(),
      ];
    return ZebrraAppBar.dropdown(
      title: ZebrraModule.TAUTULLI.title,
      useDrawer: true,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: TautulliNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    return Selector<TautulliState, bool?>(
      selector: (_, state) => state.enabled,
      builder: (context, enabled, _) {
        if (!enabled!)
          return ZebrraMessage.moduleNotEnabled(
              context: context, module: 'Tautulli');
        return ZebrraPageView(
          controller: _pageController,
          children: const [
            TautulliActivityRoute(),
            TautulliUsersRoute(),
            TautulliHistoryRoute(),
            TautulliMoreRoute(),
          ],
        );
      },
    );
  }
}
