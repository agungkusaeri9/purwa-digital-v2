import 'package:purwa_digital/core/network/api_client.dart';
import '../models/ppob_product_model.dart';
import '../models/ppob_brand_model.dart';
import '../models/ppob_category_model.dart';
import '../../transaction/models/ppob_transaction_model.dart';

class PPOBService {
  final ApiClient _apiClient;

  PPOBService(this._apiClient);

  Future<List<PPOBCategoryModel>> getCategoriesList() async {
    try {
      final response = await _apiClient.dio.get('/api/categories');
      final responseData = response.data as Map<String, dynamic>;
      final dynamic bodyData = responseData['data'];
      final List<dynamic> list;
      if (bodyData is List) {
        list = bodyData;
      } else {
        list = [];
      }

      return list.map((e) => PPOBCategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<List<PPOBBrandModel>> getBrands({
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;

      final response = await _apiClient.dio.get(
        '/api/products/brands',
        queryParameters: queryParams,
      );

      final responseData = response.data as Map<String, dynamic>;
      final dynamic bodyData = responseData['data'];
      final List<dynamic> list;
      if (bodyData is List) {
        list = bodyData;
      } else {
        list = [];
      }

      return list.map((e) => PPOBBrandModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<List<PPOBProductModel>> getProducts({
    String? category,
    String? brand,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': 100,
        'is_active': true,
      };
      if (category != null) queryParams['category'] = category;
      if (brand != null) queryParams['brand'] = brand;

      final response = await _apiClient.dio.get(
        '/api/products',
        queryParameters: queryParams,
      );

      final responseData = response.data as Map<String, dynamic>;
      final dynamic bodyData = responseData['data'];
      final List<dynamic> list;
      if (bodyData is Map && bodyData.containsKey('data')) {
        list = bodyData['data'] as List;
      } else if (bodyData is List) {
        list = bodyData;
      } else {
        list = [];
      }

      return list.map((e) => PPOBProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<Map<String, dynamic>> createTransaction({
    required String buyerSkuCode,
    required String customerNo,
    required String refId,
    String? pin,
  }) async {
    try {
      final body = <String, dynamic>{
        'buyer_sku_code': buyerSkuCode,
        'customer_no': customerNo,
        'ref_id': refId,
      };
      if (pin != null && pin.isNotEmpty) {
        body['pin'] = pin;
      }
      final response = await _apiClient.dio.post(
        '/api/digiflazz/transaction',
        data: body,
      );
      final responseData = response.data as Map<String, dynamic>;
      return responseData['data'] as Map<String, dynamic>? ?? responseData;
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<bool> verifyPin(String pin) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/me/pin/verify',
        data: {'pin': pin},
      );
      final responseData = response.data as Map<String, dynamic>;
      return responseData['status'] == true;
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }


  Future<PPOBTransactionModel> getTransactionByRef(String refId) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/ppob/transactions/ref/$refId',
      );
      final responseData = response.data as Map<String, dynamic>;
      return PPOBTransactionModel.fromJson(responseData['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }
}
