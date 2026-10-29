import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cart_item_model.dart';

abstract class CartRepository {
  Future<List<CartItemModel>> getCart();
  Future<List<CartItemModel>> addToCart(String variantId, int quantity);
  Future<List<CartItemModel>> updateItemQuantity(String cartItemId, int quantity);
  Future<List<CartItemModel>> removeCartItem(String cartItemId);
  Future<void> clearCart();
  Future<Map<String, dynamic>> applyCoupon(String code);
  Future<List<Map<String, dynamic>>> getCoupons();
}

class CartRepositoryImpl implements CartRepository {
  final DioClient _dioClient;

  CartRepositoryImpl(this._dioClient);

  List<CartItemModel> _parseCartItems(dynamic response) {
    if (response is Map<String, dynamic> && response.containsKey('items')) {
      final list = response['items'] as List<dynamic>;
      return list.map((item) => CartItemModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<CartItemModel>> getCart() async {
    try {
      final response = await _dioClient.get('/cart');
      return _parseCartItems(response);
    } catch (e) {
      debugPrint('CartRepository.getCart error: $e');
      rethrow;
    }
  }

  @override
  Future<List<CartItemModel>> addToCart(String variantId, int quantity) async {
    try {
      final response = await _dioClient.post(
        '/cart/items',
        data: {
          'variantId': variantId,
          'quantity': quantity,
        },
      );
      return _parseCartItems(response);
    } catch (e) {
      debugPrint('CartRepository.addToCart error: $e');
      rethrow;
    }
  }

  @override
  Future<List<CartItemModel>> updateItemQuantity(String cartItemId, int quantity) async {
    try {
      final response = await _dioClient.put(
        '/cart/items/$cartItemId',
        data: {'quantity': quantity},
      );
      return _parseCartItems(response);
    } catch (e) {
      debugPrint('CartRepository.updateItemQuantity error: $e');
      rethrow;
    }
  }

  @override
  Future<List<CartItemModel>> removeCartItem(String cartItemId) async {
    try {
      final response = await _dioClient.delete('/cart/items/$cartItemId');
      return _parseCartItems(response);
    } catch (e) {
      debugPrint('CartRepository.removeCartItem error: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _dioClient.delete('/cart');
    } catch (e) {
      debugPrint('CartRepository.clearCart error: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> applyCoupon(String code) async {
    try {
      final response = await _dioClient.post(
        '/cart/apply-coupon',
        data: {'code': code},
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return {};
    } catch (e) {
      debugPrint('CartRepository.applyCoupon error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCoupons() async {
    try {
      final response = await _dioClient.get('/cart/coupons');
      if (response is List) {
        return response.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('CartRepository.getCoupons error: $e');
      return [];
    }
  }
}
