class ProductVariantModel {
  final String id;
  final String productId;
  final String variantName;
  final String sku;
  final String? weightGrams;
  final double price;
  final double? compareAtPrice;
  final int stockQuantity;

  const ProductVariantModel({
    required this.id,
    required this.productId,
    required this.variantName,
    required this.sku,
    this.weightGrams,
    required this.price,
    this.compareAtPrice,
    required this.stockQuantity,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      variantName: json['variant_name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      weightGrams: json['weight_grams']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      compareAtPrice: json['compare_at_price'] != null
          ? double.tryParse(json['compare_at_price'].toString())
          : null,
      stockQuantity: int.tryParse(json['stock_quantity']?.toString() ?? '0') ?? 0,
    );
  }
}

class ProductImageModel {
  final String id;
  final String productId;
  final String imageUrl;
  final String? altText;
  final int sortOrder;
  final bool isPrimary;

  const ProductImageModel({
    required this.id,
    required this.productId,
    required this.imageUrl,
    this.altText,
    this.sortOrder = 0,
    this.isPrimary = false,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      altText: json['alt_text']?.toString(),
      sortOrder: int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
      isPrimary: json['is_primary'] == 1 || json['is_primary'] == true,
    );
  }
}

class ProductModel {
  final String id;
  final String? categoryId;
  final String name;
  final String slug;
  final String? description;
  final String? primaryImageUrl;
  final String? categoryName;
  final List<ProductVariantModel> variants;
  final List<ProductImageModel> images;

  const ProductModel({
    required this.id,
    this.categoryId,
    required this.name,
    required this.slug,
    this.description,
    this.primaryImageUrl,
    this.categoryName,
    required this.variants,
    this.images = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawVariants = json['variants'];
    final variantsList = (rawVariants is List)
        ? rawVariants.map((v) => ProductVariantModel.fromJson(v as Map<String, dynamic>)).toList()
        : <ProductVariantModel>[];

    final rawImages = json['images'];
    final imagesList = (rawImages is List)
        ? rawImages.map((img) => ProductImageModel.fromJson(img as Map<String, dynamic>)).toList()
        : <ProductImageModel>[];

    return ProductModel(
      id: json['id']?.toString() ?? '',
      categoryId: json['category_id']?.toString(),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      primaryImageUrl: json['primary_image_url']?.toString(),
      categoryName: json['category_name']?.toString(),
      variants: variantsList,
      images: imagesList,
    );
  }

  double get displayPrice {
    if (variants.isNotEmpty) {
      return variants.first.price;
    }
    return 0.0;
  }

  double? get displayComparePrice {
    if (variants.isNotEmpty) {
      return variants.first.compareAtPrice;
    }
    return null;
  }

  String get displayPackSize {
    if (variants.isNotEmpty) {
      return variants.first.variantName;
    }
    return '250g';
  }

  List<String> get allImageUrls {
    final urls = <String>[];
    for (final img in images) {
      if (img.imageUrl.isNotEmpty && !urls.contains(img.imageUrl)) {
        urls.add(img.imageUrl);
      }
    }
    if (primaryImageUrl != null && primaryImageUrl!.isNotEmpty && !urls.contains(primaryImageUrl)) {
      urls.insert(0, primaryImageUrl!);
    }
    return urls;
  }
}
