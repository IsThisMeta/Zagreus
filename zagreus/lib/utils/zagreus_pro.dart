import 'package:zagreus/database/tables/zagreus.dart';

class ZagreusPro {
  static bool get isEnabled {
    // Check if Pro is enabled
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