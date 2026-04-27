import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenue_cat_service.dart';
import 'auth_provider.dart';

class SubscriptionState {
  final bool isPremium;
  final bool isLoading;
  final CustomerInfo? customerInfo;
  final Offerings? offerings;

  SubscriptionState({
    this.isPremium = false,
    this.isLoading = false,
    this.customerInfo,
    this.offerings,
  });

  SubscriptionState copyWith({
    bool? isPremium,
    bool? isLoading,
    CustomerInfo? customerInfo,
    Offerings? offerings,
  }) {
    return SubscriptionState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      customerInfo: customerInfo ?? this.customerInfo,
      offerings: offerings ?? this.offerings,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier(this.ref) : super(SubscriptionState()) {
    _init();
    // Listen to auth changes to login/logout of RevenueCat
    ref.listen(authStateProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        RevenueCatService.login(user.uid).then((_) => refreshStatus());
      } else {
        RevenueCatService.logout().then((_) => refreshStatus());
      }
    });
  }

  final Ref ref;

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    
    // Check if user is already logged in
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      await RevenueCatService.login(user.uid);
    }
    
    await refreshStatus();
    state = state.copyWith(isLoading: false);
  }

  Future<void> refreshStatus() async {
    final customerInfo = await RevenueCatService.getCustomerInfo();
    final offerings = await RevenueCatService.getOfferings();
    
    state = state.copyWith(
      customerInfo: customerInfo,
      offerings: offerings,
      isPremium: customerInfo?.entitlements.all[RevenueCatService.entitlementId]?.isActive ?? false,
    );
  }

  Future<bool> purchasePackage(Package package) async {
    state = state.copyWith(isLoading: true);
    final success = await RevenueCatService.purchasePackage(package);
    await refreshStatus();
    state = state.copyWith(isLoading: false);
    return success;
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    await RevenueCatService.restorePurchases();
    await refreshStatus();
    state = state.copyWith(isLoading: false);
  }

  Future<String?> presentPaywall() async {
    final error = await RevenueCatService.presentPaywall();
    await refreshStatus();
    return error;
  }

  Future<void> presentPaywallIfNeeded() async {
    await RevenueCatService.presentPaywallIfNeeded();
    await refreshStatus();
  }

  Future<void> presentCustomerCenter() async {
    await RevenueCatService.presentCustomerCenter();
    await refreshStatus();
  }
}

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref);
});
