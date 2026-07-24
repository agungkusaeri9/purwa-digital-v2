import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/config/dependency_injection/core_providers.dart';
import '../services/transaction_service.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TransactionService(apiClient);
});
