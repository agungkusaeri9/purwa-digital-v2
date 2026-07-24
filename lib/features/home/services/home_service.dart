import 'package:purwa_digital/core/network/api_client.dart';
import 'package:purwa_digital/features/home/models/dashboard_data_model.dart';

class HomeService {
  final ApiClient _apiClient;

  HomeService(this._apiClient);

  Future<DashboardDataModel> getDashboardData() async {
    try {
      final response = await _apiClient.dio.get('/api/dashboard');
      final responseData = response.data as Map<String, dynamic>;
      
      // Ambil field data dari Standard JSON Response builder
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      return DashboardDataModel.fromJson(data);
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await _apiClient.dio.get('/api/me');
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      return UserProfileModel.fromJson(data);
    } catch (e) {
      throw _apiClient.mapError(e);
    }
  }

}
