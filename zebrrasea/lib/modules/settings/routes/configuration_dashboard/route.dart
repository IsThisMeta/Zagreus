import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/router/routes/settings.dart';

class ConfigurationDashboardRoute extends StatefulWidget {
  const ConfigurationDashboardRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationDashboardRoute> createState() => _State();
}

class _State extends State<ConfigurationDashboardRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZebrraAppBar(
      title: 'Dashboard',
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        _calendarSettingsPage(),
        _defaultPagesPage(),
      ],
    );
  }

  Widget _defaultPagesPage() {
    return ZebrraBlock(
      title: 'settings.DefaultPages'.tr(),
      body: [TextSpan(text: 'settings.DefaultPagesDescription'.tr())],
      trailing: const ZebrraIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_DASHBOARD_DEFAULT_PAGES.go,
    );
  }

  Widget _calendarSettingsPage() {
    return ZebrraBlock(
      title: 'settings.CalendarSettings'.tr(),
      body: [TextSpan(text: 'settings.CalendarSettingsDescription'.tr())],
      trailing: const ZebrraIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_DASHBOARD_CALENDAR.go,
    );
  }
}
