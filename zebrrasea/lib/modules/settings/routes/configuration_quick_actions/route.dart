import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/system/quick_actions/quick_actions.dart';

class ConfigurationQuickActionsRoute extends StatefulWidget {
  const ConfigurationQuickActionsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationQuickActionsRoute> createState() => _State();
}

class _State extends State<ConfigurationQuickActionsRoute>
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
      scrollControllers: [scrollController],
      title: 'settings.QuickActions'.tr(),
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        SettingsBanners.QUICK_ACTIONS_SUPPORT.banner(),
        _actionTile(
          ZebrraModule.LIDARR.title,
          ZebrraSeaDatabase.QUICK_ACTIONS_LIDARR,
        ),
        _actionTile(
          ZebrraModule.NZBGET.title,
          ZebrraSeaDatabase.QUICK_ACTIONS_NZBGET,
        ),
        if (ZebrraModule.OVERSEERR.featureFlag)
          _actionTile(
            ZebrraModule.OVERSEERR.title,
            ZebrraSeaDatabase.QUICK_ACTIONS_OVERSEERR,
          ),
        _actionTile(
          ZebrraModule.RADARR.title,
          ZebrraSeaDatabase.QUICK_ACTIONS_RADARR,
        ),
        _actionTile(
          ZebrraModule.SABNZBD.title,
          ZebrraSeaDatabase.QUICK_ACTIONS_SABNZBD,
        ),
        _actionTile(
          ZebrraModule.SEARCH.title,
          ZebrraSeaDatabase.QUICK_ACTIONS_SEARCH,
        ),
        _actionTile(
          ZebrraModule.SONARR.title,
          ZebrraSeaDatabase.QUICK_ACTIONS_SONARR,
        ),
        _actionTile(
          ZebrraModule.TAUTULLI.title,
          ZebrraSeaDatabase.QUICK_ACTIONS_TAUTULLI,
        ),
      ],
    );
  }

  Widget _actionTile(String title, ZebrraSeaDatabase action) {
    return ZebrraBlock(
      title: title,
      trailing: ZebrraBox.zebrrasea.listenableBuilder(
        selectKeys: [action.key],
        builder: (context, _) => ZebrraSwitch(
          value: action.read(),
          onChanged: (value) {
            action.update(value);
            if (ZebrraQuickActions.isSupported)
              ZebrraQuickActions().setActionItems();
          },
        ),
      ),
    );
  }
}
