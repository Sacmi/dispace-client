class DiApiException implements Exception {
  final String message;
  final int statusCode;

  const DiApiException(this.statusCode, this.message);
}

class DiApiNotAuthenticated implements Exception {

}

class DiApiSessionException implements Exception {

}