import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependency_injection/core_providers.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

final authServiceProvider =
    Provider<AuthService>((ref) => AuthService(ref.watch(apiClientProvider)));
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(
    ref.watch(authServiceProvider), ref.watch(secureStorageProvider)));
