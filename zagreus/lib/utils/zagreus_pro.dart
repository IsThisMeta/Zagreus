import 'package:zagreus/database/tables/zagreus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ZagreusPro {
  static bool? _cachedProStatus;
  static DateTime? _cacheExpiry;

  /// Clear the cached Pro status (useful for testing)
  static void clearCache() {
    _cachedProStatus = null;
    _cacheExpiry = null;
  }

  static Future<bool> get isEnabledAsync async {
    // Check cache first (valid for 5 minutes)
    if (_cachedProStatus != null &&
        _cacheExpiry != null &&
        DateTime.now().isBefore(_cacheExpiry!)) {
      return _cachedProStatus!;
    }

    // Try to check Supabase first
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        // Check subscription in database
        final response = await supabase
            .rpc('has_active_pro', params: {'p_user_id': user.id});

        if (response != null) {
          _cachedProStatus = response as bool;
          _cacheExpiry = DateTime.now().add(Duration(minutes: 5));

          // Update local storage to match server
          if (_cachedProStatus!) {
            ZagreusDatabase.ZAGREUS_PRO_ENABLED.update(true);
          } else {
            _disablePro();
          }

          return _cachedProStatus!;
        }
      }
    } catch (e) {
      print('Error checking Pro status from server: $e');
    }

    // Fallback to local storage
    return isEnabled;
  }

  // Synchronous version for backward compatibility
  static bool get isEnabled {
    // Check if Pro is enabled locally
    if (!ZagreusDatabase.ZAGREUS_PRO_ENABLED.read()) {
      return false;
    }

    // Check if subscription has expired
    final expiryString = ZagreusDatabase.ZAGREUS_PRO_EXPIRY.read();
    if (expiryString.isEmpty) {
      // No expiry set, disable Pro
      _disablePro();
      return false;
    }

    try {
      final expiry = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiry)) {
        // Subscription expired, disable Pro
        _disablePro();
        return false;
      }
    } catch (e) {
      // Invalid expiry date, disable Pro
      _disablePro();
      return false;
    }

    return true;
  }
  
  static void _disablePro() {
    ZagreusDatabase.ZAGREUS_PRO_ENABLED.update(false);
    ZagreusDatabase.ZAGREUS_PRO_EXPIRY.update('');
    ZagreusDatabase.ZAGREUS_PRO_SUBSCRIPTION_TYPE.update('');
  }
  
  static void enablePro({required bool isMonthly}) {
    // Set expiry date based on subscription type
    final now = DateTime.now();
    final expiry = isMonthly 
      ? now.add(const Duration(days: 30))
      : now.add(const Duration(days: 365));
    
    ZagreusDatabase.ZAGREUS_PRO_ENABLED.update(true);
    ZagreusDatabase.ZAGREUS_PRO_EXPIRY.update(expiry.toIso8601String());
    ZagreusDatabase.ZAGREUS_PRO_SUBSCRIPTION_TYPE.update(
      isMonthly ? 'monthly' : 'yearly'
    );
  }
  
  static bool get hasExpired {
    final expiryString = ZagreusDatabase.ZAGREUS_PRO_EXPIRY.read();
    if (expiryString.isEmpty) return true;
    
    try {
      final expiry = DateTime.parse(expiryString);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }
  
  static String get subscriptionType {
    return ZagreusDatabase.ZAGREUS_PRO_SUBSCRIPTION_TYPE.read();
  }
}