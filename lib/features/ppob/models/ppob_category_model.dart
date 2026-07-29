class PPOBCategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? logoUrl;

  PPOBCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
  });

  factory PPOBCategoryModel.fromJson(Map<String, dynamic> json) {
    return PPOBCategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      logoUrl: (json['logo'] as String?) ?? (json['logo_url'] as String?),
    );
  }
}
