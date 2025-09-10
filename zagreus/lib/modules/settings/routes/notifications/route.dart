import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'dart:convert';

class NotificationsRoute extends StatefulWidget {
  const NotificationsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<NotificationsRoute> createState() => _State();
}

class _State extends State<NotificationsRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  String _debugInfo = 'Loading...';
  String _radarrUrl = '';
  String _sonarrUrl = '';
  String _userId = '';
  String _radarrStatus = '';
  String _sonarrStatus = '';

  @override
  void initState() {
    super.initState();
    _syncWebhooksInBackground();
  }

  void _syncWebhooksInBackground() async {
    try {
      final profileName = ZagreusDatabase.ENABLED_PROFILE.read();
      final profile = ZagBox.profiles.read(profileName);
      
      setState(() {
        _debugInfo = 'Profile: ${profileName ?? "none"}';
      });
      
      if (profile == null) {
        setState(() {
          _debugInfo = 'No profile found';
        });
        return;
      }
      
      final user = ZagSupabase.client.auth.currentUser;
      if (!ZagSupabase.isSupported || user == null) {
        setState(() {
          _debugInfo = 'Not logged in or Supabase not supported';
        });
        return;
      }
      
      setState(() {
        _userId = user.id;
        _debugInfo = 'User ID: ${user.id}';
      });
      
      ZagLogger().debug('=== WEBHOOK SYNC TRIGGERED (Notifications Page) ===');
      
      // Build webhook URLs
      final payload = base64.encode(utf8.encode(user.id));
      _radarrUrl = 'https://zagreus-notifications.fly.dev/v1/notifications/webhook/$payload';
      _sonarrUrl = 'https://zagreus-notifications.fly.dev/v1/notifications/webhook/$payload';
      
      // Sync Radarr if configured
      if (profile.radarrEnabled && profile.radarrHost.isNotEmpty && profile.radarrKey.isNotEmpty) {
        setState(() {
          _radarrStatus = 'Syncing...';
        });
        
        try {
          final api = RadarrAPI(
            host: profile.radarrHost,
            apiKey: profile.radarrKey,
            headers: Map<String, dynamic>.from(profile.radarrHeaders),
          );
          final success = await RadarrWebhookManager.syncWebhook(api);
          setState(() {
            _radarrStatus = 'SUCCESS';
          });
        } catch (e) {
          setState(() {
            // Extract just the error message without the stack trace
            String errorMsg = e.toString();
            if (errorMsg.startsWith('Exception: ')) {
              errorMsg = errorMsg.substring(11);
            }
            _radarrStatus = 'FAILED: $errorMsg';
          });
        }
      } else {
        setState(() {
          _radarrStatus = 'Not configured';
        });
      }
      
      // Sync Sonarr if configured
      if (profile.sonarrEnabled && profile.sonarrHost.isNotEmpty && profile.sonarrKey.isNotEmpty) {
        setState(() {
          _sonarrStatus = 'Syncing...';
        });
        
        try {
          final api = SonarrAPI(
            host: profile.sonarrHost,
            apiKey: profile.sonarrKey,
            headers: Map<String, dynamic>.from(profile.sonarrHeaders),
          );
          final success = await SonarrWebhookManager.syncWebhook(api);
          setState(() {
            _sonarrStatus = 'SUCCESS';
          });
        } catch (e) {
          setState(() {
            // Extract just the error message without the stack trace
            String errorMsg = e.toString();
            if (errorMsg.startsWith('Exception: ')) {
              errorMsg = errorMsg.substring(11);
            }
            _sonarrStatus = 'FAILED: $errorMsg';
          });
        }
      } else {
        setState(() {
          _sonarrStatus = 'Not configured';
        });
      }
      
    } catch (e, stack) {
      setState(() {
        _debugInfo = 'Error: $e';
      });
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
        ZagDivider(),
        ZagBlock(
          title: 'Debug Info',
          body: [TextSpan(text: _debugInfo)],
        ),
        ZagBlock(
          title: 'User ID',
          body: [TextSpan(text: _userId.isEmpty ? 'Not logged in' : _userId)],
        ),
        ZagBlock(
          title: 'Radarr Webhook URL',
          body: [TextSpan(text: _radarrUrl.isEmpty ? 'Not generated' : _radarrUrl)],
          trailing: _radarrUrl.isNotEmpty ? ZagIconButton(
            icon: Icons.copy_rounded,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _radarrUrl));
              showZagSuccessSnackBar(
                title: 'Copied',
                message: 'Radarr webhook URL copied to clipboard',
              );
            },
          ) : null,
        ),
        ZagBlock(
          title: 'Radarr Status',
          body: [TextSpan(text: _radarrStatus.isEmpty ? 'Not checked' : _radarrStatus)],
        ),
        ZagBlock(
          title: 'Sonarr Webhook URL',
          body: [TextSpan(text: _sonarrUrl.isEmpty ? 'Not generated' : _sonarrUrl)],
        ),
        ZagBlock(
          title: 'Sonarr Status',
          body: [TextSpan(text: _sonarrStatus.isEmpty ? 'Not checked' : _sonarrStatus)],
        ),
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