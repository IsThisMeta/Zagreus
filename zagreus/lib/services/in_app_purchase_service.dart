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
  static const String monthlyProductId = 'com.zagreus.pro.monthly.v2';
  static const String yearlyProductId = 'com.zagreus.pro.yearly';

  static const Set<String> _productIds = {
    monthlyProductId,
    // yearlyProductId,  // Commented out - not in StoreKit file
  };

  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  // Debug flag to disable automatic restore handling
  static bool debugIgnoreAutoRestore = true;
  // Track if user initiated a purchase
  bool _userInitiatedPurchase = false;

  Future<void> initialize() async {
    print('DEBUG: IAP initialize called');

    // Debug: Check Pro status at startup
    final proEnabled = ZagreusDatabase.ZAGREUS_PRO_ENABLED.read();
    final proExpiry = ZagreusDatabase.ZAGREUS_PRO_EXPIRY.read();
    final proType = ZagreusDatabase.ZAGREUS_PRO_SUBSCRIPTION_TYPE.read();
    final isEnabled = ZagreusPro.isEnabled;

    print('DEBUG: Pro status at startup:');
    print('  - ZAGREUS_PRO_ENABLED: $proEnabled');
    print('  - ZAGREUS_PRO_EXPIRY: $proExpiry');
    print('  - ZAGREUS_PRO_SUBSCRIPTION_TYPE: $proType');
    print('  - ZagreusPro.isEnabled: $isEnabled');

    // AGGRESSIVE TOAST
    showZagInfoSnackBar(
      title: 'IAP Debug',
      message: 'Pro: $proEnabled | Enabled: $isEnabled | Type: $proType',
    );

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
    if (!_isAvailable) {
      print('DEBUG: Skipping product load - IAP not available');
      return;
    }

    print('DEBUG: Attempting to load products: $_productIds');
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds);
      print('DEBUG: Response received');
      print('DEBUG: - Error: ${response.error}');
      print('DEBUG: - Not found IDs: ${response.notFoundIDs}');
      print('DEBUG: - Product count: ${response.productDetails.length}');

      if (response.error != null) {
        print('DEBUG: Product query error details:');
        print('  - Code: ${response.error!.code}');
        print('  - Message: ${response.error!.message}');
        print('  - Details: ${response.error!.details}');
        ZagLogger().error('Error loading products', response.error, null);
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        print('DEBUG: Products not found: ${response.notFoundIDs}');
        print('DEBUG: Make sure these product IDs exist in App Store Connect');
        ZagLogger().warning('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      print('DEBUG: Successfully loaded ${_products.length} products:');
      for (var p in _products) {
        print('DEBUG: - ID: ${p.id}');
        print('DEBUG:   Title: ${p.title}');
        print('DEBUG:   Price: ${p.price}');
        print('DEBUG:   Currency: ${p.currencyCode}');
        print('DEBUG:   Description: ${p.description}');
      }

      // AGGRESSIVE TOAST
      if (_products.isNotEmpty) {
        final p = _products.first;
        showZagInfoSnackBar(
          title: 'Product Loaded!',
          message: '${p.title} - ${p.price} ${p.currencyCode}',
        );
      } else {
        showZagInfoSnackBar(
          title: 'No Products!',
          message: 'Failed to load IAP products',
        );
      }
    } catch (e, stack) {
      print('DEBUG: Exception loading products: $e');
      print('DEBUG: Stack trace: $stack');
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
      // Mark that user initiated this purchase
      _userInitiatedPurchase = true;

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
    print('DEBUG: _onPurchaseUpdate called with ${purchaseDetailsList.length} items');

    // AGGRESSIVE TOAST
    showZagInfoSnackBar(
      title: 'Purchase Event!',
      message: '${purchaseDetailsList.length} items | Status: ${purchaseDetailsList.firstOrNull?.status}',
    );

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      print('DEBUG: Purchase status: ${purchaseDetails.status}');
      print('DEBUG: Product ID: ${purchaseDetails.productID}');
      print('DEBUG: Transaction ID: ${purchaseDetails.purchaseID}');
      print('DEBUG: Verification data: ${purchaseDetails.verificationData.localVerificationData}');

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

        // Check if this is an auto-restore we should ignore
        // Only block restores if user didn't initiate a purchase
        if (debugIgnoreAutoRestore &&
            purchaseDetails.status == PurchaseStatus.restored &&
            !_userInitiatedPurchase) {
          print('DEBUG: IGNORING AUTO-RESTORE (not user initiated)');
          print('DEBUG: Would have delivered: ${purchaseDetails.productID}');

          // AGGRESSIVE TOAST
          showZagInfoSnackBar(
            title: 'BLOCKED AUTO-RESTORE',
            message: 'Ignored ${purchaseDetails.productID}',
          );
        } else {
          print('DEBUG: DELIVERING PRODUCT - This is what enables Pro!');

          // AGGRESSIVE TOAST
          showZagInfoSnackBar(
            title: _userInitiatedPurchase ? 'PURCHASE SUCCESS!' : 'DELIVERING PRODUCT!',
            message: 'Enabling Pro for ${purchaseDetails.productID}',
          );

          // Verify and deliver the purchase
          _deliverProduct(purchaseDetails);

          // Reset flag after delivering
          _userInitiatedPurchase = false;
        }
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
    // Mark as user-initiated restore
    _userInitiatedPurchase = true;

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
      // Temporarily allow restores when manually triggered
      debugIgnoreAutoRestore = false;
      await _inAppPurchase.restorePurchases();
      // Wait a bit then re-enable the flag
      Future.delayed(Duration(seconds: 5), () {
        debugIgnoreAutoRestore = true;
      });
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
