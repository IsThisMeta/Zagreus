import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/supabase/core.dart';

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

/// Manages automatic webhook injection for Radarr
class RadarrWebhookManager {
  static const String webhookName = 'Zagreus';
  
  /// Check if Zagreus webhook is already configured
  static Future<RadarrNotification?> getZagreusWebhook(RadarrAPI api) async {
    try {
      ZagLogger().debug('Fetching all Radarr notifications...');
      final notifications = await api.notification.getAll();
      ZagLogger().debug('Found ${notifications.length} notifications');
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
      ZagLogger().debug('=== Starting Radarr webhook sync ===');
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
      
      // Create the JSON manually with simple fields
      final notificationData = {
        'name': webhookName,
        'implementation': 'Webhook',
        'implementationName': 'Webhook',
        'configContract': 'WebhookSettings',
        'fields': simpleFields.map((f) => f.toJson()).toList(),
        'tags': [],
        'onGrab': true,
        'onDownload': true,
        'onUpgrade': true,
        'onRename': false,
        'onMovieAdded': true,
        'onMovieDelete': false,
        'onMovieFileDelete': false,
        'onMovieFileDeleteForUpgrade': false,
        'onHealthIssue': false,
        'includeHealthWarnings': false,
        'onApplicationUpdate': false,
        'onManualInteractionRequired': true,
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
        ZagLogger().debug('Webhook data: ${json.encode(notificationData)}');
        final response = await api.httpClient.post(
          'notification',
          data: notificationData,
        );
        ZagLogger().debug('Create response: ${response.statusCode}');
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