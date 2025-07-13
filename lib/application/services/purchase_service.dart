// lib/application/services/purchase_service.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_service.g.dart';

// The Set of product IDs from the Google Play Console
const Set<String> _productIds = {
  'buy_coffee_small',
  'support_dev_tier_1',
  // Add any other product IDs you create here
};

// This provider will expose the purchase service to the UI
@Riverpod(keepAlive: true)
PurchaseService purchaseService(PurchaseServiceRef ref) {
  return PurchaseService();
}

// This provider will expose the list of available products
@Riverpod(keepAlive: true)
Stream<List<ProductDetails>> products(ProductsRef ref) {
  return ref.watch(purchaseServiceProvider).products;
}

class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;
  final StreamController<List<ProductDetails>> _productsController =
      StreamController.broadcast();

  Stream<List<ProductDetails>> get products => _productsController.stream;

  PurchaseService() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _purchaseSubscription = purchaseUpdated.listen(
      (purchaseDetailsList) => _listenToPurchaseUpdates(purchaseDetailsList),
      onDone: () => _purchaseSubscription.cancel(),
      onError: (error) => debugPrint("Purchase Stream Error: $error"),
    );
    loadProducts();
  }

  // Fetch products from the store
  Future<void> loadProducts() async {
    final bool available = await _iap.isAvailable();
    if (available) {
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        _productIds,
      );
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint("Products not found: ${response.notFoundIDs}");
      }
      _productsController.add(response.productDetails);
    }
  }

  // Initiate a purchase
  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    // For consumable products, you can set `applicationUserName`
    await _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
  }

  // Listen for purchase updates
  void _listenToPurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Handle successful purchase
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void dispose() {
    _purchaseSubscription.cancel();
    _productsController.close();
  }
}
