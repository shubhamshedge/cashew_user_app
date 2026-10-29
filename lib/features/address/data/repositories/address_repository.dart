import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../models/address_model.dart';

abstract class AddressRepository {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> createAddress(Map<String, dynamic> data);
  Future<List<AddressModel>> setDefaultAddress(String addressId);
  Future<List<AddressModel>> deleteAddress(String addressId);
}

class AddressRepositoryImpl implements AddressRepository {
  final DioClient _dioClient;

  AddressRepositoryImpl(this._dioClient);

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _dioClient.get('/addresses');
      if (response is List) {
        return response
            .map((item) => AddressModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('AddressRepository.getAddresses error: $e');
      rethrow;
    }
  }

  @override
  Future<AddressModel> createAddress(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/addresses', data: data);
      if (response is Map<String, dynamic>) {
        return AddressModel.fromJson(response);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      debugPrint('AddressRepository.createAddress error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AddressModel>> setDefaultAddress(String addressId) async {
    try {
      final response = await _dioClient.put('/addresses/$addressId/default');
      if (response is List) {
        return response
            .map((item) => AddressModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('AddressRepository.setDefaultAddress error: $e');
      rethrow;
    }
  }

  @override
  Future<List<AddressModel>> deleteAddress(String addressId) async {
    try {
      final response = await _dioClient.delete('/addresses/$addressId');
      if (response is List) {
        return response
            .map((item) => AddressModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('AddressRepository.deleteAddress error: $e');
      rethrow;
    }
  }
}
