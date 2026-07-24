import '../models/cash_model.dart';

class CashState {
  final bool isLoading;
  final String? errorMessage;
  final CashSummaryModel? summary;
  final List<CashTransactionItem> transactions;
  final String activeTabFilter; // 'all', 'in', 'out'

  const CashState({
    this.isLoading = false,
    this.errorMessage,
    this.summary,
    this.transactions = const [],
    this.activeTabFilter = 'all',
  });

  CashState copyWith({
    bool? isLoading,
    String? errorMessage,
    CashSummaryModel? summary,
    List<CashTransactionItem>? transactions,
    String? activeTabFilter,
  }) {
    return CashState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      summary: summary ?? this.summary,
      transactions: transactions ?? this.transactions,
      activeTabFilter: activeTabFilter ?? this.activeTabFilter,
    );
  }
}
