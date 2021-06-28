import 'dart:convert';
import 'dart:io';

import 'package:dispace/api/sso/exceptions.dart';
import 'package:dispace/api/sso/form_response.dart';
import 'package:dispace/api/sso/token_response.dart';
import 'package:dispace/services/utils.dart';
import 'package:http/io_client.dart';

class SsoApi {
  static const _authenticate_url = "https://login.nstu.ru/ssoservice/json/authenticate?realm=%2Fido&goto=https%3A%2F%2Fdispace.edu.nstu.ru%2Fuser%2Fproceed%3Flogin%3Dopenam%26password%3Dauth";
  static const _login_url = "https://login.nstu.ru/ssoservice/json/authenticate";
  static const _linker_url = "https://dispace.edu.nstu.ru/user/proceed?login=openam&password=auth";
  static const _initial_url = "https://dispace.edu.nstu.ru/";
  static const _user_agent = "Dart/2.13 (dart:io)";

  String _authId = '';
  SsoFormResponse _ssoResponse = new SsoFormResponse("", List.empty(), "", "", "");

  IOClient _client = IOClient();

  String get authId => _authId;

  SsoApi() {
    // String proxy = Platform.isAndroid ? '192.168.1.4:8866' : 'localhost:8866';
    HttpClient httpClient = new HttpClient();
    // httpClient.findProxy = (uri) {
    //   return "PROXY $proxy;";
    // };
    httpClient.userAgent = _user_agent;

    // httpClient.badCertificateCallback =
    // ((X509Certificate cert, String host, int port) => Platform.isAndroid);
    _client = IOClient(httpClient);
  }

  Future<List<Cookie>> initializeCookies() async {
    final uri = Uri.parse(_initial_url),
        request = await HttpClient().getUrl(uri),
        response = await request.close(),
        cookieList = List<Cookie>.empty(growable: true);

    await response.listen((event) { }).asFuture();

    if (response.statusCode != 200) {
      throw new SsoConnectionException("Tried to get DiSpace cookies, but status code is ${response.statusCode}");
    }

    for (final cookie in response.cookies) {
      if (cookieList.where((element) => cookie.name == element.name).isEmpty) {
        cookieList.add(cookie);
      }
    }

    return List.of(cookieList, growable: false);
  }

  Future<bool> getAuthId() async {
    final uri = Uri.parse(_authenticate_url);

    final response = await _client.post(uri);
    if (response.statusCode != 200) {
      return false;
    }

    final json = jsonDecode(response.body);
    try {
      _ssoResponse = SsoFormResponse.fromJson(json);
    } catch (Exception) {
      return false;
    }

    return true;
  }

  Future<String> getToken(String email, String password) async {
    if (!_ssoResponse.isCorrect)
      throw new SsoAuthIdEmptyException();

    final uri = Uri.parse(_login_url);

    _ssoResponse.setEmailValue(email);
    _ssoResponse.setPassword(password);

    final formJson = jsonEncode(_ssoResponse.toJson());
    final response = await _client.post(uri, body: formJson, headers: {
      "Content-Type": "application/json"
    });

    switch (response.statusCode) {
      case 401:
        throw new SsoInvalidCredentialsException("Invalid email or password");
      case 200:
        break;
      default:
        throw new SsoConnectionException("Tried to receive token, but status code is ${response.statusCode}");
    }

    final json = jsonDecode(response.body);
    final tokenRes = SsoTokenResponse.fromJson(json);

    return tokenRes.tokenId;
  }

  Future<int> _createLinkReq(Uri uri, List<Cookie> cookies) async {
    final cookieStr = stringifyCookies(cookies);

    final res = await _client.get(uri, headers: {
      "Cookie": cookieStr,
    });

    return res.statusCode;
  }

  Future<bool> linkToDispace(String token, List<Cookie> cookies) async {
    final cookieList = new List<Cookie>.of(cookies, growable: true),
        ssoCookie = Cookie("NstuSsoToken", token),
        uri = Uri.parse(_linker_url);

    cookieList.add(ssoCookie);

    var resAuth = await _createLinkReq(uri, cookieList);

    return resAuth == 200;
  }

  Future<bool> test(List<Cookie> cookies) async {
    final uri = Uri.parse(_initial_url);

    final response = await _client.get(uri, headers: {
      "Cookie": stringifyCookies(cookies),
      "Connection": "keep-alive",
      "Cache-Control": "max-age=0",
      "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      "Host": "dispace.edu.nstu.ru",
    });

    final html = response.body;

    return html.contains("Гость");
  }
}