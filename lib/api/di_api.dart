import 'package:dispace/models/auth.dart';
import 'package:dispace/services/constants.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as Http;
import 'package:html/parser.dart' show parse;

import 'di/users.dart';

class DiApi {
  static const _personal_url = "https://dispace.edu.nstu.ru/personal";

  DiAccount? _user;
  String _session = "";

  DiAccount? get user => _user;

  Future<void> initialize() async {
    final box = Hive.box<Auth>(Constants.authBoxName);
    final auth = box.getAt(0);

    if (auth == null)
      throw "";

    _session = auth.session;
    _user = DiAccount.fromHiveBox();
  }

  Future<DiUser> getUserById(int id) async {
    final userPage = await _get("$_personal_url/index/$id");

    if (userPage.statusCode != 200) throw '';

    final document = parse(userPage.body);
    final userInput = document.getElementById("user_info");

    if (userInput == null) throw '';

    return DiUser.fromHTML(id, document);
  }

  Future<Http.Response> _get(String url, {Map<String, String>? headers}) {
    final uri = Uri.parse(url);

    final _headers = new Map<String, String>();
    if (headers != null) _headers.addAll(headers);

    _headers["cookie"] = "dispace=$_session; ${_headers["cookie"]}";

    return Http.get(uri, headers: _headers);
  }
}
