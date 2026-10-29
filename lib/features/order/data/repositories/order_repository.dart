import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../models/order_model.dart';

abstract class OrderRepository {
  Future<OrderModel> createOrder({
    required String addressId,
    String paymentMethod = 'COD',
    String? couponCode,
    String? customerNote,
  });
  Future<List<OrderModel>> getMyOrders();
}

class OrderRepositoryImpl implements OrderRepository {
  final DioClient _dioClient;

  OrderRepositoryImpl(this._dioClient);

  @override
  Future<OrderModel> createOrder({
    required String addressId,
    String paymentMethod = 'COD',
    String? couponCode,
    String? customerNote,
  }) async {
    try {
      final payload = {
        'addressId': addressId,
        'paymentMethod': paymentMethod,
        if (couponCode != null && couponCode.isNotEmpty) 'couponCode': couponCode,
        if (customerNote != null && customerNote.isNotEmpty) 'customerNote': customerNote,
      };

      final response = await _dioClient.post('/orders', data: payload);
      if (response is Map<String, dynamic>) {
        return OrderModel.fromJson(response);
      }
      throw Exception('Unexpected response format when creating order');
    } catch (e) {
      debugPrint('OrderRepository.createOrder error: $e');
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await _dioClient.get('/orders');
      if (response is List) {
        return response
            .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('OrderRepository.getMyOrders error: $e');
      rethrow;
    }
  }
}
