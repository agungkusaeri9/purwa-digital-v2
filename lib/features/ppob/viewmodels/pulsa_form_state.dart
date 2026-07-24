import '../models/ppob_product_model.dart';

class PulsaFormState {
  final String phoneNumber;
  final String providerName;
  final List<PPOBProductModel> products;
  final PPOBProductModel? selectedProduct;
  final bool isLoading;
  final bool isProcessing;
  final String? errorMessage;
  final String? successRefId;

  PulsaFormState({
    this.phoneNumber = '',
    this.providerName = '',
    this.products = const [],
    this.selectedProduct,
    this.isLoading = false,
    this.isProcessing = false,
    this.errorMessage,
    this.successRefId,
  });

  PulsaFormState copyWith({
    String? phoneNumber,
    String? providerName,
    List<PPOBProductModel>? products,
    PPOBProductModel? selectedProduct,
    bool? isLoading,
    bool? isProcessing,
    String? errorMessage,
    String? successRefId,
  }) {
    return PulsaFormState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      providerName: providerName ?? this.providerName,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      successRefId: successRefId ?? this.successRefId,
    );
  }
}
