class HomeState {
  const HomeState({
    this.isLoading = false,
    this.isLoggedOut = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isLoggedOut;
  final String? errorMessage;

  HomeState copyWith({
    bool? isLoading,
    bool? isLoggedOut,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
      errorMessage: errorMessage,
    );
  }
}
