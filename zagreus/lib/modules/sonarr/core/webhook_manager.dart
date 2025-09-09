import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';

/// Manages automatic webhook injection for Sonarr
class SonarrWebhookManager {
  static const String webhookName = 'Zagreus';
  
  /// Check if Zagreus webhook is already configured
  static Future<SonarrNotification?> getZagreusWebhook(SonarrAPI api) async {
    try {
      final notifications = await api.notification.getAll();
      return notifications.firstWhereOrNull(
        (n) => n.name == webhookName && n.implementation == 'Webhook',
      );
    } catch (e) {
      ZagLogger().error('Failed to get Sonarr webhooks', e);
      return null;
    }
  }

  /// Create or update Zagreus webhook
  static Future<bool> syncWebhook(SonarrAPI api) async {
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
      
      // Build webhook URL using user token
      final webhookUrl = 'https://zagreus-notifications.fly.dev/v1/sonarr/user/$userToken';
      
      // Create notification object
      final notification = SonarrNotification.webhook(
        name: webhookName,
        url: webhookUrl,
        username: '', // Can be used for additional auth if needed
        password: '', // Can be used for signature if needed
      );
      
      if (existing != null) {
        // Update existing webhook
        notification.id = existing.id;
        await api.notification.update(notification: notification);
        ZagLogger().info('Updated Sonarr webhook');
      } else {
        // Create new webhook
        await api.notification.create(notification: notification);
        ZagLogger().info('Created Sonarr webhook');
      }
      
      return true;
    } catch (e) {
      ZagLogger().error('Failed to sync Sonarr webhook', e);
      return false;
    }
  }

  /// Remove Zagreus webhook
  static Future<bool> removeWebhook(SonarrAPI api) async {
    try {
      final existing = await getZagreusWebhook(api);
      if (existing != null && existing.id != null) {
        await api.notification.delete(notificationId: existing.id!);
        ZagLogger().info('Removed Sonarr webhook');
        return true;
      }
      return false;
    } catch (e) {
      ZagLogger().error('Failed to remove Sonarr webhook', e);
      return false;
    }
  }

  /// Test webhook connection
  static Future<bool> testWebhook(SonarrAPI api) async {
    try {
      final existing = await getZagreusWebhook(api);
      if (existing != null) {
        return await api.notification.test(notification: existing);
      }
      return false;
    } catch (e) {
      ZagLogger().error('Failed to test Sonarr webhook', e);
      return false;
    }
  }
}