import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pulsa_form_viewmodel.dart';
import '../models/ppob_product_model.dart';
import '../services/ppob_service.dart';
import 'game_form_state.dart';

final gameFormViewModelProvider =
    StateNotifierProvider.autoDispose<GameFormViewModel, GameFormState>((ref) {
  final service = ref.watch(ppobServiceProvider);
  return GameFormViewModel(service);
});

class GameFormViewModel extends StateNotifier<GameFormState> {
  final PPOBService _service;

  GameFormViewModel(this._service) : super(GameFormState());

  void setBrand(String brand) {
    state = state.copyWith(brandName: brand);
    fetchProducts(brand);
  }

  void setUserId(String id) {
    state = state.copyWith(userId: id.trim());
  }

  void setZoneId(String zone) {
    state = state.copyWith(zoneId: zone.trim());
  }

  void selectProduct(PPOBProductModel product) {
    state = state.copyWith(selectedProduct: product);
  }

  Future<void> fetchProducts(String brand) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _service.getProducts(category: 'games', brand: brand);
      list.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
      state = state.copyWith(
        products: list,
        isLoading: false,
        selectedProduct: list.isNotEmpty ? list.first : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mengambil produk game: ${e.toString()}',
      );
    }
  }

  Future<String?> submitTransaction({String? pin}) async {
    if (state.selectedProduct == null || state.userId.isEmpty) {
      state = state.copyWith(errorMessage: 'User ID atau produk belum diisi.');
      return null;
    }

    if (state.brandName.toLowerCase().contains('mobile legend') && state.zoneId.isEmpty) {
      state = state.copyWith(errorMessage: 'Zone ID / Server ID belum diisi.');
      return null;
    }

    state = state.copyWith(isProcessing: true, errorMessage: null, successRefId: null);
    final refId = 'PD-${DateTime.now().millisecondsSinceEpoch}';

    try {
      await _service.createTransaction(
        buyerSkuCode: state.selectedProduct!.skuCode,
        customerNo: state.customerNo,
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
