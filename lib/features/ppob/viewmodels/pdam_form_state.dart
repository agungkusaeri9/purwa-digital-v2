import '../models/ppob_product_model.dart';

class PdamFormState {
  final String skuCode;
  final String pdamName;
  final String customerNumber;
  final bool isInquiring;
  final bool isProcessing;
  final Map<String, dynamic>? inquiryResult;
  final PPOBProductModel? product;
  final String? errorMessage;
  final String? successRefId;

  PdamFormState({
    this.skuCode = 'post726949',
    this.pdamName = 'PDAM Tirta Darma Kab. Purwakarta',
    this.customerNumber = '',
    this.isInquiring = false,
    this.isProcessing = false,
    this.inquiryResult,
    this.product,
    this.errorMessage,
    this.successRefId,
  });

  PdamFormState copyWith({
    String? skuCode,
    String? pdamName,
    String? customerNumber,
    bool? isInquiring,
    bool? isProcessing,
    Map<String, dynamic>? inquiryResult,
    PPOBProductModel? product,
    String? errorMessage,
    String? successRefId,
  }) {
    return PdamFormState(
      skuCode: skuCode ?? this.skuCode,
      pdamName: pdamName ?? this.pdamName,
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
