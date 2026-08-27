class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class AuthExceptionCustom implements Exception {
  final String message;
  const AuthExceptionCustom(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}