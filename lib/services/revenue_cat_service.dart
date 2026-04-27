import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class RevenueCatService {
  static const _apiKey = 'goog_LOGykfKJkDhmhlAdbCvwTClOget';
  static const entitlementId = 'wardrobe-palette Pro';

  static Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration = PurchasesConfiguration(_apiKey);
    // Note: In a real app, you might have different keys for Android and iOS.
    // But the user provided one "test" key.
    
    await Purchases.configure(configuration);
  }

  static Future<void> login(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('Error logging into RevenueCat: $e');
    }
  }

  static Future<void> logout() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('Error logging out of RevenueCat: $e');
    }
  }

  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('Error getting customer info: $e');
      return null;
    }
  }

  static Future<bool> isPremium() async {
    final customerInfo = await getCustomerInfo();
    return customerInfo?.entitlements.all[entitlementId]?.isActive ?? false;
  }

  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('Error getting offerings: $e');
      return null;
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      return result.customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('Error purchasing package: $e');
      return false;
    }
  }

  static Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }

  // RevenueCat Paywall
  static Future<String?> presentPaywall({bool displayCloseButton = true}) async {
    try {
      await RevenueCatUI.presentPaywall(displayCloseButton: displayCloseButton);
      return null;
    } catch (e) {
      debugPrint('Error presenting paywall: $e');
      return e.toString();
    }
  }

  static Future<void> presentPaywallIfNeeded({String? requiredEntitlement}) async {
    try {
      await RevenueCatUI.presentPaywallIfNeeded(
        requiredEntitlement ?? entitlementId,
        displayCloseButton: true,
      );
    } catch (e) {
      debugPrint('Error presenting paywall if needed: $e');
    }
  }

  // RevenueCat Customer Center
  static Future<void> presentCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('Error presenting customer center: $e');
    }
  }
}
