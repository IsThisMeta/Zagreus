import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:collection/collection.dart';

class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
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
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _onDone,
      onError: _onError,
    );
    
    // Restore previous purchases
    await restorePurchases();
  }
  
  Future<void> loadProducts() async {
    if (!_isAvailable) return;
    
    print('DEBUG: Attempting to load products: $_productIds');
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
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
  
  void _deliverProduct(PurchaseDetails purchaseDetails) {
    // Determine if monthly or yearly
    final bool isMonthly = purchaseDetails.productID == monthlyProductId;
    
    // Enable Pro
    ZagreusPro.enablePro(isMonthly: isMonthly);
    
    showZagInfoSnackBar(
      title: 'Welcome to Zagreus Pro!',
      message: 'Premium features are now unlocked',
    );
  }
  
  Future<void> restorePurchases() async {
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
  
  void dispose() {
    _subscription?.cancel();
  }
  
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
}