import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ppob_service.dart';
import '../models/ppob_product_model.dart';
import 'pdam_form_state.dart';
import 'pulsa_form_viewmodel.dart'; // Reuse ppobServiceProvider

final pdamFormViewModelProvider =
    StateNotifierProvider.autoDispose<PdamFormViewModel, PdamFormState>((ref) {
  final service = ref.watch(ppobServiceProvider);
  return PdamFormViewModel(service);
});

class PdamFormViewModel extends StateNotifier<PdamFormState> {
  final PPOBService _service;

  PdamFormViewModel(this._service) : super(PdamFormState());

  void init({String? sku, String? name}) {
    final targetSku = (sku != null && sku.isNotEmpty) ? sku : 'post726949';
    final targetName = (name != null && name.isNotEmpty)
        ? name
        : 'PDAM Tirta Darma Kab. Purwakarta';

    state = state.copyWith(
      skuCode: targetSku,
      pdamName: targetName,
      inquiryResult: null,
    );
    fetchProduct(targetSku, targetName);
  }

  void setCustomerNumber(String number) {
    state = state.copyWith(
      customerNumber: number.trim(),
      inquiryResult: null,
    );
  }

  Future<void> fetchProduct(String sku, String name) async {
    try {
      final prod = await _service.getProductBySku(sku);
      if (prod != null) {
        state = state.copyWith(product: prod);
        return;
      }

      final list = await _service.getProducts(category: 'Pascabayar', brand: 'PDAM');
      if (list.isNotEmpty) {
        state = state.copyWith(product: list.first);
        return;
      }
    } catch (_) {}

    state = state.copyWith(
      product: PPOBProductModel(
        id: 2342,
        productName: name,
        category: 'Pascabayar',
        brand: 'PDAM',
        skuCode: sku,
        basePrice: 0,
        markupPrice: 2500,
        sellingPrice: 2500,
        description: name,
      ),
    );
  }

  Future<void> inquireBill() async {
    if (state.customerNumber.isEmpty) {
      state = state.copyWith(errorMessage: 'Nomor Pelanggan / ID PDAM belum diisi.');
      return;
    }

    state = state.copyWith(isInquiring: true, errorMessage: null, inquiryResult: null);

    try {
      final sku = (state.product != null && state.product!.skuCode.isNotEmpty)
          ? state.product!.skuCode
          : state.skuCode;
      final refId = 'INQ-PDAM-${DateTime.now().millisecondsSinceEpoch}';

      final result = await _service.inquiryPasca(
        buyerSkuCode: sku,
        customerNo: state.customerNumber,
        refId: refId,
      );

      state = state.copyWith(
        isInquiring: false,
        inquiryResult: result,
      );
    } catch (e) {
      state = state.copyWith(
        isInquiring: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<String?> submitTransaction({String? pin}) async {
    if (state.inquiryResult == null || state.customerNumber.isEmpty) {
      state = state.copyWith(errorMessage: 'Silakan lakukan Cek Tagihan terlebih dahulu.');
      return null;
    }

    state = state.copyWith(isProcessing: true, errorMessage: null, successRefId: null);
    final refId = 'PD-${DateTime.now().millisecondsSinceEpoch}';
    final sku = (state.product != null && state.product!.skuCode.isNotEmpty)
        ? state.product!.skuCode
        : state.skuCode;

    try {
      await _service.createTransaction(
        buyerSkuCode: sku,
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
