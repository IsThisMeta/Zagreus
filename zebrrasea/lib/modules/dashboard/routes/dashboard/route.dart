import 'package:flutter/material.dart';

import 'package:zebrrasea/modules.dart';
import 'package:zebrrasea/database/tables/dashboard.dart';
import 'package:zebrrasea/database/tables/zebrrasea.dart';
import 'package:zebrrasea/widgets/ui.dart';
import 'package:zebrrasea/modules/dashboard/routes/dashboard/pages/calendar.dart';
import 'package:zebrrasea/modules/dashboard/routes/dashboard/pages/modules.dart';
import 'package:zebrrasea/modules/dashboard/routes/dashboard/widgets/switch_view_action.dart';
import 'package:zebrrasea/modules/dashboard/routes/dashboard/widgets/navigation_bar.dart';

class DashboardRoute extends StatefulWidget {
  const DashboardRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<DashboardRoute> createState() => _State();
}

class _State extends State<DashboardRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ZebrraPageController? _pageController;

  @override
  void initState() {
    super.initState();

    int page = DashboardDatabase.NAVIGATION_INDEX.read();
    _pageController = ZebrraPageController(initialPage: page);
  }

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZebrraModule.DASHBOARD,
      body: _body(),
      appBar: _appBar(),
      drawer: ZebrraDrawer(page: ZebrraModule.DASHBOARD.key),
      bottomNavigationBar: HomeNavigationBar(pageController: _pageController),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZebrraAppBar(
      title: 'ZebrraSea',
      useDrawer: true,
      scrollControllers: HomeNavigationBar.scrollControllers,
      pageController: _pageController,
      actions: [SwitchViewAction(pageController: _pageController)],
    );
  }

  Widget _body() {
    return ZebrraSeaDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) => ZebrraPageView(
        controller: _pageController,
        children: [
          ModulesPage(key: ValueKey(ZebrraSeaDatabase.ENABLED_PROFILE.read())),
          CalendarPage(key: ValueKey(ZebrraSeaDatabase.ENABLED_PROFILE.read())),
        ],
      ),
    );
  }
}
