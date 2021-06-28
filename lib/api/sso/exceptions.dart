class SsoInvalidCredentialsException implements Exception {
  String cause;
  SsoInvalidCredentialsException(this.cause);
}

class SsoConnectionException implements Exception {
  String cause;
  SsoConnectionException(this.cause);
}

class SsoCookiesEmptyException implements Exception {

}

class SsoAuthIdEmptyException implements Exception {

}