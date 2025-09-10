import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/modules/radarr/core/webhook_manager.dart';

class ConfigurationRadarrRoute extends StatefulWidget {
  const ConfigurationRadarrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationRadarrRoute> createState() => _State();
}

class _State extends State<ConfigurationRadarrRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    // Sync webhook when page loads
    _syncWebhook();
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: ZagModule.RADARR.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagModule.RADARR.informationBanner(),
        if (_debugInfo.isNotEmpty) 
          ZagBlock(
            title: 'DEBUG: Webhook Sync',
            body: [TextSpan(text: _debugInfo, style: TextStyle(fontFamily: 'monospace'))],
          ),
        _enabledToggle(),
        _connectionDetailsPage(),
        ZagDivider(),
        _defaultOptionsPage(),
        _defaultPagesPage(),
        _discoverUseRadarrSuggestionsToggle(),
        _queueSize(),
      ],
    );
  }

  Widget _enabledToggle() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: [ZagModule.RADARR.title]),
        trailing: ZagSwitch(
          value: ZagProfile.current.radarrEnabled,
          onChanged: (value) {
            ZagProfile.current.radarrEnabled = value;
            ZagProfile.current.save();
            context.read<RadarrState>().reset();
          },
        ),
      ),
    );
  }

  Widget _connectionDetailsPage() {
    return ZagBlock(
      title: 'settings.ConnectionDetails'.tr(),
      body: [
        TextSpan(
          text: 'settings.ConnectionDetailsDescription'.tr(
            args: [ZagModule.RADARR.title],
          ),
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_RADARR_CONNECTION_DETAILS.go,
    );
  }

  Widget _defaultOptionsPage() {
    return ZagBlock(
      title: 'settings.DefaultOptions'.tr(),
      body: [TextSpan(text: 'settings.DefaultOptionsDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_RADARR_DEFAULT_OPTIONS.go,
    );
  }

  Widget _defaultPagesPage() {
    return ZagBlock(
      title: 'settings.DefaultPages'.tr(),
      body: [TextSpan(text: 'settings.DefaultPagesDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_RADARR_DEFAULT_PAGES.go,
    );
  }

  Widget _discoverUseRadarrSuggestionsToggle() {
    const _db = RadarrDatabase.ADD_DISCOVER_USE_SUGGESTIONS;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'radarr.DiscoverSuggestions'.tr(),
        body: [TextSpan(text: 'radarr.DiscoverSuggestionsDescription'.tr())],
        trailing: ZagSwitch(
          value: _db.read(),
          onChanged: (value) => _db.update(value),
        ),
      ),
    );
  }

  Widget _queueSize() {
    const _db = RadarrDatabase.QUEUE_PAGE_SIZE;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'radarr.QueueSize'.tr(),
        body: [
          TextSpan(
            text: _db.read() == 1
                ? 'zagreus.OneItem'.tr()
                : 'zagreus.Items'.tr(args: [_db.read().toString()]),
          ),
        ],
        trailing: const ZagIconButton(icon: Icons.queue_play_next_rounded),
        onTap: () async {
          Tuple2<bool, int> result =
              await RadarrDialogs().setQueuePageSize(context);
          if (result.item1) _db.update(result.item2);
        },
      ),
    );
  }

  void _syncWebhook() async {
    try {
      // Only sync if user is authenticated
      if (ZagSupabase.isSupported && ZagSupabase.client.auth.currentUser != null) {
        final profile = ZagProfile.current;
        setState(() {
          _debugInfo = 'Host: ${profile.radarrHost}\n'
              'API Key: ${profile.radarrKey.isEmpty ? "NOT SET" : "SET (${profile.radarrKey.length} chars)"}\n'
              'Enabled: ${profile.radarrEnabled}\n'
              'User ID: ${ZagSupabase.client.auth.currentUser?.id ?? "NO USER"}';
        });
        
        if (profile.radarrEnabled && profile.radarrHost.isNotEmpty && profile.radarrKey.isNotEmpty) {
          setState(() {
            _debugInfo += '\n\nAttempting webhook sync...';
          });
          
          final api = RadarrAPI(
            host: profile.radarrHost,
            apiKey: profile.radarrKey,
            headers: Map<String, dynamic>.from(profile.radarrHeaders),
          );
          
          final success = await RadarrWebhookManager.syncWebhook(api);
          setState(() {
            _debugInfo += '\nSync result: ${success ? "SUCCESS" : "FAILED"}';
          });
        } else {
          setState(() {
            _debugInfo += '\n\nSkipping sync - not fully configured';
          });
        }
      } else {
        setState(() {
          _debugInfo = 'Not authenticated or Supabase not supported';
        });
      }
    } catch (e, stack) {
      setState(() {
        _debugInfo += '\n\nERROR: $e';
      });
      ZagLogger().error('Failed to sync webhook on page load', e, stack);
    }
  }
}
