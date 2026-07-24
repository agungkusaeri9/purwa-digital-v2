import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/config/dependency_injection/core_providers.dart';
import '../services/home_service.dart';

final homeServiceProvider = Provider<HomeService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeService(apiClient);
});
