class InitializationState {
  final bool isInitialized;
  final bool isLoading;
  final String? error;
  final String? loadingMessage;

  const InitializationState({
    required this.isInitialized,
    required this.isLoading,
    this.error,
    this.loadingMessage,
  });

  InitializationState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? error,
    String? loadingMessage,
  }) {
    return InitializationState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      loadingMessage: loadingMessage ?? this.loadingMessage,
    );
  }
}
