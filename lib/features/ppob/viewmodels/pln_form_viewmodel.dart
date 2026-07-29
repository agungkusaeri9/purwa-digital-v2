import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ppob_service.dart';
import '../models/ppob_product_model.dart';
import 'pln_form_state.dart';
import 'pulsa_form_viewmodel.dart'; // Reuse ppobServiceProvider

final plnFormViewModelProvider =
    StateNotifierProvider.autoDispose<PlnFormViewModel, PlnFormState>((ref) {
  final service = ref.watch(ppobServiceProvider);
  return PlnFormViewModel(service);
});

class PlnFormViewModel extends StateNotifier<PlnFormState> {
  final PPOBService _service;

  PlnFormViewModel(this._service) : super(PlnFormState()) {
    fetchProducts();
  }

  void setCustomerNumber(String number) {
    // Only allow digits
    final clean = number.replaceAll(RegExp(r'\D'), '');
    state = state.copyWith(
      customerNumber: clean,
    );
  }

  void selectProduct(PPOBProductModel product) {
    state = state.copyWith(selectedProduct: product);
  }

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _service.getProducts(category: 'PLN', brand: 'PLN');
      
      // Filter out utility products like verification checks ("Cek Nama Token PLN")
      final filteredList = list.where((p) => !p.productName.toLowerCase().contains('cek')).toList();
      
      // Sort nominals by price ascending
      filteredList.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));

      state = state.copyWith(
        products: filteredList,
        isLoading: false,
        selectedProduct: filteredList.isNotEmpty ? filteredList.first : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mengambil produk PLN: ${e.toString()}',
      );
    }
  }

  Future<String?> submitTransaction({String? pin}) async {
    if (state.selectedProduct == null || state.customerNumber.isEmpty) {
      state = state.copyWith(errorMessage: 'ID Pelanggan atau Produk belum diisi.');
      return null;
    }

    state = state.copyWith(isProcessing: true, errorMessage: null, successRefId: null);
    final refId = 'PD-${DateTime.now().millisecondsSinceEpoch}';

    try {
      await _service.createTransaction(
        buyerSkuCode: state.selectedProduct!.skuCode,
        customerNo: state.customerNumber,
        refId: refId,
        pin: pin,
      );
      state = state.copyWith(
        isProcessing: false,
        successRefId: refId,
      );
      return refId;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }
}
