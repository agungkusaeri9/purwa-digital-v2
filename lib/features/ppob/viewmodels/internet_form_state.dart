import '../models/ppob_product_model.dart';

class InternetFormState {
  final String skuCode;
  final String providerName;
  final String customerNumber;
  final bool isInquiring;
  final bool isProcessing;
  final Map<String, dynamic>? inquiryResult;
  final PPOBProductModel? product;
  final String? errorMessage;
  final String? successRefId;

  InternetFormState({
    this.skuCode = 'post726952',
    this.providerName = 'SPEEDY & INDIHOME',
    this.customerNumber = '',
    this.isInquiring = false,
    this.isProcessing = false,
    this.inquiryResult,
    this.product,
    this.errorMessage,
    this.successRefId,
  });

  InternetFormState copyWith({
    String? skuCode,
    String? providerName,
    String? customerNumber,
    bool? isInquiring,
    bool? isProcessing,
    Map<String, dynamic>? inquiryResult,
    PPOBProductModel? product,
    String? errorMessage,
    String? successRefId,
  }) {
    return InternetFormState(
      skuCode: skuCode ?? this.skuCode,
      providerName: providerName ?? this.providerName,
      customerNumber: customerNumber ?? this.customerNumber,
      isInquiring: isInquiring ?? this.isInquiring,
      isProcessing: isProcessing ?? this.isProcessing,
      inquiryResult: inquiryResult ?? this.inquiryResult,
      product: product ?? this.product,
      errorMessage: errorMessage,
      successRefId: successRefId ?? this.successRefId,
    );
  }
}
