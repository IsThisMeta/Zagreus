import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sabnzbd.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/router/routes/settings.dart';

class ConfigurationSABnzbdConnectionDetailsRoute extends StatefulWidget {
  const ConfigurationSABnzbdConnectionDetailsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationSABnzbdConnectionDetailsRoute> createState() => _State();
}

class _State extends State<ConfigurationSABnzbdConnectionDetailsRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'settings.ConnectionDetails'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        _testConnection(),
      ],
    );
  }

  Widget _body() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagListView(
        controller: scrollController,
        children: [
          _host(),
          _apiKey(),
          _customHeaders(),
        ],
      ),
    );
  }

  Widget _host() {
    String host = ZagProfile.current.sabnzbdHost;
    return ZagBlock(
      title: 'settings.Host'.tr(),
      body: [TextSpan(text: host.isEmpty ? 'zagreus.NotSet'.tr() : host)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await SettingsDialogs().editHost(
          context,
          prefill: host,
        );
        if (_values.item1) {
          ZagProfile.current.sabnzbdHost = _values.item2;
          ZagProfile.current.save();
          context.read<SABnzbdState>().reset();
        }
      },
    );
  }

  Widget _apiKey() {
    String apiKey = ZagProfile.current.sabnzbdKey;
    return ZagBlock(
      title: 'settings.ApiKey'.tr(),
      body: [
        TextSpan(
          text: apiKey.isEmpty
              ? 'zagreus.NotSet'.tr()
              : ZagUI.TEXT_OBFUSCATED_PASSWORD,
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await ZagDialogs().editText(
          context,
          'settings.ApiKey'.tr(),
          prefill: apiKey,
        );
        if (_values.item1) {
          ZagProfile.current.sabnzbdKey = _values.item2;
          ZagProfile.current.save();
          context.read<SABnzbdState>().reset();
        }
      },
    );
  }

  Widget _testConnection() {
    return ZagButton.text(
      text: 'settings.TestConnection'.tr(),
      icon: Icons.wifi_tethering_rounded,
      onTap: () async {
        ZagProfile _profile = ZagProfile.current;
        if (_profile.sabnzbdHost.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.HostRequired'.tr(),
            message: 'settings.HostRequiredMessage'
                .tr(args: [ZagModule.SABNZBD.title]),
          );
          return;
        }
        if (_profile.sabnzbdKey.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.ApiKeyRequired'.tr(),
            message: 'settings.ApiKeyRequiredMessage'
                .tr(args: [ZagModule.SABNZBD.title]),
          );
          return;
        }
        SABnzbdAPI.from(ZagProfile.current)
            .testConnection()
            .then((_) => showZagSuccessSnackBar(
                  title: 'settings.ConnectedSuccessfully'.tr(),
                  message: 'settings.ConnectedSuccessfullyMessage'
                      .tr(args: [ZagModule.SABNZBD.title]),
                ))
            .catchError((error, trace) {
          ZagLogger().error('Connection Test Failed', error, trace);
          showZagErrorSnackBar(
            title: 'settings.ConnectionTestFailed'.tr(),
            error: error,
          );
        });
      },
    );
  }

  Widget _customHeaders() {
    return ZagBlock(
      title: 'settings.CustomHeaders'.tr(),
      body: [TextSpan(text: 'settings.CustomHeadersDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SABNZBD_CONNECTION_DETAILS_HEADERS.go,
    );
  }
}
