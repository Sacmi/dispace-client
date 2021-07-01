class SsoTokenResponse {
  final String _tokenId;
  final String _successUrl;

  const SsoTokenResponse(this._tokenId, this._successUrl);

  String get tokenId => _tokenId;
  String get successUrl => _successUrl;

  factory SsoTokenResponse.fromJson(Map<String, dynamic> json) {
    final tokenId = json['tokenId'], successUrl = json['successUrl'];

    return new SsoTokenResponse(tokenId, successUrl);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tokenId'] = this._tokenId;
    data['successUrl'] = this._successUrl;
    return data;
  }
}
