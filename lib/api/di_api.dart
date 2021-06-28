import 'package:http/http.dart' as Http;
import 'package:html/parser.dart' show parse;

import 'di/users.dart';

class DiApi {
  static const _home_url = "https://dispace.edu.nstu.ru/";
  static const _personal_url = "https://dispace.edu.nstu.ru/personal/index";

  DiAccount? _user;
  final _session;

  DiAccount? get user => _user;

  DiApi(this._session);

  Future<void> initialize() async {
    final mainPage = await _get(_home_url);

    if (mainPage.statusCode != 200)
      throw '';

    final document = parse(mainPage.body);
    final userInput = document.getElementById("user_info");

    if (userInput == null)
      throw '';

    final surname = userInput.attributes["surname"]!;
    final name = userInput.attributes["name"]!;
    final patronymic = userInput.attributes["patronymic"]!;
    final userId = int.parse(userInput.attributes["user_id"]!);

    _user = new DiAccount(surname, name, patronymic, userId);
  }

  Future<DiUser> getUserById(int id) async {
    final userPage = await _get("$_personal_url/$id");

    if (userPage.statusCode != 200)
      throw '';

    final document = parse(userPage.body);
    final userInput = document.getElementById("user_info");

    if (userInput == null)
      throw '';

    return DiUser.fromHTML(id, document);
  }

  Future<Http.Response> _get(String url, {Map<String, String>? headers}) {
    final uri = Uri.parse(url);

    final _headers = new Map<String, String>();
    if (headers != null)
      _headers.addAll(headers);

    _headers["cookie"] = "dispace=$_session; ${_headers["cookie"]}";
    //_headers["user-agent"] = _user_agent;

    return Http.get(uri, headers: _headers);
  }
}