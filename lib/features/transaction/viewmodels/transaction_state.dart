import '../models/ppob_transaction_model.dart';

class TransactionState {
  final bool isLoading;
  final String? errorMessage;
  final List<PPOBTransactionModel> transactions;
  final List<String> categories;
  final TransactionFilterModel filter;

  const TransactionState({
    this.isLoading = false,
    this.errorMessage,
    this.transactions = const [],
    this.categories = const ['Semua', 'Pulsa', 'Data', 'E-Money', 'Games', 'PLN'],
    required this.filter,
  });

  TransactionState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<PPOBTransactionModel>? transactions,
    List<String>? categories,
    TransactionFilterModel? filter,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      filter: filter ?? this.filter,
    );
  }
}
