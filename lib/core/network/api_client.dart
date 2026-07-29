import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

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
    if (dio.httpClientAdapter is IOHttpClientAdapter) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.readToken();
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await _secureStorage.readRefreshToken();
          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              final refreshDio = Dio(
                BaseOptions(
                  baseUrl: AppEnvironment.apiBaseUrl,
                  connectTimeout: AppConstants.connectTimeout,
                  receiveTimeout: AppConstants.receiveTimeout,
                  headers: const {'Content-Type': 'application/json'},
                ),
              );

              final response = await refreshDio.post(
                '/auth/refresh',
                data: {'refresh_token': refreshToken},
              );

              if (response.statusCode == 200) {
                final responseData = response.data;
                if (responseData is Map<String, dynamic> && responseData['success'] == true) {
                  final dataMap = responseData['data'] as Map<String, dynamic>;
                  final newAccessToken = dataMap['access_token'] as String;
                  final newRefreshToken = dataMap['refresh_token'] as String;

                  await _secureStorage.saveToken(newAccessToken);
                  await _secureStorage.saveRefreshToken(newRefreshToken);

                  error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

                  final options = Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  );

                  final clonedRequest = await dio.request<dynamic>(
                    error.requestOptions.path,
                    options: options,
                    data: error.requestOptions.data,
                    queryParameters: error.requestOptions.queryParameters,
                  );

                  return handler.resolve(clonedRequest);
                }
              }
            } catch (_) {
              await _secureStorage.clearToken();
              await _secureStorage.clearRefreshToken();
            }
          }
        }
        handler.next(error);
      },
    ));
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
