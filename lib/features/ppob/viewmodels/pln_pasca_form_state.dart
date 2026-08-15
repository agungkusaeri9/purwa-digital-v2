import '../models/ppob_product_model.dart';

class PlnPascaFormState {
  final String customerNumber;
  final bool isLoadingProduct;
  final bool isInquiring;
  final bool isProcessing;
  final PPOBProductModel? product;
  final Map<String, dynamic>? inquiryResult;
  final String? errorMessage;
  final String? successRefId;

  PlnPascaFormState({
    this.customerNumber = '',
    this.isLoadingProduct = false,
    this.isInquiring = false,
    this.isProcessing = false,
    this.product,
    this.inquiryResult,
    this.errorMessage,
    this.successRefId,
  });

  PlnPascaFormState copyWith({
    String? customerNumber,
    bool? isLoadingProduct,
    bool? isInquiring,
    bool? isProcessing,
    PPOBProductModel? product,
    Map<String, dynamic>? inquiryResult,
    bool clearInquiry = false,
    String? errorMessage,
    String? successRefId,
  }) {
    return PlnPascaFormState(
      customerNumber: customerNumber ?? this.customerNumber,
      isLoadingProduct: isLoadingProduct ?? this.isLoadingProduct,
      isInquiring: isInquiring ?? this.isInquiring,
      isProcessing: isProcessing ?? this.isProcessing,
      product: product ?? this.product,
      inquiryResult: clearInquiry ? null : (inquiryResult ?? this.inquiryResult),
      errorMessage: errorMessage,
      successRefId: successRefId ?? this.successRefId,
    );
  }
}
