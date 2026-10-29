import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashew_store/core/network/api_exception.dart';
import 'package:cashew_store/features/home/data/models/product_model.dart';
import 'package:cashew_store/features/cart/data/models/cart_item_model.dart';
import 'package:cashew_store/features/cart/data/repositories/cart_repository.dart';
import 'package:cashew_store/features/cart/presentation/cubit/cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepository;

  CartCubit(this._cartRepository) : super(const CartState());

  /// Load current user's cart from MySQL database
  Future<void> loadCart() async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final items = await _cartRepository.getCart();
      emit(state.copyWith(
        status: CartStatus.loaded,
        items: items,
      ));
      loadAvailableCoupons();
    } catch (e) {
      debugPrint('CartCubit.loadCart error: $e');
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Add item to MySQL cart database and update state
  Future<void> addToCart(
    ProductModel product,
    ProductVariantModel variant, {
    int quantity = 1,
  }) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final updatedItems = await _cartRepository.addToCart(variant.id, quantity);
      emit(state.copyWith(
        status: CartStatus.loaded,
        items: updatedItems,
      ));
    } catch (e) {
      debugPrint('CartCubit.addToCart network error, updating locally: $e');
      final currentItems = List<CartItemModel>.from(state.items);
      final index = currentItems.indexWhere(
        (item) => item.product.id == product.id && item.variant.id == variant.id,
      );

      if (index >= 0) {
        final existing = currentItems[index];
        currentItems[index] = existing.copyWith(quantity: existing.quantity + quantity);
      } else {
        currentItems.add(
          CartItemModel(
            product: product,
            variant: variant,
            quantity: quantity,
          ),
        );
      }

      emit(state.copyWith(
        status: CartStatus.loaded,
        items: currentItems,
      ));
    }
  }

  /// Update item quantity in MySQL
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      final updatedItems = await _cartRepository.updateItemQuantity(cartItemId, quantity);
      emit(state.copyWith(
        status: CartStatus.loaded,
        items: updatedItems,
      ));
    } catch (e) {
      debugPrint('CartCubit.updateQuantity error: $e');
    }
  }

  /// Remove item from MySQL cart
  Future<void> removeCartItem(String cartItemId) async {
    try {
      final updatedItems = await _cartRepository.removeCartItem(cartItemId);
      emit(state.copyWith(
        status: CartStatus.loaded,
        items: updatedItems,
      ));
    } catch (e) {
      debugPrint('CartCubit.removeCartItem error: $e');
    }
  }

  /// Clear entire cart in MySQL
  Future<void> clearCart() async {
    try {
      await _cartRepository.clearCart();
      emit(const CartState(
        status: CartStatus.loaded,
        items: [],
      ));
    } catch (e) {
      debugPrint('CartCubit.clearCart error: $e');
      emit(const CartState(
        status: CartStatus.loaded,
        items: [],
      ));
    }
  }

  /// Load available promo coupons from MySQL
  Future<void> loadAvailableCoupons() async {
    try {
      final coupons = await _cartRepository.getCoupons();
      emit(state.copyWith(availableCoupons: coupons));
    } catch (e) {
      debugPrint('CartCubit.loadAvailableCoupons error: $e');
    }
  }

  /// Validate and apply coupon using MySQL backend
  Future<bool> applyCoupon(String code) async {
    emit(state.copyWith(isApplyingCoupon: true, clearCouponError: true));
    try {
      final res = await _cartRepository.applyCoupon(code);
      final applied = AppliedCoupon.fromJson(res);
      emit(state.copyWith(
        isApplyingCoupon: false,
        appliedCoupon: applied,
        clearCouponError: true,
      ));
      return true;
    } catch (e) {
      String msg = 'Failed to apply coupon';
      if (e is ApiException) {
        msg = e.message;
      } else {
        msg = e.toString();
      }
      emit(state.copyWith(
        isApplyingCoupon: false,
        couponError: msg,
      ));
      return false;
    }
  }

  /// Remove applied coupon
  void removeCoupon() {
    emit(state.copyWith(
      clearAppliedCoupon: true,
      clearCouponError: true,
    ));
  }
}
