import 'package:collection/collection.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/supabase/core.dart';

/// Manages automatic webhook injection for Radarr
class RadarrWebhookManager {
  static const String webhookName = 'Zagreus';
  
  /// Check if Zagreus webhook is already configured
  static Future<RadarrNotification?> getZagreusWebhook(RadarrAPI api) async {
    try {
      final notifications = await api.notification.getAll();
      return notifications.firstWhereOrNull(
        (n) => n.name == webhookName && n.implementation == 'Webhook',
      );
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to get Radarr webhooks', e, stackTrace);
      return null;
    }
  }

  /// Create or update Zagreus webhook
  static Future<bool> syncWebhook(RadarrAPI api) async {
    try {
      // Get user token from Supabase
      final user = ZagSupabase.client.auth.currentUser;
      if (user == null) {
        ZagLogger().warning('No authenticated user for webhook');
        return false;
      }
      
      final userToken = user.id; // Use Supabase user ID as the token

      // Check if webhook already exists
      final existing = await getZagreusWebhook(api);
      
      // Build webhook URL with user_id in the payload
      final webhookUrl = 'https://zagreus-notifications.fly.dev/v1/notifications/webhook';
      
      // Create notification object with user ID in username field
      final notification = RadarrNotification.webhook(
        name: webhookName,
        url: webhookUrl,
        username: userToken, // Pass user ID as username for webhook auth
        password: '', // Can be used for signature if needed
      );
      
      if (existing != null) {
        // Update existing webhook
        notification.id = existing.id;
        await api.notification.update(notification: notification);
        ZagLogger().debug('Updated Radarr webhook');
      } else {
        // Create new webhook
        await api.notification.create(notification: notification);
        ZagLogger().debug('Created Radarr webhook');
      }
      
      return true;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to sync Radarr webhook', e, stackTrace);
      return false;
    }
  }

  /// Remove Zagreus webhook
  static Future<bool> removeWebhook(RadarrAPI api) async {
    try {
      final existing = await getZagreusWebhook(api);
      if (existing != null && existing.id != null) {
        await api.notification.delete(notificationId: existing.id!);
        ZagLogger().debug('Removed Radarr webhook');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to remove Radarr webhook', e, stackTrace);
      return false;
    }
  }

  /// Test webhook connection
  static Future<bool> testWebhook(RadarrAPI api) async {
    try {
      final existing = await getZagreusWebhook(api);
      if (existing != null) {
        return await api.notification.test(notification: existing);
      }
      return false;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to test Radarr webhook', e, stackTrace);
      return false;
    }
  }
}