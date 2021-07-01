class SsoInvalidCredentialsException implements Exception {
  final String cause;
  const SsoInvalidCredentialsException(this.cause);
}

class SsoConnectionException implements Exception {
  final String cause;
  const SsoConnectionException(this.cause);
}

class SsoCookiesEmptyException implements Exception {}

class SsoAuthIdEmptyException implements Exception {}
