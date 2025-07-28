import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/tautulli.dart';

class ConfigurationTautulliDefaultPagesRoute extends StatefulWidget {
  const ConfigurationTautulliDefaultPagesRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationTautulliDefaultPagesRoute> createState() => _State();
}

class _State extends State<ConfigurationTautulliDefaultPagesRoute>
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
      title: 'settings.DefaultPages'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        _homePage(),
        _graphsPage(),
        _libraryDetailsPage(),
        _mediaDetailsPage(),
        _userDetailsPage(),
      ],
    );
  }

  Widget _homePage() {
    const _db = TautulliDatabase.NAVIGATION_INDEX;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'zebrrasea.Home'.tr(),
        body: [TextSpan(text: TautulliNavigationBar.titles[_db.read()])],
        trailing: ZebrraIconButton(icon: TautulliNavigationBar.icons[_db.read()]),
        onTap: () async {
          List values = await TautulliDialogs.setDefaultPage(
            context,
            titles: TautulliNavigationBar.titles,
            icons: TautulliNavigationBar.icons,
          );
          if (values[0]) _db.update(values[1]);
        },
      ),
    );
  }

  Widget _graphsPage() {
    const _db = TautulliDatabase.NAVIGATION_INDEX_GRAPHS;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'tautulli.Graphs'.tr(),
        body: [TextSpan(text: TautulliGraphsNavigationBar.titles[_db.read()])],
        trailing:
            ZebrraIconButton(icon: TautulliGraphsNavigationBar.icons[_db.read()]),
        onTap: () async {
          List values = await TautulliDialogs.setDefaultPage(
            context,
            titles: TautulliGraphsNavigationBar.titles,
            icons: TautulliGraphsNavigationBar.icons,
          );
          if (values[0]) _db.update(values[1]);
        },
      ),
    );
  }

  Widget _libraryDetailsPage() {
    const _db = TautulliDatabase.NAVIGATION_INDEX_LIBRARIES_DETAILS;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'tautulli.LibraryDetails'.tr(),
        body: [
          TextSpan(
              text: TautulliLibrariesDetailsNavigationBar.titles[_db.read()])
        ],
        trailing: ZebrraIconButton(
            icon: TautulliLibrariesDetailsNavigationBar.icons[_db.read()]),
        onTap: () async {
          List values = await TautulliDialogs.setDefaultPage(
            context,
            titles: TautulliLibrariesDetailsNavigationBar.titles,
            icons: TautulliLibrariesDetailsNavigationBar.icons,
          );
          if (values[0]) _db.update(values[1]);
        },
      ),
    );
  }

  Widget _mediaDetailsPage() {
    const _db = TautulliDatabase.NAVIGATION_INDEX_MEDIA_DETAILS;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'tautulli.MediaDetails'.tr(),
        body: [
          TextSpan(text: TautulliMediaDetailsNavigationBar.titles[_db.read()]),
        ],
        trailing: ZebrraIconButton(
            icon: TautulliMediaDetailsNavigationBar.icons[_db.read()]),
        onTap: () async {
          List values = await TautulliDialogs.setDefaultPage(
            context,
            titles: TautulliMediaDetailsNavigationBar.titles,
            icons: TautulliMediaDetailsNavigationBar.icons,
          );
          if (values[0]) _db.update(values[1]);
        },
      ),
    );
  }

  Widget _userDetailsPage() {
    const _db = TautulliDatabase.NAVIGATION_INDEX_USER_DETAILS;
    return _db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'tautulli.UserDetails'.tr(),
        body: [
          TextSpan(text: TautulliUserDetailsNavigationBar.titles[_db.read()]),
        ],
        trailing: ZebrraIconButton(
            icon: TautulliUserDetailsNavigationBar.icons[_db.read()]),
        onTap: () async {
          List values = await TautulliDialogs.setDefaultPage(
            context,
            titles: TautulliUserDetailsNavigationBar.titles,
            icons: TautulliUserDetailsNavigationBar.icons,
          );
          if (values[0]) _db.update(values[1]);
        },
      ),
    );
  }
}
