import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/messaging.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/database.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';
import 'package:zagreus/modules/radarr/core/webhook_manager.dart';
import 'package:zagreus/modules/sonarr/core/webhook_manager.dart';

class NotificationsRoute extends StatefulWidget {
  const NotificationsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<NotificationsRoute> createState() => _State();
}

class _State extends State<NotificationsRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Trigger webhook sync when page loads
    _syncWebhooksInBackground();
  }

  void _syncWebhooksInBackground() async {
    try {
      final profileName = ZagreusDatabase.ENABLED_PROFILE.read();
      final profile = ZagBox.profiles.read(profileName);
      
      if (profile == null || !ZagSupabase.isSupported || ZagSupabase.client.auth.currentUser == null) {
        return;
      }
      
      ZagLogger().debug('=== WEBHOOK SYNC TRIGGERED (Notifications Page) ===');
      
      // Sync Radarr if configured
      if (profile.radarrEnabled && profile.radarrHost.isNotEmpty && profile.radarrKey.isNotEmpty) {
        ZagLogger().debug('Syncing Radarr webhook...');
        try {
          final api = RadarrAPI(
            host: profile.radarrHost,
            apiKey: profile.radarrKey,
            headers: Map<String, dynamic>.from(profile.radarrHeaders),
          );
          final success = await RadarrWebhookManager.syncWebhook(api);
          ZagLogger().debug('Radarr webhook sync: ${success ? "SUCCESS" : "FAILED"}');
        } catch (e, stack) {
          ZagLogger().error('Radarr webhook sync error', e, stack);
        }
      }
      
      // Sync Sonarr if configured
      if (profile.sonarrEnabled && profile.sonarrHost.isNotEmpty && profile.sonarrKey.isNotEmpty) {
        ZagLogger().debug('Syncing Sonarr webhook...');
        try {
          final api = SonarrAPI(
            host: profile.sonarrHost,
            apiKey: profile.sonarrKey,
            headers: Map<String, dynamic>.from(profile.sonarrHeaders),
          );
          final success = await SonarrWebhookManager.syncWebhook(api);
          ZagLogger().debug('Sonarr webhook sync: ${success ? "SUCCESS" : "FAILED"}');
        } catch (e, stack) {
          ZagLogger().error('Sonarr webhook sync error', e, stack);
        }
      }
      
      ZagLogger().debug('=== WEBHOOK SYNC COMPLETE ===');
    } catch (e, stack) {
      ZagLogger().error('Webhook sync failed', e, stack);
    }
  }

  Future<void> _registerDeviceTokenIfNeeded() async {
    try {
      final user = ZagSupabase.client.auth.currentUser;
      if (user != null) {
        await ZagSupabaseMessaging.instance.registerDeviceToken();
      }
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to register device token', e, stackTrace);
    }
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
      title: 'settings.Notifications'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        FutureBuilder(
          future: ZagSupabaseMessaging.instance.areNotificationsAllowed(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData && !snapshot.data!)
              return ZagBanner(
                headerText: 'settings.NotAuthorized'.tr(),
                bodyText: 'settings.NotAuthorizedMessage'.tr(),
                icon: Icons.error_outline_rounded,
                iconColor: ZagColours.red,
              );
            return const SizedBox(height: 0.0, width: double.infinity);
          },
        ),
        _enableNotifications(),
      ],
    );
  }

  Widget _enableNotifications() {
    const db = ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS;
    return ZagBlock(
      title: 'Enable Notifications',
      body: [TextSpan(text: 'Receive push notifications for media events')],
      trailing: db.listenableBuilder(
        builder: (context, _) => ZagSwitch(
          value: db.read(),
          onChanged: (value) async {
            if (value) {
              // Request notification permissions when enabling
              bool granted = await ZagSupabaseMessaging.instance.requestNotificationPermissions();
              if (!granted) {
                // If permissions denied, don't enable the toggle
                showZagErrorSnackBar(
                  title: 'Permission Denied',
                  message: 'Please enable notifications in Settings',
                );
                return;
              }
              // Register device token when notifications are enabled
              await _registerDeviceTokenIfNeeded();
            }
            db.update(value);
          },
        ),
      ),
    );
  }
}