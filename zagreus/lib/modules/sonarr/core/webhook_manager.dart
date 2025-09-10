import 'dart:convert';
import 'package:collection/collection.dart';
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
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to get Sonarr webhooks', e, stackTrace);
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
      
      // Build webhook URL with user_id in the path
      // Encode the user ID in base64
      final payload = base64.encode(utf8.encode(userToken));
      final webhookUrl = 'https://zagreus-notifications.fly.dev/v1/notifications/webhook/$payload';
      
      // Create notification object (no auth needed since token is in URL)
      final notification = SonarrNotification.webhook(
        name: webhookName,
        url: webhookUrl,
        username: '', // No username needed
        password: '', // No password needed
      );
      
      if (existing != null) {
        // Update existing webhook
        notification.id = existing.id;
        await api.notification.update(notification: notification);
        ZagLogger().debug('Updated Sonarr webhook');
      } else {
        // Create new webhook
        await api.notification.create(notification: notification);
        ZagLogger().debug('Created Sonarr webhook');
      }
      
      return true;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to sync Sonarr webhook', e, stackTrace);
      return false;
    }
  }

  /// Remove Zagreus webhook
  static Future<bool> removeWebhook(SonarrAPI api) async {
    try {
      final existing = await getZagreusWebhook(api);
      if (existing != null && existing.id != null) {
        await api.notification.delete(notificationId: existing.id!);
        ZagLogger().debug('Removed Sonarr webhook');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to remove Sonarr webhook', e, stackTrace);
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
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to test Sonarr webhook', e, stackTrace);
      return false;
    }
  }
}