import 'package:purwa_digital/core/network/api_client.dart';
import '../models/cash_model.dart';

class CashService {
  final ApiClient _apiClient;

  CashService(this._apiClient);

  Future<CashSummaryModel> getSummary() async {
    try {
      final response = await _apiClient.dio.get('/api/cash-transactions/summary');
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      return CashSummaryModel.fromJson(data);
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<List<CashTransactionItem>> getTransactions({String? type, String? search}) async {
    try {
      final queryParams = <String, dynamic>{'page': 1, 'limit': 30};
      if (type != null && type.isNotEmpty && type != 'all') {
        queryParams['type'] = type;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.dio.get(
        '/api/cash-transactions',
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
          .map((item) => CashTransactionItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<void> createTransaction({
    required double amount,
    required String type,
    required String description,
  }) async {
    try {
      await _apiClient.dio.post(
        '/api/cash-transactions',
        data: {
          'amount': amount,
          'type': type,
          'status': 'success',
          'description': description,
        },
      );
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }
}
