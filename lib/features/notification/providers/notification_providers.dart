import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/config/dependency_injection/core_providers.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationService(apiClient);
});
