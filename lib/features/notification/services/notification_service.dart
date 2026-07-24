import 'package:purwa_digital/core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<List<NotificationModel>> getNotifications({bool? isRead}) async {
    try {
      final queryParams = <String, dynamic>{'page': 1, 'limit': 50};
      if (isRead != null) {
        queryParams['is_read'] = isRead;
      }

      final response = await _apiClient.dio.get(
        '/api/notifications',
        queryParameters: queryParams,
      );

      final responseData = response.data as Map<String, dynamic>;
      
      dynamic rawItems;
      if (responseData['data'] is Map<String, dynamic>) {
        rawItems = responseData['data']['items'] ?? responseData['data']['data'] ?? [];
      } else if (responseData['data'] is List) {
        rawItems = responseData['data'];
      } else {
        rawItems = [];
      }

      return (rawItems as List)
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _apiClient.dio.put('/api/notifications/$id/read');
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.dio.put('/api/notifications/read-all');
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }
}
