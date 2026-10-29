import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/product_repository.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _productRepository;
  List<CategoryModel> _cachedCategories = [];

  ProductCubit(this._productRepository) : super(ProductInitial());

  Future<void> loadDashboardData() async {
    try {
      emit(ProductLoading());
      final categories = await _productRepository.getCategories();
      _cachedCategories = categories;

      final products = await _productRepository.getProducts();

      emit(ProductLoaded(
        products: products,
        categories: categories,
        selectedCategoryId: null,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> filterByCategory(String? categoryId) async {
    try {
      emit(ProductLoading());
      final products = await _productRepository.getProducts(categoryId: categoryId);
      emit(ProductLoaded(
        products: products,
        categories: _cachedCategories,
        selectedCategoryId: categoryId,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
