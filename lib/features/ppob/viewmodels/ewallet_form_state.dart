import '../models/ppob_product_model.dart';

class EWalletFormState {
  final String providerName;
  final String phoneNumber;
  final List<PPOBProductModel> products;
  final PPOBProductModel? selectedProduct;
  final bool isLoading;
  final bool isProcessing;
  final String? errorMessage;
  final String? successRefId;

  EWalletFormState({
    this.providerName = '',
    this.phoneNumber = '',
    this.products = const [],
    this.selectedProduct,
    this.isLoading = false,
    this.isProcessing = false,
    this.errorMessage,
    this.successRefId,
  });

  EWalletFormState copyWith({
    String? providerName,
    String? phoneNumber,
    List<PPOBProductModel>? products,
    PPOBProductModel? selectedProduct,
    bool? isLoading,
    bool? isProcessing,
    String? errorMessage,
    String? successRefId,
  }) {
    return EWalletFormState(
      providerName: providerName ?? this.providerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      successRefId: successRefId ?? this.successRefId,
    );
  }
}
