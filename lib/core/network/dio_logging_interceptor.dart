import 'package:dio/dio.dart';
import '../services/app_logger.dart';

class DioLoggingInterceptor extends Interceptor {
  final Map<RequestOptions, DateTime> _requestTimestamps = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _requestTimestamps[options] = DateTime.now();

    final queryParams = options.queryParameters.isNotEmpty
        ? ' ?${options.queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';
    final fullUrl = '${options.baseUrl}${options.path}$queryParams';

    final headers = Map<String, dynamic>.from(options.headers);
    if (headers.containsKey('Authorization')) {
      headers['Authorization'] = 'Bearer [REDACTED]';
    }

    dynamic body = options.data;
    if (body is Map<String, dynamic>) {
      body = AppLogger.sanitizeData(body);
    }

    AppLogger.info(
      '🌐 HTTP REQUEST [${options.method}] $fullUrl\n'
      'Headers: $headers\n'
      'Body: ${body ?? "{}"}',
    );

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = _requestTimestamps.remove(response.requestOptions);
    final duration = startTime != null ? DateTime.now().difference(startTime).inMilliseconds : 0;

    final fullUrl = '${response.requestOptions.baseUrl}${response.requestOptions.path}';

    AppLogger.info(
      '✅ HTTP RESPONSE [${response.statusCode}] $fullUrl (${duration}ms)\n'
      'Data: ${response.data}',
    );

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = _requestTimestamps.remove(err.requestOptions);
    final duration = startTime != null ? DateTime.now().difference(startTime).inMilliseconds : 0;

    final fullUrl = '${err.requestOptions.baseUrl}${err.requestOptions.path}';

    AppLogger.error(
      '❌ HTTP ERROR [${err.response?.statusCode ?? 'NO_STATUS'}] $fullUrl (${duration}ms)\n'
      'Error: ${err.message}\n'
      'Response: ${err.response?.data}',
      err.error,
      err.stackTrace,
    );

    super.onError(err, handler);
  }
}
