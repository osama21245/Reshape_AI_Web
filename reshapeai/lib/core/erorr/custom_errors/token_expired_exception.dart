class TokenExpiredException implements Exception {
  final String message;
  TokenExpiredException({this.message = "TokenExpired"});

  @override
  String toString() => message;
}
