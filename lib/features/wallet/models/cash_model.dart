class CashSummaryModel {
  final double totalIn;
  final double totalOut;
  final double totalProcessing;
  final double currentBalance;

  CashSummaryModel({
    required this.totalIn,
    required this.totalOut,
    required this.totalProcessing,
    required this.currentBalance,
  });

  factory CashSummaryModel.fromJson(Map<String, dynamic> json) {
    return CashSummaryModel(
      totalIn: (json['total_in'] as num?)?.toDouble() ?? 0.0,
      totalOut: (json['total_out'] as num?)?.toDouble() ?? 0.0,
      totalProcessing: (json['total_processing'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CashTransactionItem {
  final int id;
  final double amount;
  final String type; // 'in' or 'out'
  final String status; // 'success', 'pending', 'failed', 'processing'
  final String description;
  final String? referenceId;
  final String createdAt;

  CashTransactionItem({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    this.referenceId,
    required this.createdAt,
  });

  factory CashTransactionItem.fromJson(Map<String, dynamic> json) {
    return CashTransactionItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? 'in',
      status: json['status'] as String? ?? 'success',
      description: json['description'] as String? ?? 'Transaksi Uang Kas',
      referenceId: json['reference_id'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
