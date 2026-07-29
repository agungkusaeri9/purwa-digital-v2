import '../models/ppob_product_model.dart';

class GameFormState {
  final String userId;
  final String zoneId;
  final String brandName;
  final List<PPOBProductModel> products;
  final PPOBProductModel? selectedProduct;
  final bool isLoading;
  final bool isProcessing;
  final String? errorMessage;
  final String? successRefId;

  GameFormState({
    this.userId = '',
    this.zoneId = '',
    this.brandName = '',
    this.products = const [],
    this.selectedProduct,
    this.isLoading = false,
    this.isProcessing = false,
    this.errorMessage,
    this.successRefId,
  });

  String get customerNo {
    if (brandName.toLowerCase().contains('mobile legend')) {
      if (zoneId.isEmpty) return userId;
      return '$userId($zoneId)';
    }
    return userId;
  }

  GameFormState copyWith({
    String? userId,
    String? zoneId,
    String? brandName,
    List<PPOBProductModel>? products,
    PPOBProductModel? selectedProduct,
    bool? isLoading,
    bool? isProcessing,
    String? errorMessage,
    String? successRefId,
  }) {
    return GameFormState(
      userId: userId ?? this.userId,
      zoneId: zoneId ?? this.zoneId,
      brandName: brandName ?? this.brandName,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      successRefId: successRefId ?? this.successRefId,
    );
  }
}
