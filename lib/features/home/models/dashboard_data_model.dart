class DashboardStats {
  final double totalRevenue;
  final int totalTransactions;
  final int activeUsers;
  final int totalCustomers;
  final double revenueGrowth;
  final double transactionGrowth;

  DashboardStats({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.activeUsers,
    required this.totalCustomers,
    required this.revenueGrowth,
    required this.transactionGrowth,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalTransactions: (json['total_transactions'] as num?)?.toInt() ?? 0,
      activeUsers: (json['active_users'] as num?)?.toInt() ?? 0,
      totalCustomers: (json['total_customers'] as num?)?.toInt() ?? 0,
      revenueGrowth: (json['revenue_growth'] as num?)?.toDouble() ?? 0.0,
      transactionGrowth: (json['transaction_growth'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class HomePPOBTransaction {
  final int id;
  final String refId;
  final String buyerSkuCode;
  final String productName;
  final String customerNo;
  final double price;
  final double sellingPrice;
  final String status;
  final String createdAt;
  final String? category;
  final String? brand;

  HomePPOBTransaction({
    required this.id,
    required this.refId,
    required this.buyerSkuCode,
    required this.productName,
    required this.customerNo,
    required this.price,
    required this.sellingPrice,
    required this.status,
    required this.createdAt,
    this.category,
    this.brand,
  });

  factory HomePPOBTransaction.fromJson(Map<String, dynamic> json) {
    return HomePPOBTransaction(
      id: (json['id'] as num?)?.toInt() ?? 0,
      refId: json['ref_id'] as String? ?? '',
      buyerSkuCode: json['buyer_sku_code'] as String? ?? '',
      productName: json['product_name'] as String? ?? 'Transaksi PPOB',
      customerNo: json['customer_no'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Pending',
      createdAt: json['created_at'] as String? ?? '',
      category: json['category'] as String?,
      brand: json['brand'] as String?,
    );
  }
}

class DashboardDataModel {
  final DashboardStats stats;
  final List<HomePPOBTransaction> recentTransactions;

  DashboardDataModel({
    required this.stats,
    required this.recentTransactions,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    final statsJson = json['stats'] as Map<String, dynamic>? ?? {};
    final recentTxList = json['recent_transactions'] as List? ?? [];
    
    return DashboardDataModel(
      stats: DashboardStats.fromJson(statsJson),
      recentTransactions: recentTxList
          .map((tx) => HomePPOBTransaction.fromJson(tx as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UserProfileModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String role;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'User',
    );
  }
}
