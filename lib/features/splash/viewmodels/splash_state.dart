import 'package:purwa_digital/features/splash/enums/splash_destination.dart';

class SplashState {
  const SplashState({
    this.isLoading = true,
    this.destination,
    this.errorMessage,
  });

  final bool isLoading;
  final SplashDestination? destination;
  final String? errorMessage;

  SplashState copyWith({
    bool? isLoading,
    SplashDestination? destination,
    String? errorMessage,
  }) {
    return SplashState(
      isLoading: isLoading ?? this.isLoading,
      destination: destination ?? this.destination,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
