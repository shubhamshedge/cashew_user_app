import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';

abstract class ProductState {
  const ProductState();
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final String? selectedCategoryId;

  const ProductLoaded({
    required this.products,
    required this.categories,
    this.selectedCategoryId,
  });
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
}
