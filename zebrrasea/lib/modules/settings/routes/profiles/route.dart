import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/utils/profile_tools.dart';

class ProfilesRoute extends StatefulWidget {
  const ProfilesRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfilesRoute> createState() => _State();
}

class _State extends State<ProfilesRoute> with ZebrraScrollControllerMixin {
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
      title: 'settings.Profiles'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        SettingsBanners.PROFILES_SUPPORT.banner(),
        _enabledProfile(),
        _addProfile(),
        _renameProfile(),
        _deleteProfile(),
      ],
    );
  }

  Widget _addProfile() {
    return ZebrraBlock(
      title: 'settings.AddProfile'.tr(),
      body: [TextSpan(text: 'settings.AddProfileDescription'.tr())],
      trailing: const ZebrraIconButton(icon: ZebrraIcons.ADD),
      onTap: () async {
        final dialogs = SettingsDialogs();
        final context = ZebrraState.context;
        final profiles = ZebrraProfile.list;

        final selected = await dialogs.addProfile(context, profiles);
        if (selected.item1) {
          ZebrraProfileTools().create(selected.item2);
        }
      },
    );
  }

  Widget _renameProfile() {
    return ZebrraBlock(
      title: 'settings.RenameProfile'.tr(),
      body: [TextSpan(text: 'settings.RenameProfileDescription'.tr())],
      trailing: const ZebrraIconButton(icon: ZebrraIcons.RENAME),
      onTap: () async {
        final dialogs = SettingsDialogs();
        final context = ZebrraState.context;
        final profiles = ZebrraProfile.list;

        final selected = await dialogs.renameProfile(context, profiles);
        if (selected.item1) {
          final name = await dialogs.renameProfileSelected(context, profiles);
          if (name.item1) {
            ZebrraProfileTools().rename(selected.item2, name.item2);
          }
        }
      },
    );
  }

  Widget _deleteProfile() {
    return ZebrraBlock(
        title: 'settings.DeleteProfile'.tr(),
        body: [TextSpan(text: 'settings.DeleteProfileDescription'.tr())],
        trailing: const ZebrraIconButton(icon: ZebrraIcons.DELETE),
        onTap: () async {
          final dialogs = SettingsDialogs();
          final enabledProfile = ZebrraSeaDatabase.ENABLED_PROFILE.read();
          final context = ZebrraState.context;
          final profiles = ZebrraProfile.list;
          profiles.removeWhere((p) => p == enabledProfile);

          if (profiles.isEmpty) {
            showZebrraInfoSnackBar(
              title: 'settings.NoProfilesFound'.tr(),
              message: 'settings.NoAdditionalProfilesAdded'.tr(),
            );
            return;
          }

          final selected = await dialogs.deleteProfile(context, profiles);
          if (selected.item1) {
            ZebrraProfileTools().remove(selected.item2);
          }
        });
  }

  Widget _enabledProfile() {
    const db = ZebrraSeaDatabase.ENABLED_PROFILE;
    return db.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'settings.EnabledProfile'.tr(),
        body: [TextSpan(text: db.read())],
        trailing: const ZebrraIconButton(icon: ZebrraIcons.USER),
        onTap: () async {
          final dialogs = SettingsDialogs();
          final enabledProfile = ZebrraSeaDatabase.ENABLED_PROFILE.read();
          final context = ZebrraState.context;
          final profiles = ZebrraProfile.list;
          profiles.removeWhere((p) => p == enabledProfile);

          if (profiles.isEmpty) {
            showZebrraInfoSnackBar(
              title: 'settings.NoProfilesFound'.tr(),
              message: 'settings.NoAdditionalProfilesAdded'.tr(),
            );
            return;
          }

          final selected = await dialogs.enabledProfile(context, profiles);
          if (selected.item1) {
            ZebrraProfileTools().changeTo(selected.item2);
          }
        },
      ),
    );
  }
}
