import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/sabnzbd.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/router/routes/settings.dart';

class ConfigurationSABnzbdConnectionDetailsRoute extends StatefulWidget {
  const ConfigurationSABnzbdConnectionDetailsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationSABnzbdConnectionDetailsRoute> createState() => _State();
}

class _State extends State<ConfigurationSABnzbdConnectionDetailsRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  Widget _appBar() {
    return ZebrraAppBar(
      title: 'settings.ConnectionDetails'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZebrraBottomActionBar(
      actions: [
        _testConnection(),
      ],
    );
  }

  Widget _body() {
    return ZebrraBox.profiles.listenableBuilder(
      builder: (context, _) => ZebrraListView(
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
    String host = ZebrraProfile.current.sabnzbdHost;
    return ZebrraBlock(
      title: 'settings.Host'.tr(),
      body: [TextSpan(text: host.isEmpty ? 'zebrrasea.NotSet'.tr() : host)],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await SettingsDialogs().editHost(
          context,
          prefill: host,
        );
        if (_values.item1) {
          ZebrraProfile.current.sabnzbdHost = _values.item2;
          ZebrraProfile.current.save();
          context.read<SABnzbdState>().reset();
        }
      },
    );
  }

  Widget _apiKey() {
    String apiKey = ZebrraProfile.current.sabnzbdKey;
    return ZebrraBlock(
      title: 'settings.ApiKey'.tr(),
      body: [
        TextSpan(
          text: apiKey.isEmpty
              ? 'zebrrasea.NotSet'.tr()
              : ZebrraUI.TEXT_OBFUSCATED_PASSWORD,
        ),
      ],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await ZebrraDialogs().editText(
          context,
          'settings.ApiKey'.tr(),
          prefill: apiKey,
        );
        if (_values.item1) {
          ZebrraProfile.current.sabnzbdKey = _values.item2;
          ZebrraProfile.current.save();
          context.read<SABnzbdState>().reset();
        }
      },
    );
  }

  Widget _testConnection() {
    return ZebrraButton.text(
      text: 'settings.TestConnection'.tr(),
      icon: Icons.wifi_tethering_rounded,
      onTap: () async {
        ZebrraProfile _profile = ZebrraProfile.current;
        if (_profile.sabnzbdHost.isEmpty) {
          showZebrraErrorSnackBar(
            title: 'settings.HostRequired'.tr(),
            message: 'settings.HostRequiredMessage'
                .tr(args: [ZebrraModule.SABNZBD.title]),
          );
          return;
        }
        if (_profile.sabnzbdKey.isEmpty) {
          showZebrraErrorSnackBar(
            title: 'settings.ApiKeyRequired'.tr(),
            message: 'settings.ApiKeyRequiredMessage'
                .tr(args: [ZebrraModule.SABNZBD.title]),
          );
          return;
        }
        SABnzbdAPI.from(ZebrraProfile.current)
            .testConnection()
            .then((_) => showZebrraSuccessSnackBar(
                  title: 'settings.ConnectedSuccessfully'.tr(),
                  message: 'settings.ConnectedSuccessfullyMessage'
                      .tr(args: [ZebrraModule.SABNZBD.title]),
                ))
            .catchError((error, trace) {
          ZebrraLogger().error('Connection Test Failed', error, trace);
          showZebrraErrorSnackBar(
            title: 'settings.ConnectionTestFailed'.tr(),
            error: error,
          );
        });
      },
    );
  }

  Widget _customHeaders() {
    return ZebrraBlock(
      title: 'settings.CustomHeaders'.tr(),
      body: [TextSpan(text: 'settings.CustomHeadersDescription'.tr())],
      trailing: const ZebrraIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_SABNZBD_CONNECTION_DETAILS_HEADERS.go,
    );
  }
}
