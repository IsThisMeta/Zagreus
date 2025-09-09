import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/messaging.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/utils/links.dart';

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
        SettingsBanners.NOTIFICATIONS_MODULE_SUPPORT.banner(),
        _enableInAppNotifications(),
        _testNotificationButton(),
        // Webhook configuration is now handled automatically
        // ZagDivider(),
        // ..._modules(),
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
              message: 'Failed to get device token. Make sure notifications are enabled.',
            );
            return;
          }
          
          showZagSnackBar(
            title: 'Device Token Retrieved',
            message: 'Token: ${token.substring(0, 20)}...',
            type: ZagSnackbarType.SUCCESS,
            duration: const Duration(seconds: 5),
          );
          
          // TODO: Send test notification via your notification server
          // For now, simulate a local notification
          ZagSupabaseMessaging.instance.simulateMessage(
            RemoteMessage(
              notification: RemoteNotification(
                title: '🎉 Notifications Working!',
                body: 'Your Zagreus notifications are set up correctly.',
              ),
              data: {
                'module': 'settings',
                'profile': 'default',
              },
            ),
          );
          
        } catch (e) {
          showZagErrorSnackBar(
            title: 'Test Failed',
            message: e.toString(),
          );
        }
      },
    );
  }

  List<Widget> _modules() {
    // Removed webhook tiles - notifications are now handled differently
    return [];
  }
}
