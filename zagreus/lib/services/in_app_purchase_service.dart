import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InAppPurchaseService {
  static final InAppPurchaseService _instance =
      InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Product IDs - these must match exactly what you create in App Store Connect
  static const String monthlyProductId = 'com.zagreus.pro.monthly.v2';
  static const String yearlyProductId = 'com.zagreus.pro.yearly';

  static const Set<String> _productIds = {
    monthlyProductId,
    // yearlyProductId,  // Commented out - not in StoreKit file
  };

  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  bool _userInitiatedAction = false;

  Future<void> initialize() async {
    // Check if IAP is available
    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
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

    // DON'T call restore on app launch - only when user explicitly requests it
    // Instead verify subscription status with backend
    await _verifySubscriptionIfNeeded();
  }

  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds);

      if (response.error != null) {
        ZagLogger().error('Error loading products', response.error, null);
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        ZagLogger().warning('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
    } catch (e, stack) {
      ZagLogger().error('Failed to load products', e, stack);
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
      _userInitiatedAction = true;
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
    print(
        '>>> Purchase update: ${purchaseDetailsList.length} items, userInitiated=$_userInitiatedAction');
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      print(
          '  Status: ${purchaseDetails.status}, ProductID: ${purchaseDetails.productID}');
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showZagInfoSnackBar(
          title: 'Processing',
          message: 'Processing your purchase...',
        );
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        ZagLogger().error('Purchase error', purchaseDetails.error, null);
        showZagInfoSnackBar(
          title: 'Purchase Failed',
          message: 'Unable to complete purchase',
        );
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Only deliver if user initiated (purchase or manual restore)
        // Ignore auto-restore from StoreKit on app launch
        if (_userInitiatedAction) {
          _deliverProduct(purchaseDetails);
        }
      }

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }

    // Reset flag after processing
    _userInitiatedAction = false;
  }

  void _deliverProduct(PurchaseDetails purchaseDetails) async {
    // Determine if monthly or yearly
    final bool isMonthly = purchaseDetails.productID == monthlyProductId;
    final bool isRestore = purchaseDetails.status == PurchaseStatus.restored;

    // Validate receipt with server first to get real expiry date
    final validationSuccess = await _validateAndStoreReceipt(purchaseDetails);

    // Only enable Pro locally if we didn't get server validation
    // (Server validation already sets the expiry correctly)
    if (!validationSuccess) {
      // Fallback: enable with estimated expiry window
      ZagreusPro.enablePro(
        isMonthly: isMonthly,
        productId: purchaseDetails.productID,
      );
    }

    showZagInfoSnackBar(
      title: isRestore ? 'Subscription Restored' : 'Welcome to Zagreus Pro!',
      message: isRestore
          ? 'Your subscription has been restored.'
          : 'Premium features are now unlocked.',
    );
  }

  Future<bool> _validateAndStoreReceipt(PurchaseDetails purchaseDetails) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        // If no user, just store locally
        return false;
      }

      // For iOS, get the receipt data
      String? receiptData;
      if (Platform.isIOS) {
        receiptData = purchaseDetails.verificationData.localVerificationData;
      }

      if (receiptData == null) {
        return false;
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
        final subscription = response.data['subscription'];
        if (subscription is Map) {
          final productId = (subscription['product_id'] as String?) ??
              purchaseDetails.productID;
          final expiry = _parseDate(subscription['expires_date']);

          if (expiry != null) {
            ZagreusPro.applySubscription(
              expiresAt: expiry,
              productId: productId,
            );
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      // Don't block the purchase, local storage will work as fallback
      ZagLogger().debug('Receipt validation failed: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      showZagInfoSnackBar(
        title: 'Unavailable',
        message: 'In-app purchases are not available',
      );
      return;
    }

    // First try to restore from Supabase
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        // Check for active subscription in database
        final response = await supabase
            .rpc('get_active_subscription', params: {'p_user_id': user.id});

        if (response != null && (response as List).isNotEmpty) {
          final subscription = response[0];
          final expiresDate = _parseDate(subscription['expires_date']);

          if (expiresDate != null &&
              expiresDate.isAfter(DateTime.now().toUtc())) {
            final productId =
                (subscription['product_id'] as String?) ?? monthlyProductId;

            ZagreusPro.applySubscription(
              expiresAt: expiresDate,
              productId: productId,
            );

            showZagInfoSnackBar(
              title: 'Subscription Restored',
              message: 'Your Pro subscription has been restored.',
            );
            return;
          }
        }
      }
    } catch (e) {
      // Fall through to Apple restore
    }

    // Fallback to Apple's restore
    try {
      _userInitiatedAction = true;
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      ZagLogger().error('Restore purchases failed', e, null);
      showZagInfoSnackBar(
        title: 'Restore Failed',
        message: 'Unable to restore purchases',
      );
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
    }
  }

  void dispose() {
    _subscription?.cancel();
  }

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value).toUtc();
      } catch (_) {}
    }
    return null;
  }
}
