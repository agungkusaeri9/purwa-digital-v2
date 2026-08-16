import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ppob_service.dart';
import '../models/ppob_product_model.dart';
import 'bpjs_form_state.dart';
import 'pulsa_form_viewmodel.dart'; // Reuse ppobServiceProvider

final bpjsFormViewModelProvider =
    StateNotifierProvider.autoDispose<BpjsFormViewModel, BpjsFormState>((ref) {
  final service = ref.watch(ppobServiceProvider);
  return BpjsFormViewModel(service);
});

class BpjsFormViewModel extends StateNotifier<BpjsFormState> {
  final PPOBService _service;

  BpjsFormViewModel(this._service) : super(BpjsFormState());

  void setBpjsType(String type) {
    state = state.copyWith(
      bpjsType: type,
      inquiryResult: null,
    );
    fetchProduct(type);
  }

  void setCustomerNumber(String number) {
    state = state.copyWith(
      customerNumber: number.trim(),
      inquiryResult: null,
    );
  }

  Future<void> fetchProduct(String type) async {
    final isKetenagakerjaan = type.toLowerCase().contains('ketenaga');
    final targetSku = isKetenagakerjaan ? 'post726950' : 'post694283';
    final targetBrand = isKetenagakerjaan ? 'BPJS KETENAGAKERJAAN' : 'BPJS KESEHATAN';
    final fallbackName = isKetenagakerjaan ? 'Bpjs Ketenagakerjaan Penerima Upah' : 'Bpjs Kesehatan';

    try {
      final prodBySku = await _service.getProductBySku(targetSku);
      if (prodBySku != null) {
        state = state.copyWith(product: prodBySku);
        return;
      }

      final list = await _service.getProducts(category: 'Pascabayar', brand: targetBrand);
      final validProds = list.where((p) => p.skuCode.startsWith('post')).toList();
      if (validProds.isNotEmpty) {
        state = state.copyWith(product: validProds.first);
        return;
      }
    } catch (_) {}

    state = state.copyWith(
      product: PPOBProductModel(
        id: isKetenagakerjaan ? 2343 : 1899,
        productName: fallbackName,
        category: 'Pascabayar',
        brand: targetBrand,
        skuCode: targetSku,
        basePrice: 0,
        markupPrice: 2500,
        sellingPrice: 2500,
        description: fallbackName,
      ),
    );
  }

  Future<void> inquireBill() async {
    if (state.customerNumber.isEmpty) {
      state = state.copyWith(errorMessage: 'Nomor VA / Peserta BPJS belum diisi.');
      return;
    }

    state = state.copyWith(isInquiring: true, errorMessage: null, inquiryResult: null);

    try {
      final isKetenagakerjaan = state.bpjsType.toLowerCase().contains('ketenaga');
      final targetSku = isKetenagakerjaan ? 'post726950' : 'post694283';
      final sku = (state.product != null && state.product!.skuCode.startsWith('post'))
          ? state.product!.skuCode
          : targetSku;
      final refId = 'INQ-BPJS-${DateTime.now().millisecondsSinceEpoch}';

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
    final isKetenagakerjaan = state.bpjsType.toLowerCase().contains('ketenaga');
    final targetSku = isKetenagakerjaan ? 'post726950' : 'post694283';
    final sku = (state.product != null && state.product!.skuCode.startsWith('post'))
        ? state.product!.skuCode
        : targetSku;

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
