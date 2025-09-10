import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/messaging.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/utils/links.dart';
import 'package:dio/dio.dart';

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
        _testNotificationButton(),
        ZagDivider(),
        _webhookStatus(),
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
            }
            db.update(value);
          },
        ),
      ),
    );
  }

  Widget _testNotificationButton() {
    return ZagBlock(
      title: 'Test Push Notifications',
      body: [
        TextSpan(text: 'Send a test notification to verify your setup'),
      ],
      trailing: const ZagIconButton(icon: Icons.send_rounded),
      onTap: () async {
        // Show loading
        showZagSnackBar(
          title: 'Sending Test Notification',
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
              message: 'Check Xcode console for errors. Are you on a real device?',
            );
            return;
          }
          
          showZagSnackBar(
            title: 'Sending Test Notification',
            message: 'Check your notification center...',
            type: ZagSnackbarType.INFO,
          );
          
          // Send actual test notification to the server
          try {
            final dio = Dio();
            final user = ZagSupabase.client.auth.currentUser;
            
            final response = await dio.post(
              'https://zagreus-notifications.fly.dev/v1/notifications/test',
              data: {
                'user_id': user?.id,
                'token': token,
              },
              options: Options(
                headers: {'Content-Type': 'application/json'},
              ),
            );
            
            if (response.statusCode == 200) {
              showZagSuccessSnackBar(
                title: 'Test Notification Sent! 🎉',
                message: 'Check your notification center.',
              );
            } else {
              throw Exception('Server returned ${response.statusCode}');
            }
          } catch (e) {
            // Server doesn't have test endpoint - show error
            showZagErrorSnackBar(
              title: 'Test Endpoint Not Available',
              message: 'Test notifications from Radarr/Sonarr webhooks instead.',
            );
            ZagLogger().debug('Test notification endpoint not available: $e');
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

  Widget _webhookStatus() {
    return const SizedBox.shrink();
  }

  Widget _webhookDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _modules() {
    // Removed webhook tiles - notifications are now handled differently
    return [];
  }
}
