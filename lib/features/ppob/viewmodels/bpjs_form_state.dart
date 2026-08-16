import '../models/ppob_product_model.dart';

class BpjsFormState {
  final String bpjsType; // 'kesehatan' or 'ketenagakerjaan'
  final String customerNumber;
  final bool isInquiring;
  final bool isProcessing;
  final Map<String, dynamic>? inquiryResult;
  final PPOBProductModel? product;
  final String? errorMessage;
  final String? successRefId;

  BpjsFormState({
    this.bpjsType = 'kesehatan',
    this.customerNumber = '',
    this.isInquiring = false,
    this.isProcessing = false,
    this.inquiryResult,
    this.product,
    this.errorMessage,
    this.successRefId,
  });

  BpjsFormState copyWith({
    String? bpjsType,
    String? customerNumber,
    bool? isInquiring,
    bool? isProcessing,
    Map<String, dynamic>? inquiryResult,
    PPOBProductModel? product,
    String? errorMessage,
    String? successRefId,
  }) {
    return BpjsFormState(
      bpjsType: bpjsType ?? this.bpjsType,
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
