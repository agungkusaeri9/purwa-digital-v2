import 'package:dio/dio.dart';

import '../../config/environment/app_environment.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  ApiClient(this._secureStorage)
      : dio = Dio(
          BaseOptions(
            baseUrl: AppEnvironment.apiBaseUrl,
            connectTimeout: AppConstants.connectTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
            headers: const {'Content-Type': 'application/json'},
          ),
        ) {
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      final token = await _secureStorage.readToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    }));
  }

  final SecureStorageService _secureStorage;
  final Dio dio;

  AppException mapError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      final message = data is Map<String, dynamic>
          ? data['message'] as String? ?? 'Terjadi kesalahan jaringan.'
          : 'Terjadi kesalahan jaringan.';
      return AppException(message, statusCode: error.response?.statusCode);
    }
    return const AppException('Terjadi kesalahan yang tidak terduga.');
  }
}
