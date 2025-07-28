import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/radarr.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/router/routes/settings.dart';

class ConfigurationRadarrConnectionDetailsRoute extends StatefulWidget {
  const ConfigurationRadarrConnectionDetailsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationRadarrConnectionDetailsRoute> createState() => _State();
}

class _State extends State<ConfigurationRadarrConnectionDetailsRoute>
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
    String host = ZebrraProfile.current.radarrHost;
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
          ZebrraProfile.current.radarrHost = _values.item2;
          ZebrraProfile.current.save();
          context.read<RadarrState>().reset();
        }
      },
    );
  }

  Widget _apiKey() {
    String apiKey = ZebrraProfile.current.radarrKey;
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
          ZebrraProfile.current.radarrKey = _values.item2;
          ZebrraProfile.current.save();
          context.read<RadarrState>().reset();
        }
      },
    );
  }

  Widget _testConnection() {
    return ZebrraButton.text(
      text: 'settings.TestConnection'.tr(),
      icon: ZebrraIcons.CONNECTION_TEST,
      onTap: () async {
        ZebrraProfile _profile = ZebrraProfile.current;
        if (_profile.radarrHost.isEmpty) {
          showZebrraErrorSnackBar(
            title: 'settings.HostRequired'.tr(),
            message: 'settings.HostRequiredMessage'
                .tr(args: [ZebrraModule.RADARR.title]),
          );
          return;
        }
        if (_profile.radarrKey.isEmpty) {
          showZebrraErrorSnackBar(
            title: 'settings.ApiKeyRequired'.tr(),
            message: 'settings.ApiKeyRequiredMessage'
                .tr(args: [ZebrraModule.RADARR.title]),
          );
          return;
        }
        RadarrAPI(
          host: _profile.radarrHost,
          apiKey: _profile.radarrKey,
          headers: Map<String, dynamic>.from(_profile.radarrHeaders),
        )
            .system
            .status()
            .then(
              (_) => showZebrraSuccessSnackBar(
                title: 'settings.ConnectedSuccessfully'.tr(),
                message: 'settings.ConnectedSuccessfullyMessage'
                    .tr(args: [ZebrraModule.RADARR.title]),
              ),
            )
            .catchError(
          (error, trace) {
            ZebrraLogger().error(
              'Connection Test Failed',
              error,
              trace,
            );
            showZebrraErrorSnackBar(
              title: 'settings.ConnectionTestFailed'.tr(),
              error: error,
            );
          },
        );
      },
    );
  }

  Widget _customHeaders() {
    return ZebrraBlock(
      title: 'settings.CustomHeaders'.tr(),
      body: [TextSpan(text: 'settings.CustomHeadersDescription'.tr())],
      trailing: const ZebrraIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_RADARR_CONNECTION_DETAILS_HEADERS.go,
    );
  }
}
