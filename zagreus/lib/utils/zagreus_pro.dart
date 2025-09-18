import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/database/tables/bios.dart';
import 'package:zagreus/modules.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ZagreusPro {
  static const Duration _fallbackMonthlyDuration = Duration(days: 1);
  static const Duration _fallbackYearlyDuration = Duration(days: 7);

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
      final expiry = DateTime.parse(expiryString).toUtc();
      if (DateTime.now().toUtc().isAfter(expiry)) {
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
    clearCache();
  }

  /// Apply subscription data sourced from Apple/Supabase.
  static void applySubscription({
    required DateTime expiresAt,
    required String productId,
  }) {
    final expiryUtc = expiresAt.toUtc();
    ZagreusDatabase.ZAGREUS_PRO_ENABLED.update(true);
    ZagreusDatabase.ZAGREUS_PRO_EXPIRY.update(expiryUtc.toIso8601String());
    ZagreusDatabase.ZAGREUS_PRO_SUBSCRIPTION_TYPE.update(
      _subscriptionTypeFromProduct(productId),
    );
    ZagreusDatabase.LAST_SUBSCRIPTION_VERIFY
        .update(DateTime.now().toUtc().toIso8601String());

    clearCache();
    _setProBootModule();
  }

  /// Fallback helper when the app cannot reach the backend.
  /// Provides a temporary expiry so the user retains access until we can revalidate.
  static void enablePro({
    required bool isMonthly,
    String? productId,
    Duration? fallbackDuration,
  }) {
    final duration = fallbackDuration ??
        (isMonthly ? _fallbackMonthlyDuration : _fallbackYearlyDuration);
    final fallbackProductId =
        productId ?? (isMonthly ? 'fallback-monthly' : 'fallback-yearly');

    applySubscription(
      expiresAt: DateTime.now().toUtc().add(duration),
      productId: fallbackProductId,
    );
  }

  static void disable() {
    _disablePro();
  }

  static void _setProBootModule() {
    try {
      final currentModule = BIOSDatabase.BOOT_MODULE.read();
      final userModuleSaved = ZagreusDatabase.USER_BOOT_MODULE.read();

      // Set to Discover if not already, and save user's preference
      if (currentModule != ZagModule.DISCOVER) {
        // Only save current as user preference if we haven't saved one yet
        // (dashboard is the default, so if it's still dashboard, this is first time)
        if (userModuleSaved == 'dashboard' || userModuleSaved.isEmpty) {
          ZagreusDatabase.USER_BOOT_MODULE.update(currentModule.key);
        }
        // Always set to Discover when Pro is activated
        BIOSDatabase.BOOT_MODULE.update(ZagModule.DISCOVER);
        print('Pro activated: Setting boot module to Discover');
      }
    } catch (e) {
      print('Error setting Pro boot module: $e');
    }
  }

  static bool get hasExpired {
    final expiryString = ZagreusDatabase.ZAGREUS_PRO_EXPIRY.read();
    if (expiryString.isEmpty) return true;

    try {
      final expiry = DateTime.parse(expiryString).toUtc();
      return DateTime.now().toUtc().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  static String get subscriptionType {
    return ZagreusDatabase.ZAGREUS_PRO_SUBSCRIPTION_TYPE.read();
  }

  static String _subscriptionTypeFromProduct(String productId) {
    final lower = productId.toLowerCase();
    if (lower.contains('year')) return 'yearly';
    if (lower.contains('month')) return 'monthly';
    return lower;
  }
}
