import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  static const String _apiKey = 'appl_rUDwskSqmGCotcUTmqthnGgYCFq';
  static const String _entitlementId = 'pro';

  CustomerInfo? _customerInfo;

  Future<void> initialize() async {
    try {
      // Configure RevenueCat
      await Purchases.configure(
        PurchasesConfiguration(_apiKey)
          ..appUserID = null // Let RevenueCat generate anonymous ID
      );

      // Enable debug logs in debug mode
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      // Get initial customer info
      await updateCustomerInfo();

      // Listen to customer info updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _customerInfo = customerInfo;
        _updateProStatus();
      });

      print('✅ RevenueCat initialized successfully');
    } catch (e) {
      print('❌ RevenueCat initialization failed: $e');
    }
  }

  Future<void> updateCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      _updateProStatus();
    } catch (e) {
      print('❌ Failed to get customer info: $e');
    }
  }

  void _updateProStatus() {
    final isActive = _customerInfo?.entitlements.all[_entitlementId]?.isActive ?? false;

    if (isActive) {
      final expirationDate = _customerInfo?.entitlements.all[_entitlementId]?.expirationDate;
      if (expirationDate != null) {
        final expiry = DateTime.parse(expirationDate);
        print('🎯 RevenueCat: Pro active until $expiry');
        ZagreusPro.applySubscription(
          expiresAt: expiry,
          productId: 'revenuecat_pro',
        );
      }
    } else {
      print('📵 RevenueCat: Pro not active');
      ZagreusPro.disable();
    }
  }

  Future<bool> purchaseMonthly() async {
    try {
      // Get available packages
      final offerings = await Purchases.getOfferings();

      // Try to find monthly package by identifier, or just use the first available package
      final packages = offerings.current?.availablePackages ?? [];
      final monthlyPackage = packages.isNotEmpty
          ? packages.firstWhere(
              (pkg) => pkg.identifier == '\$rc_monthly',
              orElse: () => packages.first,
            )
          : null;

      if (monthlyPackage == null) {
        showZagInfoSnackBar(
          title: 'Error',
          message: 'Monthly subscription not available',
        );
        return false;
      }

      // Make purchase
      final result = await Purchases.purchasePackage(monthlyPackage);
      _customerInfo = result.customerInfo;
      _updateProStatus();

      showZagInfoSnackBar(
        title: 'Welcome to Zagreus Pro!',
        message: 'Premium features are now unlocked.',
      );
      return true;
    } catch (e) {
      if (e is PurchasesErrorCode && e == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled - don't show error
        return false;
      }
      print('❌ Purchase failed: $e');
      showZagInfoSnackBar(
        title: 'Purchase Failed',
        message: 'Unable to complete purchase',
      );
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _customerInfo = customerInfo;
      _updateProStatus();

      if (_customerInfo?.entitlements.all[_entitlementId]?.isActive ?? false) {
        showZagInfoSnackBar(
          title: 'Subscription Restored',
          message: 'Your Pro subscription has been restored.',
        );
      } else {
        showZagInfoSnackBar(
          title: 'No Subscription Found',
          message: 'No active subscription to restore.',
        );
      }
    } catch (e) {
      print('❌ Restore failed: $e');
      showZagInfoSnackBar(
        title: 'Restore Failed',
        message: 'Unable to restore purchases',
      );
    }
  }

  bool get isProActive =>
    _customerInfo?.entitlements.all[_entitlementId]?.isActive ?? false;

  bool get isAvailable => true; // RevenueCat handles availability internally

  Future<bool> purchaseYearly() async {
    // TODO: Implement yearly subscription when available
    showZagInfoSnackBar(
      title: 'Coming Soon',
      message: 'Yearly subscriptions will be available soon',
    );
    return false;
  }
}