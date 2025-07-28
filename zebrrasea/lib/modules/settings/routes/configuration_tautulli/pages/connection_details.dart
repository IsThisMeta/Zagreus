import 'package:flutter/material.dart';
import 'package:zebrrasea/core.dart';
import 'package:zebrrasea/modules/settings.dart';
import 'package:zebrrasea/modules/tautulli.dart';
import 'package:zebrrasea/router/routes/settings.dart';

class ConfigurationTautulliConnectionDetailsRoute extends StatefulWidget {
  const ConfigurationTautulliConnectionDetailsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationTautulliConnectionDetailsRoute> createState() => _State();
}

class _State extends State<ConfigurationTautulliConnectionDetailsRoute>
    with ZebrraScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZebrraScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  PreferredSizeWidget _appBar() {
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
    String host = ZebrraProfile.current.tautulliHost;
    return ZebrraBlock(
      title: 'settings.Host'.tr(),
      body: [TextSpan(text: host.isEmpty ? 'zebrrasea.NotSet'.tr() : host)],
      trailing: const ZebrraIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await SettingsDialogs().editHost(
          context,
          prefill: ZebrraProfile.current.tautulliHost,
        );
        if (_values.item1) {
          ZebrraProfile.current.tautulliHost = _values.item2;
          ZebrraProfile.current.save();
          context.read<TautulliState>().reset();
        }
      },
    );
  }

  Widget _apiKey() {
    String apiKey = ZebrraProfile.current.tautulliKey;
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
          prefill: ZebrraProfile.current.tautulliKey,
        );
        if (_values.item1) {
          ZebrraProfile.current.tautulliKey = _values.item2;
          ZebrraProfile.current.save();
          context.read<TautulliState>().reset();
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
        if (_profile.tautulliHost.isEmpty) {
          showZebrraErrorSnackBar(
            title: 'settings.HostRequired'.tr(),
            message: 'settings.HostRequiredMessage'
                .tr(args: [ZebrraModule.TAUTULLI.title]),
          );
          return;
        }
        if (_profile.tautulliKey.isEmpty) {
          showZebrraErrorSnackBar(
            title: 'settings.ApiKeyRequired'.tr(),
            message: 'settings.ApiKeyRequiredMessage'
                .tr(args: [ZebrraModule.TAUTULLI.title]),
          );
          return;
        }
        TautulliAPI(
                host: _profile.tautulliHost,
                apiKey: _profile.tautulliKey,
                headers: Map<String, dynamic>.from(_profile.tautulliHeaders))
            .miscellaneous
            .arnold()
            .then((_) => showZebrraSuccessSnackBar(
                  title: 'settings.ConnectedSuccessfully'.tr(),
                  message: 'settings.ConnectedSuccessfullyMessage'
                      .tr(args: [ZebrraModule.TAUTULLI.title]),
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
      onTap:
          SettingsRoutes.CONFIGURATION_TAUTULLI_CONNECTION_DETAILS_HEADERS.go,
    );
  }
}
