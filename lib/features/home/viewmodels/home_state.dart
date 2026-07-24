import 'package:purwa_digital/features/home/models/dashboard_data_model.dart';

class HomeState {
  const HomeState({
    this.isLoading = false,
    this.isLoggedOut = false,
    this.errorMessage,
    this.dashboardData,
    this.profile,
  });

  final bool isLoading;
  final bool isLoggedOut;
  final String? errorMessage;
  final DashboardDataModel? dashboardData;
  final UserProfileModel? profile;

  HomeState copyWith({
    bool? isLoading,
    bool? isLoggedOut,
    String? errorMessage,
    DashboardDataModel? dashboardData,
    UserProfileModel? profile,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
      errorMessage: errorMessage,
      dashboardData: dashboardData ?? this.dashboardData,
      profile: profile ?? this.profile,
    );
  }
}
