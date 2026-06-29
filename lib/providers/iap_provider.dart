import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum PlanType { free, subscription, lifetime }

class IapState {
  final PlanType planType;
  final bool isLoading;
  final String? error;

  const IapState({
    this.planType = PlanType.free,
    this.isLoading = false,
    this.error,
  });

  bool get hasPremium => planType != PlanType.free;

  IapState copyWith({PlanType? planType, bool? isLoading, String? error}) => IapState(
    planType: planType ?? this.planType,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class IapNotifier extends StateNotifier<IapState> {
  IapNotifier() : super(const IapState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final info = await Purchases.getCustomerInfo();
      _updateFromCustomerInfo(info);
    } catch (_) {}
  }

  void _updateFromCustomerInfo(CustomerInfo info) {
    final entitlements = info.entitlements.active;
    PlanType plan = PlanType.free;

    if (entitlements.containsKey('lifetime')) {
      plan = PlanType.lifetime;
    } else if (entitlements.containsKey('premium')) {
      plan = PlanType.subscription;
    }

    state = state.copyWith(planType: plan);
  }

  Future<bool> purchaseSubscription() async {
    state = state.copyWith(isLoading: true);
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;
      if (offering == null) {
        state = state.copyWith(isLoading: false, error: 'オファリングが見つかりません');
        return false;
      }
      final monthly = offering.monthly;
      if (monthly == null) {
        state = state.copyWith(isLoading: false, error: '月額プランが見つかりません');
        return false;
      }
      final info = await Purchases.purchaseStoreProduct(monthly.storeProduct);
      _updateFromCustomerInfo(info);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> purchaseLifetime() async {
    state = state.copyWith(isLoading: true);
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;
      if (offering == null) {
        state = state.copyWith(isLoading: false, error: 'オファリングが見つかりません');
        return false;
      }
      final lifetime = offering.lifetime;
      if (lifetime == null) {
        state = state.copyWith(isLoading: false, error: '買い切りプランが見つかりません');
        return false;
      }
      final info = await Purchases.purchaseStoreProduct(lifetime.storeProduct);
      _updateFromCustomerInfo(info);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    try {
      final info = await Purchases.restorePurchases();
      _updateFromCustomerInfo(info);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final iapProvider = StateNotifierProvider<IapNotifier, IapState>(
  (ref) => IapNotifier(),
);
