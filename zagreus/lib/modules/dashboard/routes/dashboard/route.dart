import 'package:flutter/material.dart';

import 'package:zagreus/modules.dart';
import 'package:zagreus/database/tables/dashboard.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/pages/calendar.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/pages/modules.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/switch_view_action.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/navigation_bar.dart';

class DashboardRoute extends StatefulWidget {
  const DashboardRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<DashboardRoute> createState() => _State();
}

class _State extends State<DashboardRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;

  @override
  void initState() {
    super.initState();

    int page = DashboardDatabase.NAVIGATION_INDEX.read();
    _pageController = ZagPageController(initialPage: page);
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.DASHBOARD,
      body: _body(),
      appBar: _appBar(),
      drawer: ZagDrawer(page: ZagModule.DASHBOARD.key),
      bottomNavigationBar: HomeNavigationBar(pageController: _pageController),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'Zagreus',
      useDrawer: true,
      scrollControllers: HomeNavigationBar.scrollControllers,
      pageController: _pageController,
      actions: [SwitchViewAction(pageController: _pageController)],
    );
  }

  Widget _body() {
    return ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) => ZagPageView(
        controller: _pageController,
        children: [
          ModulesPage(key: ValueKey(ZagreusDatabase.ENABLED_PROFILE.read())),
          CalendarPage(key: ValueKey(ZagreusDatabase.ENABLED_PROFILE.read())),
        ],
      ),
    );
  }
}
