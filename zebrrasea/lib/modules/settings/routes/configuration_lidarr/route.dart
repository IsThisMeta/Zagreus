import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/lidarr.dart';
import 'package:zebrrasea/router/routes/settings.dart';

class ConfigurationLidarrRoute extends StatefulWidget {
  const ConfigurationLidarrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationLidarrRoute> createState() => _State();
}

class _State extends State<ConfigurationLidarrRoute>
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
      title: ZebrraModule.LIDARR.title,
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        ZebrraModule.LIDARR.informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
        ZebrraDivider(),
        _defaultPagesPage(),
        //_defaultPagesPage(),
      ],
    );
  }

  Widget _enabledToggle() {
    return ZebrraBox.profiles.listenableBuilder(
      builder: (context, _) => ZebrraBlock(
        title: 'settings.EnableModule'.tr(args: [ZebrraModule.LIDARR.title]),
        trailing: ZebrraSwitch(
          value: ZebrraProfile.current.lidarrEnabled,
          onChanged: (value) {
            ZebrraProfile.current.lidarrEnabled = value;
            ZebrraProfile.current.save();
            context.read<LidarrState>().reset();
          },
        ),
      ),
    );
  }

  Widget _connectionDetailsPage() {
    return ZebrraBlock(
      title: 'settings.ConnectionDetails'.tr(),
      body: [
        TextSpan(
          text: 'settings.ConnectionDetailsDescription'.tr(
            args: [ZebrraModule.LIDARR.title],
          ),
        ),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_LIDARR_CONNECTION_DETAILS.go,
    );
  }

  Widget _defaultPagesPage() {
    return ZebrraBlock(
      title: 'settings.DefaultPages'.tr(),
      body: [TextSpan(text: 'settings.DefaultPagesDescription'.tr())],
      trailing: const ZebrraIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_LIDARR_DEFAULT_PAGES.go,
    );
  }
}
