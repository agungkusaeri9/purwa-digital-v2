import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/core/errors/app_exception.dart';
import '../providers/cash_providers.dart';
import 'cash_state.dart';

class CashViewModel extends Notifier<CashState> {
  @override
  CashState build() {
    Future.microtask(() => loadData());
    return const CashState(isLoading: true);
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final service = ref.read(cashServiceProvider);
      
      final results = await Future.wait([
        service.getSummary(),
        service.getTransactions(type: state.activeTabFilter),
      ]);

      state = state.copyWith(
        isLoading: false,
        summary: results[0] as dynamic,
        transactions: results[1] as dynamic,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat data uang kas.',
      );
    }
  }

  Future<void> setTabFilter(String filter) async {
    state = state.copyWith(activeTabFilter: filter);
    await loadData();
  }

  Future<bool> addCashTransaction({
    required double amount,
    required String type,
    required String description,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final service = ref.read(cashServiceProvider);
      await service.createTransaction(
        amount: amount,
        type: type,
        description: description,
      );
      await loadData();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menambah transaksi kas.',
      );
      return false;
    }
  }
}

final cashViewModelProvider = NotifierProvider<CashViewModel, CashState>(
  CashViewModel.new,
);
