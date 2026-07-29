class PPOBProductModel {
  final int id;
  final String productName;
  final String skuCode;
  final double basePrice;
  final double markupPrice;
  final double sellingPrice;
  final String category;
  final String brand;
  final String? description;

  PPOBProductModel({
    required this.id,
    required this.productName,
    required this.skuCode,
    required this.basePrice,
    required this.markupPrice,
    required this.sellingPrice,
    required this.category,
    required this.brand,
    this.description,
  });

  factory PPOBProductModel.fromJson(Map<String, dynamic> json) {
    final basePrice = (json['base_price'] as num?)?.toDouble() ?? 0.0;
    final markupPrice = (json['markup_price'] as num?)?.toDouble() ?? 0.0;
    final price = (json['price'] as num?)?.toDouble() ?? (basePrice + markupPrice);
    return PPOBProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      productName: json['product_name'] as String? ?? '',
      skuCode: json['sku_code'] as String? ?? '',
      basePrice: basePrice,
      markupPrice: markupPrice,
      sellingPrice: price,
      category: json['category'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}
