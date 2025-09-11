import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';

/// Simple webhook field that only serializes name and value
class SimpleWebhookField {
  final String name;
  final String value;
  
  SimpleWebhookField({required this.name, required this.value});
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
  };
}

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
      ZagLogger().debug('=== Starting Sonarr webhook sync ===');
      // Get user token from Supabase
      final user = ZagSupabase.client.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }
      
      final userToken = user.id; // Use Supabase user ID as the token

      // Check if webhook already exists
      ZagLogger().debug('Checking for existing webhook...');
      final existing = await getZagreusWebhook(api);
      ZagLogger().debug('Existing webhook: ${existing != null ? 'Found' : 'Not found'}');
      
      // Build webhook URL with user_id in the path
      // Encode the user ID in base64
      final payload = base64.encode(utf8.encode(userToken));
      final webhookUrl = 'https://zagreus-notifications.fly.dev/v1/notifications/webhook/$payload';
      
      // Create simple fields (just name and value)
      final simpleFields = [
        SimpleWebhookField(name: 'url', value: webhookUrl),
        SimpleWebhookField(name: 'method', value: '1'),
        SimpleWebhookField(name: 'username', value: ''),
        SimpleWebhookField(name: 'password', value: ''),
      ];
      
      // Create the JSON manually with simple fields and specific events enabled
      final notificationData = {
        'name': webhookName,
        'implementation': 'Webhook',
        'implementationName': 'Webhook',
        'configContract': 'WebhookSettings',
        'fields': simpleFields.map((f) => f.toJson()).toList(),
        'tags': [],
        'onGrab': true,           // Episode grabbed
        'onDownload': true,        // Episode downloaded
        'onUpgrade': true,         // Episode upgraded
        'onRename': false,         // Don't notify on renames
        'onSeriesAdd': true,       // Series added
        'onSeriesDelete': true,    // Series deleted
        'onEpisodeFileDelete': false,  // Episode file deleted
        'onEpisodeFileDeleteForUpgrade': false,  // Episode deleted for upgrade
        'onHealthIssue': false,    // Health issues
        'includeHealthWarnings': false,
        'onApplicationUpdate': false,  // App updates
        'onManualInteractionRequired': true,  // Manual intervention needed
      };
      
      if (existing != null && existing.id != null) {
        // Update existing webhook
        notificationData['id'] = existing.id!;
        ZagLogger().debug('Updating existing webhook with ID: ${existing.id}');
        final response = await api.httpClient.put(
          'notification/${existing.id}',
          data: notificationData,
        );
        ZagLogger().debug('Update response: ${response.statusCode}');
      } else {
        // Create new webhook
        ZagLogger().debug('Creating new webhook');
        final response = await api.httpClient.post(
          'notification',
          data: notificationData,
        );
        ZagLogger().debug('Create response: ${response.statusCode}');
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