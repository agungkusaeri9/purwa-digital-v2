class PPOBTransactionModel {
  final int id;
  final String refId;
  final String buyerSkuCode;
  final String productName;
  final String customerNo;
  final String? waNumber;
  final double price;
  final double markupPrice;
  final double sellingPrice;
  final String status;
  final String? sn;
  final String? message;
  final String? category;
  final String? brand;
  final String createdAt;

  PPOBTransactionModel({
    required this.id,
    required this.refId,
    required this.buyerSkuCode,
    required this.productName,
    required this.customerNo,
    this.waNumber,
    required this.price,
    required this.markupPrice,
    required this.sellingPrice,
    required this.status,
    this.sn,
    this.message,
    this.category,
    this.brand,
    required this.createdAt,
  });

  factory PPOBTransactionModel.fromJson(Map<String, dynamic> json) {
    return PPOBTransactionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      refId: json['ref_id'] as String? ?? '',
      buyerSkuCode: json['buyer_sku_code'] as String? ?? '',
      productName: json['product_name'] as String? ?? 'Transaksi PPOB',
      customerNo: json['customer_no'] as String? ?? '',
      waNumber: json['wa_number'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      markupPrice: (json['markup_price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Pending',
      sn: json['sn'] as String?,
      message: json['message'] as String?,
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class TransactionFilterModel {
  final String search;
  final String category;
  final String brand;
  final String status;
  final int page;
  final int limit;

  TransactionFilterModel({
    this.search = '',
    this.category = '',
    this.brand = '',
    this.status = '',
    this.page = 1,
    this.limit = 20,
  });

  TransactionFilterModel copyWith({
    String? search,
    String? category,
    String? brand,
    String? status,
    int? page,
    int? limit,
  }) {
    return TransactionFilterModel(
      search: search ?? this.search,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      status: status ?? this.status,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search.isNotEmpty) params['search'] = search;
    if (category.isNotEmpty && category != 'Semua') params['category'] = category;
    if (brand.isNotEmpty && brand != 'Semua') params['brand'] = brand;
    if (status.isNotEmpty && status != 'Semua') params['status'] = status;
    return params;
  }
}
