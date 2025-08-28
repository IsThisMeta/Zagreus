import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/nzbget.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/router/routes/settings.dart';

class ConfigurationNZBGetConnectionDetailsRoute extends StatefulWidget {
  const ConfigurationNZBGetConnectionDetailsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationNZBGetConnectionDetailsRoute> createState() => _State();
}

class _State extends State<ConfigurationNZBGetConnectionDetailsRoute>
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
          _username(),
          _password(),
          _customHeaders(),
        ],
      ),
    );
  }

  Widget _host() {
    String host = ZagProfile.current.nzbgetHost;
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
          ZagProfile.current.nzbgetHost = _values.item2;
          ZagProfile.current.save();
          context.read<NZBGetState>().reset();
        }
      },
    );
  }

  Widget _username() {
    String username = ZagProfile.current.nzbgetUser;
    return ZagBlock(
      title: 'settings.Username'.tr(),
      body: [
        TextSpan(text: username.isEmpty ? 'zagreus.NotSet'.tr() : username),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await ZagDialogs().editText(
          context,
          'settings.Username'.tr(),
          prefill: username,
        );
        if (_values.item1) {
          ZagProfile.current.nzbgetUser = _values.item2;
          ZagProfile.current.save();
          context.read<NZBGetState>().reset();
        }
      },
    );
  }

  Widget _password() {
    String password = ZagProfile.current.nzbgetPass;
    return ZagBlock(
      title: 'settings.Password'.tr(),
      body: [
        TextSpan(
          text: password.isEmpty
              ? 'zagreus.NotSet'.tr()
              : ZagUI.TEXT_OBFUSCATED_PASSWORD,
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> _values = await ZagDialogs().editText(
          context,
          'settings.Password'.tr(),
          prefill: password,
          extraText: [
            ZagDialog.textSpanContent(
              text: '${ZagUI.TEXT_BULLET} ${'settings.PasswordHint1'.tr()}',
            ),
          ],
        );
        if (_values.item1) {
          ZagProfile.current.nzbgetPass = _values.item2;
          ZagProfile.current.save();
          context.read<NZBGetState>().reset();
        }
      },
    );
  }

  Widget _testConnection() {
    return ZagButton.text(
      text: 'settings.TestConnection'.tr(),
      icon: ZagIcons.CONNECTION_TEST,
      onTap: () async {
        ZagProfile _profile = ZagProfile.current;
        if (_profile.nzbgetHost.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.HostRequired'.tr(),
            message: 'settings.HostRequiredMessage'
                .tr(args: [ZagModule.NZBGET.title]),
          );
          return;
        }
        NZBGetAPI.from(ZagProfile.current)
            .testConnection()
            .then((_) => showZagSuccessSnackBar(
                  title: 'settings.ConnectedSuccessfully'.tr(),
                  message: 'settings.ConnectedSuccessfullyMessage'
                      .tr(args: [ZagModule.NZBGET.title]),
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
      onTap: SettingsRoutes.CONFIGURATION_NZBGET_CONNECTION_DETAILS_HEADERS.go,
    );
  }
}
