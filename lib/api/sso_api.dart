import 'dart:convert';
import 'dart:io';

import 'package:dispace/api/sso/exceptions.dart';
import 'package:dispace/api/sso/form_response.dart';
import 'package:dispace/api/sso/token_response.dart';
import 'package:dispace/services/utils.dart';
import 'package:http/http.dart' as Http;

enum SsoResults {
  Success,
  AuthIdMissing,
  FormNotFilled,
  InvalidCredentials
}

class SsoApi {
  static const _authenticate_url = "https://login.nstu.ru/ssoservice/json/authenticate?realm=%2Fido&goto=https%3A%2F%2Fdispace.edu.nstu.ru%2Fuser%2Fproceed%3Flogin%3Dopenam%26password%3Dauth";
  static const _login_url = "https://login.nstu.ru/ssoservice/json/authenticate";
  static const _linker_url = "https://dispace.edu.nstu.ru/user/proceed?login=openam&password=auth";
  static const _initial_url = "https://dispace.edu.nstu.ru/";
  static const _user_agent = "Mozilla/5.0 (X11; Linux x86_64; rv:89.0) Gecko/20100101 Firefox/89.0";

  String _authId = '';
  SsoFormResponse _ssoResponse = new SsoFormResponse("", List.empty(), "", "", "");

  String get authId => _authId;

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

    final response = await Http.post(uri);
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
    final response = await Http.post(uri, body: formJson, headers: {
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

  Future<bool> linkToDispace(String token, List<Cookie> cookies) async {
    final cookieList = new List<Cookie>.of(cookies, growable: true),
        ssoCookie = Cookie("NstuSsoToken", token),
        uri = Uri.parse(_linker_url);

    final client = new HttpClient();
    client.userAgent = _user_agent;

    cookieList.add(ssoCookie);

    final request = await client.getUrl(uri);
    request.cookies.addAll(cookieList);
    request.followRedirects = false;
    request.headers.add(HttpHeaders.hostHeader, "dispace.edu.nstu.ru");
    request.headers.add(HttpHeaders.acceptHeader, "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8");
    request.headers.add(HttpHeaders.acceptLanguageHeader, "ru,en-US;q=0.7,en;q=0.3");
    request.headers.add(HttpHeaders.acceptEncodingHeader, "gzip, deflate, br");
    request.headers.add(HttpHeaders.connectionHeader, "keep-alive");
    request.headers.add(HttpHeaders.refererHeader, "https://login.nstu.ru/");
    request.headers.add(HttpHeaders.cacheControlHeader, "no-cache");
    request.headers.add(HttpHeaders.pragmaHeader, "no-cache");
    request.headers.add("Upgrade-Insecure-Requests", "1");
    request.headers.add("Sec-GPC", "1");

    final test = stringifyCookies(cookieList);

    final response = await request.close();
    await response.listen((event) { }).asFuture();

    final qqq = response.headers;
    final qqqq = response.connectionInfo;

    return response.statusCode == 302;

    /*final response = await Http.get(uri, headers: {
      "User-Agent": _user_agent,
      "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*//*;q=0.8",
      "Accept-Language": "ru,en-US;q=0.7,en;q=0.3",
      "Connection": "keep-alive",
      "Referer": "",
      "Cookie": test,
    });

    final te = response.body;

    return response.statusCode == 302;*/
  }

  Future<bool> test(List<Cookie> cookies) async {
    final uri = Uri.parse(_initial_url);

    final str = stringifyCookies(cookies);

    final response = await Http.get(uri, headers: {
      "Cookie": stringifyCookies(cookies),
      "Connection": "keep-alive",
      "Cache-Control": "max-age=0",
      "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      "Host": "dispace.edu.nstu.ru",
      "User-Agent": _user_agent,
    });

    final html = response.body;

    return html.contains("Гость");
  }
}