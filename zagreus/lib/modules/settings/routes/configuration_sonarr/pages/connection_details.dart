import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';
import 'package:zagreus/modules/sonarr/core/webhook_manager.dart';

class ConfigurationSonarrConnectionDetailsRoute extends StatefulWidget {
  const ConfigurationSonarrConnectionDetailsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationSonarrConnectionDetailsRoute> createState() => _State();
}

class _State extends State<ConfigurationSonarrConnectionDetailsRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  PreferredSizeWidget _appBar() {
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
    String host = ZagProfile.current.sonarrHost;
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
          ZagProfile.current.sonarrHost = _values.item2;
          ZagProfile.current.save();
          context.read<SonarrState>().reset();
          // Sync webhook if user is authenticated
          _syncWebhook();
        }
      },
    );
  }

  Widget _apiKey() {
    String apiKey = ZagProfile.current.sonarrKey;
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
          ZagProfile.current.sonarrKey = _values.item2;
          ZagProfile.current.save();
          context.read<SonarrState>().reset();
          // Sync webhook if user is authenticated
          _syncWebhook();
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
        if (_profile.sonarrHost.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.HostRequired'.tr(),
            message: 'settings.HostRequiredMessage'
                .tr(args: [ZagModule.SONARR.title]),
          );
          return;
        }
        if (_profile.sonarrKey.isEmpty) {
          showZagErrorSnackBar(
            title: 'settings.ApiKeyRequired'.tr(),
            message: 'settings.ApiKeyRequiredMessage'
                .tr(args: [ZagModule.SONARR.title]),
          );
          return;
        }
        SonarrAPI(
          host: _profile.sonarrHost,
          apiKey: _profile.sonarrKey,
          headers: Map<String, dynamic>.from(
            _profile.sonarrHeaders,
          ),
        ).system.getStatus().then((_) {
          showZagSuccessSnackBar(
            title: 'settings.ConnectedSuccessfully'.tr(),
            message: 'settings.ConnectedSuccessfullyMessage'
                .tr(args: [ZagModule.SONARR.title]),
          );
          // Sync webhook after successful connection
          _syncWebhook();
        }).catchError((error, trace) {
          ZagLogger().error(
            'Connection Test Failed',
            error,
            trace,
          );
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
      onTap: SettingsRoutes.CONFIGURATION_SONARR_CONNECTION_DETAILS_HEADERS.go,
    );
  }

  void _syncWebhook() async {
    try {
      // Only sync if user is authenticated
      if (ZagSupabase.isSupported && ZagSupabase.client.auth.currentUser != null) {
        final profile = ZagProfile.current;
        if (profile.sonarrEnabled && profile.sonarrHost.isNotEmpty && profile.sonarrKey.isNotEmpty) {
          ZagLogger().debug('Syncing Sonarr webhook after configuration change');
          final api = SonarrAPI(
            host: profile.sonarrHost,
            apiKey: profile.sonarrKey,
            headers: Map<String, dynamic>.from(profile.sonarrHeaders),
          );
          await SonarrWebhookManager.syncWebhook(api);
        }
      }
    } catch (e, stack) {
      ZagLogger().error('Failed to sync webhook after configuration', e, stack);
    }
  }
}
