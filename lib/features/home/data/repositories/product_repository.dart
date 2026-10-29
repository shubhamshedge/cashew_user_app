import '../../../../core/network/dio_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts({String? categoryId, String? search});
  Future<List<CategoryModel>> getCategories();
  Future<ProductModel?> getProductById(String id);
}

class ProductRepositoryImpl implements ProductRepository {
  final DioClient _dioClient;

  ProductRepositoryImpl(this._dioClient);

  @override
  Future<List<ProductModel>> getProducts({String? categoryId, String? search}) async {
    final queryParams = <String, dynamic>{};
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _dioClient.get(
      '/products',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response is Map<String, dynamic> && response.containsKey('products')) {
      final list = response['products'] as List<dynamic>;
      return list.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _dioClient.get('/products/categories');
    if (response is List) {
      return response.map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    try {
      final response = await _dioClient.get('/products/$id');
      if (response is Map<String, dynamic>) {
        return ProductModel.fromJson(response);
      }
    } catch (_) {}
    return null;
  }
}
