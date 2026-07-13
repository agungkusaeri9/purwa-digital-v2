import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/preferences_service.dart';
import '../../core/storage/secure_storage_service.dart';

final secureStorageProvider =
    Provider<SecureStorageService>((ref) => SecureStorageService());
final preferencesProvider =
    Provider<PreferencesService>((ref) => PreferencesService());
final apiClientProvider =
    Provider<ApiClient>((ref) => ApiClient(ref.watch(secureStorageProvider)));
