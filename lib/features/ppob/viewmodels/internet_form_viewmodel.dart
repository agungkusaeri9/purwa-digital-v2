import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ppob_service.dart';
import '../models/ppob_product_model.dart';
import 'internet_form_state.dart';
import 'pulsa_form_viewmodel.dart'; // Reuse ppobServiceProvider

final internetFormViewModelProvider =
    StateNotifierProvider.autoDispose<InternetFormViewModel, InternetFormState>((ref) {
  final service = ref.watch(ppobServiceProvider);
  return InternetFormViewModel(service);
});

class InternetFormViewModel extends StateNotifier<InternetFormState> {
  final PPOBService _service;

  InternetFormViewModel(this._service) : super(InternetFormState());

  void init({String? sku, String? name}) {
    final targetSku = (sku != null && sku.isNotEmpty) ? sku : 'post726952';
    final targetName = (name != null && name.isNotEmpty) ? name : 'SPEEDY & INDIHOME';

    state = state.copyWith(
      skuCode: targetSku,
      providerName: targetName,
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

      final list = await _service.getProducts(category: 'Pascabayar', brand: 'INTERNET PASCABAYAR');
      if (list.isNotEmpty) {
        state = state.copyWith(product: list.first);
        return;
      }
    } catch (_) {}

    state = state.copyWith(
      product: PPOBProductModel(
        id: 2498,
        productName: name,
        category: 'Pascabayar',
        brand: 'INTERNET PASCABAYAR',
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
      state = state.copyWith(errorMessage: 'Nomor Pelanggan / ID Internet belum diisi.');
      return;
    }

    state = state.copyWith(isInquiring: true, errorMessage: null, inquiryResult: null);

    try {
      final sku = (state.product != null && state.product!.skuCode.isNotEmpty)
          ? state.product!.skuCode
          : state.skuCode;
      final refId = 'INQ-INET-${DateTime.now().millisecondsSinceEpoch}';

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
