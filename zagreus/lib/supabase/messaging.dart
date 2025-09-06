import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/profile_tools.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class ZagSupabaseMessaging {
  // Method channel for native iOS communication
  static const MethodChannel _channel = MethodChannel('app.zagreus/notifications');
  
  static bool get isSupported {
    if (ZagSupabase.isSupported && Platform.isIOS) return true;
    return false;
  }

  /// Returns an instance to handle APNS.
  static ZagSupabaseMessaging get instance => ZagSupabaseMessaging();

  /// Returns a stream controller for handling messages
  final StreamController<RemoteMessage> _messageController = 
      StreamController<RemoteMessage>.broadcast();

  /// Returns a [Stream] to handle any new messages that are received while the application is in the open and in foreground.
  Stream<RemoteMessage> get onMessage => _messageController.stream;

  /// Returns a [Stream] to handle any notifications that are tapped while the application is in the background (not terminated).
  Stream<RemoteMessage> get onMessageOpenedApp => _messageController.stream;

  /// Returns the APNS device token for this device.
  /// Note: In production, this would interface with native iOS code to get the actual APNS token
  Future<String?> getToken() async {
    // TODO: Implement actual APNS token retrieval
    // This would typically involve:
    // 1. Requesting notification permissions
    // 2. Registering for remote notifications
    // 3. Getting the device token from iOS
    return 'dummy_apns_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Request for permission to send a user notifications.
  ///
  /// Returns true if permissions are allowed.
  /// Returns false if permissions are denied or not determined.
  Future<bool> requestNotificationPermissions() async {
    try {
      // Use method channel to request iOS notification permissions
      final bool granted = await _channel.invokeMethod('requestPermission');
      return granted;
    } catch (error, stack) {
      ZagLogger()
          .error('Failed to request notification permission', error, stack);
      return false;
    }
  }

  /// Return the current notification authorization status.
  Future<AuthorizationStatus> getAuthorizationStatus() async {
    try {
      final bool allowed = await _channel.invokeMethod('checkPermission');
      return allowed ? AuthorizationStatus.authorized : AuthorizationStatus.denied;
    } catch (error, stack) {
      ZagLogger().error('Failed to check notification permission', error, stack);
      return AuthorizationStatus.notDetermined;
    }
  }

  /// Returns true if permissions are allowed.
  /// Returns false on any other status (denied, not determined, null, etc.).
  Future<bool> areNotificationsAllowed() async {
    final status = await getAuthorizationStatus();
    return status == AuthorizationStatus.authorized ||
           status == AuthorizationStatus.provisional;
  }

  /// Return a [StreamSubscription] that will show a notification banner on a newly received notification.
  ///
  /// This listens on the message stream where the application must be open and in the foreground.
  StreamSubscription<RemoteMessage> registerOnMessageListener() {
    return onMessage.listen((message) {
      if (!ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.read()) return;

      ZagModule? module = ZagModule.fromKey(message.data['module']);
      showZagSnackBar(
        title: message.notification?.title ?? 'Unknown Content',
        message: message.notification?.body ?? ZagUI.TEXT_EMDASH,
        type: ZagSnackbarType.INFO,
        position: FlashPosition.top,
        duration: const Duration(seconds: 6, milliseconds: 750),
        showButton: module != null,
        buttonOnPressed: () async => _handleWebhook(message),
      );
    });
  }

  /// Returns a [StreamSubscription] that will handle messages/notifications that are opened while Zagreus is running in the background.
  ///
  /// This listens on the message stream where the application must be open but in the background.
  StreamSubscription<RemoteMessage> registerOnMessageOpenedAppListener() =>
      onMessageOpenedApp.listen(_handleWebhook);

  /// Check to see if there was an initial [RemoteMessage] available to be accessed.
  ///
  /// If so, handles the notification webhook.
  Future<void> checkAndHandleInitialMessage() async {
    // TODO: Implement check for initial message from APNS
    // This would typically check if the app was launched from a notification
  }

  /// Shared webhook handler.
  Future<void> _handleWebhook(RemoteMessage? message) async {
    if (message == null || message.data.isEmpty) return;
    // Extract module
    ZagModule? module = ZagModule.fromKey(message.data['module']);
    if (module == null) {
      ZagLogger().warning(
        'Unknown module found inside of RemoteMessage: ${message.data['module'] ?? 'null'}',
      );
      return;
    }
    String profile = message.data['profile'] ?? '';
    if (profile.isEmpty) {
      ZagLogger().warning(
        'Invalid profile received in webhook: ${message.data['profile'] ?? 'null'}',
      );
      return;
    }
    bool result = ZagProfileTools().changeTo(profile, popToRootRoute: true);
    if (result) {
      module.handleWebhook(message.data);
    } else {
      showZagErrorSnackBar(
        title: 'Unknown Profile',
        message: '"$profile" does not exist in Zagreus',
      );
    }
  }

  /// Simulate receiving a message (for testing purposes)
  void simulateMessage(RemoteMessage message) {
    _messageController.add(message);
  }
}

/// Authorization status enum to match Firebase's API
enum AuthorizationStatus {
  notDetermined,
  denied,
  authorized,
  provisional,
}

/// RemoteMessage class to match Firebase's API
class RemoteMessage {
  final RemoteNotification? notification;
  final Map<String, dynamic> data;
  
  RemoteMessage({this.notification, required this.data});
}

/// RemoteNotification class to match Firebase's API
class RemoteNotification {
  final String? title;
  final String? body;
  
  RemoteNotification({this.title, this.body});
}