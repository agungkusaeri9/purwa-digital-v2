import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ppob_service.dart';
import 'pln_pasca_form_state.dart';
import 'pulsa_form_viewmodel.dart';

final plnPascaFormViewModelProvider =
    StateNotifierProvider.autoDispose<PlnPascaFormViewModel, PlnPascaFormState>((ref) {
  final service = ref.watch(ppobServiceProvider);
  return PlnPascaFormViewModel(service);
});

class PlnPascaFormViewModel extends StateNotifier<PlnPascaFormState> {
  final PPOBService _service;

  PlnPascaFormViewModel(this._service) : super(PlnPascaFormState()) {
    fetchProduct();
  }

  void setCustomerNumber(String number) {
    final clean = number.replaceAll(RegExp(r'\D'), '');
    state = state.copyWith(
      customerNumber: clean,
      clearInquiry: true,
    );
  }

  Future<void> fetchProduct() async {
    state = state.copyWith(isLoadingProduct: true, errorMessage: null);
    try {
      // First try fetching products with type=pasca
      var list = await _service.getProducts(type: 'pasca');
      var plnPasca = list.where((p) =>
        p.productName.toLowerCase().contains('pln') ||
        p.brand.toLowerCase().contains('pln')
      ).toList();

      if (plnPasca.isEmpty) {
        // Fallback: fetch all products and look for PLN pasca
        var allList = await _service.getProducts();
        plnPasca = allList.where((p) =>
          p.productName.toLowerCase().contains('pln') &&
          (p.productName.toLowerCase().contains('pasca') || p.brand.toLowerCase().contains('pasca'))
        ).toList();
      }

      state = state.copyWith(
        isLoadingProduct: false,
        product: plnPasca.isNotEmpty ? plnPasca.first : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingProduct: false,
        errorMessage: 'Gagal mengambil data produk PLN Pascabayar: ${e.toString()}',
      );
    }
  }

  Future<void> performInquiry() async {
    if (state.product == null) {
      state = state.copyWith(errorMessage: 'Produk PLN Pascabayar tidak ditemukan.');
      return;
    }
    if (state.customerNumber.isEmpty) {
      state = state.copyWith(errorMessage: 'Nomor Pelanggan wajib diisi.');
      return;
    }

    state = state.copyWith(isInquiring: true, errorMessage: null, clearInquiry: true);
    try {
      final res = await _service.inquiryPasca(
        buyerSkuCode: state.product!.skuCode,
        customerNo: state.customerNumber,
      );
      state = state.copyWith(
        isInquiring: false,
        inquiryResult: res,
      );
    } catch (e) {
      state = state.copyWith(
        isInquiring: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<String?> submitTransaction({String? pin}) async {
    if (state.product == null || state.customerNumber.isEmpty || state.inquiryResult == null) {
      state = state.copyWith(errorMessage: 'Inquiry tagihan belum dilakukan.');
      return null;
    }

    state = state.copyWith(isProcessing: true, errorMessage: null, successRefId: null);
    final refId = 'PASCA-${DateTime.now().millisecondsSinceEpoch}';

    try {
      await _service.createTransaction(
        buyerSkuCode: state.product!.skuCode,
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
