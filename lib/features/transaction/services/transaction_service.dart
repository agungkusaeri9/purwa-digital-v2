import 'package:purwa_digital/core/network/api_client.dart';
import '../models/ppob_transaction_model.dart';

class TransactionService {
  final ApiClient _apiClient;

  TransactionService(this._apiClient);

  Future<List<PPOBTransactionModel>> getTransactions(TransactionFilterModel filter) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/ppob/transactions',
        queryParameters: filter.toQueryParams(),
      );

      final responseData = response.data as Map<String, dynamic>;
      
      // Standar pagination response: response.data.data.items atau response.data.data
      dynamic rawItems;
      if (responseData['data'] is Map<String, dynamic>) {
        rawItems = responseData['data']['items'] ?? responseData['data']['data'] ?? [];
      } else if (responseData['data'] is List) {
        rawItems = responseData['data'];
      } else {
        rawItems = [];
      }

      final items = (rawItems as List)
          .map((item) => PPOBTransactionModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return items;
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.dio.get('/api/categories');
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as List? ?? [];
      
      return data.map((e) {
        if (e is Map<String, dynamic>) {
          return (e['name'] ?? e['category_name'] ?? e['title'] ?? '').toString();
        }
        return e.toString();
      }).where((name) => name.isNotEmpty).toList();
    } catch (_) {
      // Return fallback categories jika error
      return ['Pulsa', 'Data', 'E-Money', 'Games', 'PLN'];
    }
  }

}
