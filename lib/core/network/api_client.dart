import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../config/environment/app_environment.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage_service.dart';

import 'dio_logging_interceptor.dart';

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

    dio.interceptors.add(DioLoggingInterceptor());
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
      if (data is Map<String, dynamic>) {
        final errors = data['errors'];
        if (errors != null && errors.toString().isNotEmpty && errors.toString() != 'null') {
          return AppException(errors.toString(), statusCode: error.response?.statusCode);
        }
        final message = data['message'] as String?;
        if (message != null && message.isNotEmpty) {
          return AppException(message, statusCode: error.response?.statusCode);
        }
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return const AppException(
          'Koneksi waktu habis (Timeout). Silakan periksa koneksi internet Anda.',
        );
      }

      if (error.type == DioExceptionType.connectionError ||
          (error.message != null &&
              (error.message!.contains('Connection refused') ||
                  error.message!.contains('SocketException')))) {
        return AppException(
          'Gagal terhubung ke server (Connection Refused). Pastikan koneksi internet aktif dan server backend beroperasi.',
          statusCode: error.response?.statusCode,
        );
      }

      return AppException(
        error.message ?? 'Terjadi kesalahan koneksi jaringan.',
        statusCode: error.response?.statusCode,
      );
    }
    if (error is AppException) {
      return error;
    }
    return const AppException('Terjadi kesalahan yang tidak terduga.');
  }
}
