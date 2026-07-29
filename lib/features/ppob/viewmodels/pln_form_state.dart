import '../models/ppob_product_model.dart';

class PlnFormState {
  final String customerNumber;
  final List<PPOBProductModel> products;
  final PPOBProductModel? selectedProduct;
  final bool isLoading;
  final bool isProcessing;
  final String? errorMessage;
  final String? successRefId;

  PlnFormState({
    this.customerNumber = '',
    this.products = const [],
    this.selectedProduct,
    this.isLoading = false,
    this.isProcessing = false,
    this.errorMessage,
    this.successRefId,
  });

  PlnFormState copyWith({
    String? customerNumber,
    List<PPOBProductModel>? products,
    PPOBProductModel? selectedProduct,
    bool? isLoading,
    bool? isProcessing,
    String? errorMessage,
    String? successRefId,
  }) {
    return PlnFormState(
      customerNumber: customerNumber ?? this.customerNumber,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      successRefId: successRefId ?? this.successRefId,
    );
  }
}
