import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class InAppPurchaseService {
  static final InAppPurchaseService _instance =
      InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Product IDs - these must match exactly what you create in App Store Connect
  static const String monthlyProductId = 'com.zagreus.pro.monthlyrenewing';
  static const String yearlyProductId = 'com.zagreus.pro.yearly';

  static const Set<String> _productIds = {
    monthlyProductId,
    // yearlyProductId,  // Commented out - not in StoreKit file
  };

  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  Future<void> initialize() async {
    print('DEBUG: IAP initialize called');
    // Check if IAP is available
    _isAvailable = await _inAppPurchase.isAvailable();
    print('DEBUG: IAP available: $_isAvailable');
    if (!_isAvailable) {
      ZagLogger().warning('In-app purchases not available');
      return;
    }

    // Load products
    await loadProducts();

    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _onDone,
      onError: _onError,
    );

    // Don't restore purchases on every launch - let ZagreusPro handle verification
    // Only restore when user explicitly requests it

    // But do verify subscription periodically (once per week)
    await _verifySubscriptionIfNeeded();
  }

  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    print('DEBUG: Attempting to load products: $_productIds');
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_productIds);
    print('DEBUG: Response received');

    if (response.error != null) {
      ZagLogger().error('Error loading products', response.error, null);
      return;
    }

    if (response.notFoundIDs.isNotEmpty) {
      print('DEBUG: Products not found: ${response.notFoundIDs}');
      ZagLogger().warning('Products not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
    print('DEBUG: Found ${_products.length} products');
    for (var p in _products) {
      print('DEBUG: - ${p.id}');
    }
  }

  Future<bool> purchaseMonthly() async {
    return _purchase(monthlyProductId);
  }

  Future<bool> purchaseYearly() async {
    return _purchase(yearlyProductId);
  }

  Future<bool> _purchase(String productId) async {
    if (!_isAvailable) {
      showZagInfoSnackBar(
        title: 'Unavailable',
        message: 'In-app purchases are not available',
      );
      return false;
    }

    final ProductDetails? productDetails = _products.firstWhereOrNull(
      (product) => product.id == productId,
    );

    if (productDetails == null) {
      showZagInfoSnackBar(
        title: 'Error',
        message: 'Product not found. Please try again later.',
      );
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );

    try {
      // For subscriptions, use buyNonConsumable
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      return success;
    } catch (e) {
      ZagLogger().error('Purchase failed', e, null);
      showZagInfoSnackBar(
        title: 'Purchase Failed',
        message: 'Unable to complete purchase',
      );
      return false;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
        showZagInfoSnackBar(
          title: 'Processing',
          message: 'Processing your purchase...',
        );
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle error
        ZagLogger().error('Purchase error', purchaseDetails.error, null);
        showZagInfoSnackBar(
          title: 'Purchase Failed',
          message: 'Unable to complete purchase',
        );
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Verify and deliver the purchase
        _deliverProduct(purchaseDetails);
      }

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  void _deliverProduct(PurchaseDetails purchaseDetails) async {
    // Determine if monthly or yearly
    final bool isMonthly = purchaseDetails.productID == monthlyProductId;

    final bool wasAlreadyPro = ZagreusPro.isEnabled;

    // Validate receipt with server
    await _validateAndStoreReceipt(purchaseDetails);

    // Enable Pro locally (as backup)
    ZagreusPro.enablePro(isMonthly: isMonthly);

    final bool isNewPurchase =
        purchaseDetails.status == PurchaseStatus.purchased;
    if (isNewPurchase || !wasAlreadyPro) {
      showZagInfoSnackBar(
        title: 'Welcome to Zagreus Pro!',
        message: 'Premium features are now unlocked',
      );
    } else if (purchaseDetails.status == PurchaseStatus.restored &&
        wasAlreadyPro) {
      // Avoid spamming the welcome toast on every app launch. Optionally log.
      ZagLogger().debug('Pro subscription restored silently.');
    }
  }

  Future<void> _validateAndStoreReceipt(PurchaseDetails purchaseDetails) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        // If no user, just store locally
        print('No authenticated user, storing locally only');
        return;
      }

      // For iOS, get the receipt data
      String? receiptData;
      if (Platform.isIOS) {
        receiptData = purchaseDetails.verificationData.localVerificationData;
      }

      if (receiptData == null) {
        print('No receipt data available');
        return;
      }

      // Call Supabase Edge Function to validate receipt
      final response = await supabase.functions.invoke(
        'validate-receipt',
        body: {
          'receipt_data': receiptData,
          'user_id': user.id,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        print('Receipt validated and stored successfully');
        // Optionally store subscription info locally for offline access
        final subscription = response.data['subscription'];
        if (subscription != null) {
          ZagreusDatabase.ZAGREUS_PRO_EXPIRY
              .update(subscription['expires_date']?.toString() ?? '');
        }
      }
    } catch (e) {
      print('Error validating receipt: $e');
      // Don't block the purchase, local storage will work as fallback
    }
  }

  Future<void> restorePurchases() async {
    // First check if user has subscription in Supabase
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        // Check for active subscription in database
        final response = await supabase
            .rpc('get_active_subscription', params: {'p_user_id': user.id});

        if (response != null && (response as List).isNotEmpty) {
          final subscription = response[0];
          final expiresDate = DateTime.parse(subscription['expires_date']);

          if (expiresDate.isAfter(DateTime.now())) {
            // Restore Pro status from server
            ZagreusDatabase.ZAGREUS_PRO_ENABLED.update(true);
            ZagreusDatabase.ZAGREUS_PRO_EXPIRY
                .update(expiresDate.toIso8601String());

            final productId = subscription['product_id'] as String;
            final isMonthly = productId.contains('monthly');
            ZagreusDatabase.ZAGREUS_PRO_SUBSCRIPTION_TYPE
                .update(isMonthly ? 'monthly' : 'yearly');

            showZagInfoSnackBar(
              title: 'Subscription Restored',
              message: 'Your Pro subscription has been restored',
            );
            return;
          }
        }
      }
    } catch (e) {
      print('Error restoring from server: $e');
    }

    // Fallback to Apple's restore
    if (!_isAvailable) return;

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      ZagLogger().error('Restore purchases failed', e, null);
    }
  }

  void _onDone() {
    _subscription?.cancel();
  }

  void _onError(dynamic error) {
    ZagLogger().error('Purchase stream error', error, null);
  }

  Future<void> _verifySubscriptionIfNeeded() async {
    // Only verify if user has Pro enabled locally
    if (!ZagreusPro.isEnabled) return;

    // Check when we last verified
    final lastVerified = ZagreusDatabase.LAST_SUBSCRIPTION_VERIFY.read();
    if (lastVerified.isNotEmpty) {
      try {
        final lastDate = DateTime.parse(lastVerified);
        final now = DateTime.now();

        // If we verified in the last 7 days, skip
        if (now.difference(lastDate).inDays < 7) {
          return;
        }
      } catch (e) {
        // Invalid date, continue with verification
      }
    }

    // Silently verify with Supabase
    try {
      final isValid = await ZagreusPro.isEnabledAsync;

      // Update last verified time
      ZagreusDatabase.LAST_SUBSCRIPTION_VERIFY
          .update(DateTime.now().toIso8601String());

      // If subscription expired, clear Pro status
      if (!isValid && ZagreusPro.hasExpired) {
        showZagInfoSnackBar(
          title: 'Subscription Expired',
          message: 'Your Zagreus Pro subscription has expired',
        );
      }
    } catch (e) {
      // Silently fail - don't interrupt user experience
      print('Failed to verify subscription: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
}
