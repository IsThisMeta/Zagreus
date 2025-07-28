import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sabnzbd.dart';
import 'package:zebrrasea/router/routes/settings.dart';

class ConfigurationSABnzbdRoute extends StatefulWidget {
  const ConfigurationSABnzbdRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationSABnzbdRoute> createState() => _State();
}

class _State extends State<ConfigurationSABnzbdRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZebrraAppBar(
      title: ZebrraModule.SABNZBD.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZebrraListView(
      controller: scrollController,
      children: [
        ZebrraModule.SABNZBD.informationBanner(),
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
        title: 'settings.EnableModule'.tr(args: [ZebrraModule.SABNZBD.title]),
        trailing: ZebrraSwitch(
          value: ZebrraProfile.current.sabnzbdEnabled,
          onChanged: (value) {
            ZebrraProfile.current.sabnzbdEnabled = value;
            ZebrraProfile.current.save();
            context.read<SABnzbdState>().reset();
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
            args: [ZebrraModule.SABNZBD.title],
          ),
        )
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SABNZBD_CONNECTION_DETAILS.go,
    );
  }

  Widget _defaultPagesPage() {
    return ZebrraBlock(
      title: 'settings.DefaultPages'.tr(),
      body: [TextSpan(text: 'settings.DefaultPagesDescription'.tr())],
      trailing: const ZebrraIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SABNZBD_DEFAULT_PAGES.go,
    );
  }
}
