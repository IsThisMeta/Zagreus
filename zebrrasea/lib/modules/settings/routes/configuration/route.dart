import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/router/routes/settings.dart';
import 'package:zebrrasea/system/quick_actions/quick_actions.dart';
import 'package:zebrrasea/utils/profile_tools.dart';

class ConfigurationRoute extends StatefulWidget {
  const ConfigurationRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationRoute> createState() => _State();
}

class _State extends State<ConfigurationRoute> with ZebrraScrollControllerMixin {
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
      title: 'settings.Configuration'.tr(),
      scrollControllers: [scrollController],
      actions: [_enabledProfile()],
    );
  }

  Widget _enabledProfile() {
    return ZebrraBox.profiles.listenableBuilder(
      builder: (context, _) {
        if (ZebrraBox.profiles.size < 2) return const SizedBox();
        return ZebrraIconButton(
          icon: Icons.switch_account_rounded,
          onPressed: () async {
            final dialogs = SettingsDialogs();
            final enabledProfile = ZebrraSeaDatabase.ENABLED_PROFILE.read();
            final profiles = ZebrraProfile.list;
            profiles.removeWhere((p) => p == enabledProfile);

            if (profiles.isEmpty) {
              showZebrraInfoSnackBar(
                title: 'settings.NoProfilesFound'.tr(),
                message: 'settings.NoAdditionalProfilesAdded'.tr(),
              );
              return;
            }

            final selected = await dialogs.enabledProfile(
              ZebrraState.context,
              profiles,
            );
            if (selected.item1) {
              ZebrraProfileTools().changeTo(selected.item2);
            }
          },
        );
      },
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        ZebrraBlock(
          title: 'settings.General'.tr(),
          body: [TextSpan(text: 'settings.GeneralDescription'.tr())],
          trailing: const ZebrraIconButton(icon: Icons.brush_rounded),
          onTap: SettingsRoutes.CONFIGURATION_GENERAL.go,
        ),
        ZebrraBlock(
          title: 'settings.Drawer'.tr(),
          body: [TextSpan(text: 'settings.DrawerDescription'.tr())],
          trailing: const ZebrraIconButton(icon: Icons.menu_rounded),
          onTap: SettingsRoutes.CONFIGURATION_DRAWER.go,
        ),
        if (ZebrraQuickActions.isSupported)
          ZebrraBlock(
            title: 'settings.QuickActions'.tr(),
            body: [TextSpan(text: 'settings.QuickActionsDescription'.tr())],
            trailing: const ZebrraIconButton(icon: Icons.rounded_corner_rounded),
            onTap: SettingsRoutes.CONFIGURATION_QUICK_ACTIONS.go,
          ),
        ZebrraDivider(),
        ..._moduleList(),
      ],
    );
  }

  List<Widget> _moduleList() {
    return ([ZebrraModule.DASHBOARD, ...ZebrraModule.active])
        .map(_tileFromModuleMap)
        .toList();
  }

  Widget _tileFromModuleMap(ZebrraModule module) {
    return ZebrraBlock(
      title: module.title,
      body: [
        TextSpan(text: 'settings.ConfigureModule'.tr(args: [module.title]))
      ],
      trailing: ZebrraIconButton(icon: module.icon),
      onTap: module.settingsRoute!.go,
    );
  }
}
