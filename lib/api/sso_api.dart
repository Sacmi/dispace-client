import 'dart:convert';
import 'dart:io';

import 'package:dispace/api/sso/exceptions.dart';
import 'package:dispace/api/sso/form_response.dart';
import 'package:dispace/api/sso/token_response.dart';
import 'package:dispace/models/account.dart';
import 'package:dispace/models/auth.dart';
import 'package:dispace/services/constants.dart';
import 'package:dispace/services/cookie.dart';
import 'package:hive/hive.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

class SsoApi {
  static const _authenticate_url =
      "https://login.nstu.ru/ssoservice/json/authenticate?realm=%2Fido&goto=https%3A%2F%2Fdispace.edu.nstu.ru%2Fuser%2Fproceed%3Flogin%3Dopenam%26password%3Dauth";
  static const _login_url =
      "https://login.nstu.ru/ssoservice/json/authenticate";
  static const _linker_url =
      "https://dispace.edu.nstu.ru/user/proceed?login=openam&password=auth";
  static const _initial_url = "https://dispace.edu.nstu.ru/";

  String _authId = '';
  SsoFormResponse _ssoResponse =
      new SsoFormResponse("", List.empty(), "", "", "");

  IOClient _client = IOClient();
  List<Cookie> _cookies = List.empty(growable: true);
  String _session = "";
  String _token = "";

  String get authId => _authId;
  String get session => _session;
  String get token => _token;

  SsoApi() {
    HttpClient httpClient = new HttpClient();

    _client = IOClient(httpClient);
  }

  Future<void> initializeCookies() async {
    final uri = Uri.parse(_initial_url),
        request = await HttpClient().getUrl(uri),
        response = await request.close();

    await response.listen((event) {}).asFuture();

    if (response.statusCode != 200) {
      throw new SsoConnectionException(
          "Tried to get DiSpace cookies, but status code is ${response.statusCode}");
    }

    for (final cookie in response.cookies) {
      if (_cookies.where((element) => cookie.name == element.name).isEmpty) {
        _cookies.add(cookie);
      }
    }

    _session = CookieUtils.getCookieValue("dispace", _cookies);
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

  Future<void> login(String email, String password) async {
    if (email.isEmpty)
      throw new SsoInvalidCredentialsException("Email must be not empty");

    if (password.isEmpty)
      throw new SsoInvalidCredentialsException("Password must be not empty");

    if (!_ssoResponse.isCorrect) throw new SsoAuthIdEmptyException();

    final uri = Uri.parse(_login_url);

    _ssoResponse.setEmailValue(email);
    _ssoResponse.setPassword(password);

    final formJson = jsonEncode(_ssoResponse.toJson());
    final response = await _client.post(uri,
        body: formJson, headers: {"Content-Type": "application/json"});

    switch (response.statusCode) {
      case 401:
        throw new SsoInvalidCredentialsException("Invalid email or password");
      case 200:
        break;
      default:
        throw new SsoConnectionException(
            "Tried to receive token, but status code is ${response.statusCode}");
    }

    final json = jsonDecode(response.body);
    final tokenRes = SsoTokenResponse.fromJson(json);

    _cookies.add(new Cookie("NstuSsoToken", tokenRes.tokenId));

    _token = tokenRes.tokenId;
  }

  Future<Response> _createLinkReq(Uri uri) async {
    final res = await _client.get(uri, headers: {
      "cookie": CookieUtils.stringifyCookies(_cookies),
    });

    return res;
  }

  Future<void> authToDispace() async {
    final uri = Uri.parse(_linker_url);

    var response = await _createLinkReq(uri);

    if (response.statusCode != 200) {
      throw new SsoConnectionException(
          "Tried to receive token, but status code is ${response.statusCode}");
    }

    _setAuthInfo();
    _setUserInfo(response.body);
  }

  Future<bool> test() async {
    final uri = Uri.parse(_initial_url);

    final response = await _client.get(uri, headers: {
      "cookie": CookieUtils.stringifyCookies(_cookies),
    });

    final html = response.body;

    return html.contains("Гость");
  }

  Future<void> _setUserInfo(String html) async {
    final box = Hive.box<Account>(Constants.accountBoxName);
    await box.clear();

    final document = parse(html);
    final userInput = document.getElementById("user_info");

    if (userInput == null) throw '';

    final surname = userInput.attributes["surname"]!;
    final name = userInput.attributes["name"]!;
    final patronymic = userInput.attributes["patronymic"]!;
    final userId = int.parse(userInput.attributes["user_id"]!);

    final account = Account(userId, surname, name, patronymic);
    await box.add(account);
  }

  Future<void> _setAuthInfo() async {
    final box = Hive.box<Auth>(Constants.authBoxName);
    await box.clear();

    final auth = new Auth(session, token, DateTime.now());

    await box.add(auth);
  }
}
