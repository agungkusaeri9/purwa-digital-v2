class AuthToken {
  final String accessToken;

  AuthToken({required this.accessToken});

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] as String? ?? json['accessToken'] as String? ?? '',
    );
  }
}
