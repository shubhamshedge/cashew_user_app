import 'package:cashew_store/features/cart/data/models/cart_item_model.dart';

enum CartStatus { initial, loading, loaded, error }

class AppliedCoupon {
  final String id;
  final String code;
  final String description;
  final String discountType; // 'PERCENTAGE' or 'FIXED'
  final double discountValue;
  final double discountAmount;

  const AppliedCoupon({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
  });

  factory AppliedCoupon.fromJson(Map<String, dynamic> json) {
    final coupon = json['coupon'] as Map<String, dynamic>? ?? {};
    return AppliedCoupon(
      id: coupon['id']?.toString() ?? '',
      code: coupon['code']?.toString() ?? '',
      description: coupon['description']?.toString() ?? '',
      discountType: coupon['discountType']?.toString() ?? 'FIXED',
      discountValue: (coupon['discountValue'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CartState {
  final CartStatus status;
  final List<CartItemModel> items;
  final String? errorMessage;
  final AppliedCoupon? appliedCoupon;
  final List<Map<String, dynamic>> availableCoupons;
  final String? couponError;
  final bool isApplyingCoupon;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.appliedCoupon,
    this.availableCoupons = const [],
    this.couponError,
    this.isApplyingCoupon = false,
  });

  int get totalItemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);

  double get discountAmount => appliedCoupon?.discountAmount ?? 0.0;

  double get grandTotal => (subtotal - discountAmount) > 0 ? (subtotal - discountAmount) : 0.0;

  CartState copyWith({
    CartStatus? status,
    List<CartItemModel>? items,
    String? errorMessage,
    AppliedCoupon? appliedCoupon,
    bool clearAppliedCoupon = false,
    List<Map<String, dynamic>>? availableCoupons,
    String? couponError,
    bool clearCouponError = false,
    bool? isApplyingCoupon,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      appliedCoupon: clearAppliedCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      availableCoupons: availableCoupons ?? this.availableCoupons,
      couponError: clearCouponError ? null : (couponError ?? this.couponError),
      isApplyingCoupon: isApplyingCoupon ?? this.isApplyingCoupon,
    );
  }
}
