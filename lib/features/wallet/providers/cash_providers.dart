import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/config/dependency_injection/core_providers.dart';
import '../services/cash_service.dart';

final cashServiceProvider = Provider<CashService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CashService(apiClient);
});
