import 'package:cashew_store/features/home/data/models/product_model.dart';

class CartItemModel {
  final String? id;
  final String? cartId;
  final ProductModel product;
  final ProductVariantModel variant;
  final int quantity;

  const CartItemModel({
    this.id,
    this.cartId,
    required this.product,
    required this.variant,
    required this.quantity,
  });

  double get totalPrice => variant.price * quantity;

  CartItemModel copyWith({
    String? id,
    String? cartId,
    ProductModel? product,
    ProductVariantModel? variant,
    int? quantity,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      product: product ?? this.product,
      variant: variant ?? this.variant,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString(),
      cartId: json['cartId']?.toString(),
      quantity: json['quantity'] != null ? (json['quantity'] as num).toInt() : 1,
      variant: ProductVariantModel.fromJson(json['variant'] as Map<String, dynamic>),
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cartId': cartId,
      'variantId': variant.id,
      'quantity': quantity,
    };
  }
}
