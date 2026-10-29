class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }
}
