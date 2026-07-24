import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/core/errors/app_exception.dart';
import '../models/ppob_transaction_model.dart';
import '../providers/transaction_providers.dart';
import 'transaction_state.dart';

class TransactionViewModel extends Notifier<TransactionState> {
  @override
  TransactionState build() {
    final initialState = TransactionState(filter: TransactionFilterModel());
    Future.microtask(() => loadInitialData());
    return initialState;
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final service = ref.read(transactionServiceProvider);
      
      final fetchedCategories = await service.getCategories();
      final categoryList = ['Semua', ...fetchedCategories];

      final transactions = await service.getTransactions(state.filter);

      state = state.copyWith(
        isLoading: false,
        categories: categoryList,
        transactions: transactions,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat transaksi PPOB.',
      );
    }
  }

  Future<void> fetchTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final service = ref.read(transactionServiceProvider);
      final transactions = await service.getTransactions(state.filter);

      state = state.copyWith(
        isLoading: false,
        transactions: transactions,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat transaksi.',
      );
    }
  }

  void setSearch(String search) {
    final updatedFilter = state.filter.copyWith(search: search, page: 1);
    state = state.copyWith(filter: updatedFilter);
    fetchTransactions();
  }

  void setCategory(String category) {
    final selectedCat = category == 'Semua' ? '' : category;
    final updatedFilter = state.filter.copyWith(category: selectedCat, page: 1);
    state = state.copyWith(filter: updatedFilter);
    fetchTransactions();
  }

  void setStatus(String status) {
    final selectedStatus = status == 'Semua' ? '' : status;
    final updatedFilter = state.filter.copyWith(status: selectedStatus, page: 1);
    state = state.copyWith(filter: updatedFilter);
    fetchTransactions();
  }
}

final transactionViewModelProvider = NotifierProvider<TransactionViewModel, TransactionState>(
  TransactionViewModel.new,
);
