import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/messaging.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/utils/links.dart';
import 'package:dio/dio.dart';
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
        _enableInAppNotifications(),
        ZagDivider(),
        _manualSyncWebhooksButton(),
        _testRadarrNotificationButton(),
        _testSonarrNotificationButton(),
      ],
    );
  }

  Widget _enableInAppNotifications() {
    const db = ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS;
    return ZagBlock(
      title: 'settings.EnableInAppNotifications'.tr(),
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
                  title: 'settings.PermissionDenied'.tr(),
                  message: 'settings.NotificationPermissionDenied'.tr(),
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

  Widget _manualSyncWebhooksButton() {
    return ZagBlock(
      title: 'Sync All Webhooks',
      body: [
        TextSpan(text: 'Manually sync webhooks for all configured services'),
      ],
      trailing: const ZagIconButton(icon: Icons.sync_rounded),
      onTap: () async {
        // Show loading
        showZagSnackBar(
          title: 'Syncing Webhooks',
          message: 'Please wait...',
          type: ZagSnackbarType.INFO,
        );
        
        try {
          // Get current profile
          final profileName = ZagreusDatabase.ENABLED_PROFILE.read();
          final profile = ZagBox.profiles.read(profileName);
          
          if (profile == null) {
            showZagErrorSnackBar(
              title: 'No Profile',
              message: 'No active profile found',
            );
            return;
          }
          
          bool radarrSuccess = false;
          bool sonarrSuccess = false;
          String errors = '';
          
          // Sync Radarr if configured
          if (profile.radarrEnabled) {
            try {
              final api = RadarrAPI(
                host: profile.radarrHost,
                apiKey: profile.radarrKey,
                headers: Map<String, dynamic>.from(profile.radarrHeaders),
              );
              
              radarrSuccess = await RadarrWebhookManager.syncWebhook(api);
              if (!radarrSuccess) {
                errors += 'Radarr sync failed. ';
              }
            } catch (e) {
              errors += 'Radarr: ${e.toString()}. ';
            }
          }
          
          // Sync Sonarr if configured
          if (profile.sonarrEnabled) {
            try {
              final api = SonarrAPI(
                host: profile.sonarrHost,
                apiKey: profile.sonarrKey,
                headers: Map<String, dynamic>.from(profile.sonarrHeaders),
              );
              
              sonarrSuccess = await SonarrWebhookManager.syncWebhook(api);
              if (!sonarrSuccess) {
                errors += 'Sonarr sync failed. ';
              }
            } catch (e) {
              errors += 'Sonarr: ${e.toString()}. ';
            }
          }
          
          // Show results
          if ((profile.radarrEnabled && radarrSuccess) || (profile.sonarrEnabled && sonarrSuccess)) {
            showZagSuccessSnackBar(
              title: 'Webhook Sync Complete',
              message: 'Check your Radarr/Sonarr webhook settings',
            );
          } else if (errors.isNotEmpty) {
            showZagErrorSnackBar(
              title: 'Sync Failed',
              message: errors,
            );
          } else {
            showZagSnackBar(
              title: 'No Services',
              message: 'No services configured',
              type: ZagSnackbarType.INFO,
            );
          }
          
        } catch (e) {
          showZagErrorSnackBar(
            title: 'Sync Failed',
            message: e.toString(),
          );
        }
      },
    );
  }

  Widget _testRadarrNotificationButton() {
    return ZagBlock(
      title: 'Test Radarr Notifications',
      body: [
        TextSpan(text: 'Send a test notification from Radarr'),
      ],
      trailing: const ZagIconButton(icon: Icons.movie_rounded),
      onTap: () async {
        // Show loading
        showZagSnackBar(
          title: 'Testing Radarr Webhook',
          message: 'Please wait...',
          type: ZagSnackbarType.INFO,
        );
        
        try {
          // First check if we have permissions
          bool allowed = await ZagSupabaseMessaging.instance.areNotificationsAllowed();
          if (!allowed) {
            bool granted = await ZagSupabaseMessaging.instance.requestNotificationPermissions();
            if (!granted) {
              showZagErrorSnackBar(
                title: 'Permission Required',
                message: 'Please enable notifications in Settings',
              );
              return;
            }
          }
          
          // Get the device token
          String? token = await ZagSupabaseMessaging.instance.getToken();
          if (token == null) {
            showZagErrorSnackBar(
              title: 'No Device Token',
              message: 'Unable to register for push notifications. Are you on a real device?',
            );
            return;
          }
          
          // Test Radarr webhook
          final radarrState = context.read<RadarrState>();
          if (!radarrState.enabled) {
            showZagErrorSnackBar(
              title: 'Radarr Not Configured',
              message: 'Configure Radarr in Settings first',
            );
            return;
          }
          
          final api = radarrState.api;
          if (api == null) {
            showZagErrorSnackBar(
              title: 'Invalid Configuration',
              message: 'Check your Radarr settings',
            );
            return;
          }
          
          final success = await RadarrWebhookManager.testWebhook(api);
          if (success) {
            showZagSuccessSnackBar(
              title: 'Test Notification Sent',
              message: 'Check your notifications from Radarr',
            );
          } else {
            showZagErrorSnackBar(
              title: 'Test Failed',
              message: 'Could not trigger Radarr test webhook',
            );
          }
          
        } catch (e) {
          showZagErrorSnackBar(
            title: 'Test Failed',
            message: e.toString(),
          );
        }
      },
    );
  }

  Widget _testSonarrNotificationButton() {
    return ZagBlock(
      title: 'Test Sonarr Notifications',
      body: [
        TextSpan(text: 'Send a test notification from Sonarr'),
      ],
      trailing: const ZagIconButton(icon: Icons.tv_rounded),
      onTap: () async {
        // Show loading
        showZagSnackBar(
          title: 'Testing Sonarr Webhook',
          message: 'Please wait...',
          type: ZagSnackbarType.INFO,
        );
        
        try {
          // First check if we have permissions
          bool allowed = await ZagSupabaseMessaging.instance.areNotificationsAllowed();
          if (!allowed) {
            bool granted = await ZagSupabaseMessaging.instance.requestNotificationPermissions();
            if (!granted) {
              showZagErrorSnackBar(
                title: 'Permission Required',
                message: 'Please enable notifications in Settings',
              );
              return;
            }
          }
          
          // Get the device token
          String? token = await ZagSupabaseMessaging.instance.getToken();
          if (token == null) {
            showZagErrorSnackBar(
              title: 'No Device Token',
              message: 'Unable to register for push notifications. Are you on a real device?',
            );
            return;
          }
          
          // Test Sonarr webhook
          final sonarrState = context.read<SonarrState>();
          if (!sonarrState.enabled) {
            showZagErrorSnackBar(
              title: 'Sonarr Not Configured',
              message: 'Configure Sonarr in Settings first',
            );
            return;
          }
          
          final api = sonarrState.api;
          if (api == null) {
            showZagErrorSnackBar(
              title: 'Invalid Configuration',
              message: 'Check your Sonarr settings',
            );
            return;
          }
          
          final success = await SonarrWebhookManager.testWebhook(api);
          if (success) {
            showZagSuccessSnackBar(
              title: 'Test Notification Sent',
              message: 'Check your notifications from Sonarr',
            );
          } else {
            showZagErrorSnackBar(
              title: 'Test Failed',
              message: 'Could not trigger Sonarr test webhook',
            );
          }
          
        } catch (e) {
          showZagErrorSnackBar(
            title: 'Test Failed',
            message: e.toString(),
          );
        }
      },
    );
  }


}
