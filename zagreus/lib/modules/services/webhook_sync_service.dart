import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/box.dart';
import 'package:zagreus/modules/radarr/core/webhook_manager.dart';
import 'package:zagreus/modules/sonarr/core/webhook_manager.dart';
import 'package:zagreus/modules/radarr/core/state.dart';
import 'package:zagreus/modules/sonarr/core/state.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';

/// Service to handle periodic webhook synchronization
/// Based on Ruddarr's implementation (MIT licensed)
class WebhookSyncService {
  static const String _lastSyncPrefix = 'webhookLastSync:';
  static const Duration _syncInterval = Duration(hours: 24);
  
  /// Initialize the webhook sync service
  static void initialize() {
    // Do an initial check when app starts
    maybeUpdateWebhooks();
  }
  
  /// Check if webhooks need updating when app becomes active
  /// Based on Ruddarr's implementation
  static void maybeUpdateWebhooks() {
    _checkAndSync();
  }
  
  /// Get the key for storing last sync time
  static String _getLastSyncKey(String profileName, String service) {
    return '$_lastSyncPrefix$profileName:$service';
  }
  
  /// Check if sync is needed and perform it
  static Future<void> _checkAndSync() async {
    try {
      // Get all profiles
      final profiles = ZagBox.profiles.keys.toList();
      
      for (final profileName in profiles) {
        final profile = ZagBox.profiles.read(profileName);
        if (profile == null) continue;
        
        // Check Radarr
        if (profile.radarrEnabled) {
          await _syncIfNeeded(
            profileName: profileName,
            service: 'radarr',
            syncFunction: () => _syncRadarrWebhook(profile),
          );
        }
        
        // Check Sonarr
        if (profile.sonarrEnabled) {
          await _syncIfNeeded(
            profileName: profileName,
            service: 'sonarr',
            syncFunction: () => _syncSonarrWebhook(profile),
          );
        }
      }
    } catch (e, stack) {
      ZagLogger().error('Failed to check webhook sync', e, stack);
    }
  }
  
  /// Check if sync is needed for a specific service
  static Future<void> _syncIfNeeded({
    required String profileName,
    required String service,
    required Future<bool> Function() syncFunction,
  }) async {
    try {
      final key = _getLastSyncKey(profileName, service);
      final lastSyncMillis = ZagBox.zagreus.read(key, fallback: 0);
      final lastSync = DateTime.fromMillisecondsSinceEpoch(lastSyncMillis);
      final now = DateTime.now();
      
      // Check if more than 24 hours have passed
      if (now.difference(lastSync) >= _syncInterval) {
        ZagLogger().debug('Webhook sync needed for $profileName:$service');
        
        final success = await syncFunction();
        
        if (success) {
          // Update last sync time
          await ZagBox.zagreus.update(key, now.millisecondsSinceEpoch);
          ZagLogger().debug('Webhook sync successful for $profileName:$service');
        } else {
          ZagLogger().warning('Webhook sync failed for $profileName:$service');
        }
      }
    } catch (e, stack) {
      ZagLogger().error('Failed to sync webhook for $profileName:$service', e, stack);
    }
  }
  
  /// Sync Radarr webhook
  static Future<bool> _syncRadarrWebhook(ZagProfile profile) async {
    try {
      // Create Radarr API instance
      final api = RadarrAPI(
        host: profile.radarrHost,
        apiKey: profile.radarrKey,
        headers: Map<String, dynamic>.from(profile.radarrHeaders),
      );
      
      // Sync webhook
      return await RadarrWebhookManager.syncWebhook(api);
    } catch (e, stack) {
      ZagLogger().error('Failed to sync Radarr webhook', e, stack);
      return false;
    }
  }
  
  /// Sync Sonarr webhook
  static Future<bool> _syncSonarrWebhook(ZagProfile profile) async {
    try {
      // Create Sonarr API instance
      final api = SonarrAPI(
        host: profile.sonarrHost,
        apiKey: profile.sonarrKey,
        headers: Map<String, dynamic>.from(profile.sonarrHeaders),
      );
      
      // Sync webhook
      return await SonarrWebhookManager.syncWebhook(api);
    } catch (e, stack) {
      ZagLogger().error('Failed to sync Sonarr webhook', e, stack);
      return false;
    }
  }
  
  /// Manually trigger a sync for a specific profile and service
  static Future<bool> manualSync(String profileName, String service) async {
    try {
      final profile = ZagBox.profiles.read(profileName);
      if (profile == null) return false;
      
      bool success = false;
      
      if (service == 'radarr' && profile.radarrEnabled) {
        success = await _syncRadarrWebhook(profile);
      } else if (service == 'sonarr' && profile.sonarrEnabled) {
        success = await _syncSonarrWebhook(profile);
      }
      
      if (success) {
        // Update last sync time
        final key = _getLastSyncKey(profileName, service);
        await ZagBox.zagreus.update(key, DateTime.now().millisecondsSinceEpoch);
      }
      
      return success;
    } catch (e, stack) {
      ZagLogger().error('Manual sync failed for $profileName:$service', e, stack);
      return false;
    }
  }
  
  /// Get last sync time for a profile and service
  static DateTime? getLastSync(String profileName, String service) {
    try {
      final key = _getLastSyncKey(profileName, service);
      final millis = ZagBox.zagreus.read(key, fallback: null);
      
      if (millis == null) return null;
      
      return DateTime.fromMillisecondsSinceEpoch(millis);
    } catch (e) {
      return null;
    }
  }
  
  /// Check if webhook is in sync (within 24 hours)
  static bool isInSync(String profileName, String service) {
    final lastSync = getLastSync(profileName, service);
    if (lastSync == null) return false;
    
    return DateTime.now().difference(lastSync) < _syncInterval;
  }
}