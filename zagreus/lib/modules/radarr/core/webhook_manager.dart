import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
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
        throw Exception('No authenticated user');
      }
      
      final userToken = user.id; // Use Supabase user ID as the token

      // Check if webhook already exists
      final existing = await getZagreusWebhook(api);
      
      // Get the webhook schema
      final schema = await api.notification.getSchema(implementation: 'Webhook');
      
      // Build webhook URL with user_id in the path
      // Encode the user ID in base64
      final payload = base64.encode(utf8.encode(userToken));
      final webhookUrl = 'https://zagreus-notifications.fly.dev/v1/notifications/webhook/$payload';
      
      // Create fields based on schema
      final fields = <RadarrNotificationField>[];
      for (var schemaField in schema) {
        if (schemaField.name == 'url') {
          schemaField.value = webhookUrl;
          fields.add(schemaField);
        } else if (schemaField.name == 'method') {
          schemaField.value = '1';
          fields.add(schemaField);
        } else if (schemaField.name == 'username') {
          schemaField.value = '';
          fields.add(schemaField);
        } else if (schemaField.name == 'password') {
          schemaField.value = '';
          fields.add(schemaField);
        }
      }
      
      // Create notification object
      final notification = RadarrNotification(
        name: webhookName,
        implementation: 'Webhook',
        implementationName: 'Webhook',
        configContract: 'WebhookSettings',
        fields: fields,
        tags: [],
      );
      
      // Enable same notification types as Ruddarr (but disable others)
      notification.onGrab = true;
      notification.onDownload = true;
      notification.onUpgrade = true;
      notification.onRename = false;
      notification.onMovieAdded = true;
      notification.onMovieDelete = false;
      notification.onMovieFileDelete = false;
      notification.onMovieFileDeleteForUpgrade = false;
      notification.onHealthIssue = false;
      notification.includeHealthWarnings = false;
      notification.onApplicationUpdate = false;
      notification.onManualInteractionRequired = true;
      
      // Debug: Log the JSON we're about to send
      final jsonData = json.encode(notification.toJson());
      ZagLogger().debug('Sending JSON: $jsonData');
      
      if (existing != null) {
        // Update existing webhook
        notification.id = existing.id;
        await api.notification.update(notification: notification);
      } else {
        // Create new webhook
        await api.notification.create(notification: notification);
      }
      
      return true;
    } on DioException catch (e) {
      // Extract error details from Radarr's response
      String errorMsg = 'Webhook sync failed: ';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          // Try to get error message from response
          final data = e.response!.data as Map;
          if (data['message'] != null) {
            errorMsg += data['message'];
          } else if (data['error'] != null) {
            errorMsg += data['error'];
          } else {
            errorMsg += 'Response: ${json.encode(data)}';
          }
        } else {
          errorMsg += e.response!.data.toString();
        }
      } else {
        errorMsg += e.message ?? e.toString();
      }
      throw Exception(errorMsg);
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to sync Radarr webhook', e, stackTrace);
      rethrow;
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