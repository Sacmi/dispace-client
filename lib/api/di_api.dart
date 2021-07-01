import 'dart:collection';

import 'package:dispace/api/di/elements_id.dart';
import 'package:dispace/models/auth.dart';
import 'package:dispace/models/cached_html.dart';
import 'package:dispace/services/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart' as Http;
import 'package:html/parser.dart' show parse;

import 'package:dispace/api/di/users.dart';
import 'package:dispace/api/di/exceptions.dart';

import 'package:dispace/api/di/urls.dart';

import 'package:dispace/api/di/chip.dart';

class DiApi {
  static const _session_max_age = 7200;

  DiAccount get user => DiAccount.fromHiveBox();

  bool get isSessionValid {
    final box = Hive.box<Auth>(SharedConstants.authBoxName);
    final auth = box.getAt(0);

    if (auth == null) throw DiApiNotAuthenticated();

    return auth.time
            .add(Duration(seconds: _session_max_age))
            .compareTo(DateTime.now()) ==
        1;
  }

  bool get isAuthenticated {
    final box = Hive.box<Auth>(SharedConstants.authBoxName);
    final auth = box.getAt(0);

    return auth != null;
  }

  Future<Http.Response> _get(String url, {Map<String, String>? headers}) async {
    final uri = Uri.parse(url),
        authBox = Hive.box<Auth>(SharedConstants.authBoxName),
        auth = authBox.getAt(0)!;

    final _headers = new Map<String, String>();
    if (headers != null) _headers.addAll(headers);

    _headers["cookie"] = "dispace=${auth.session}; ${_headers["cookie"]}";

    auth.time = DateTime.now();
    auth.save();

    final response = await Http.get(uri, headers: _headers);
    if (response.statusCode != 200)
      throw DiApiException(
          response.statusCode, "Tried to send GET request to $url");

    return response;
  }

  Future<Document> _getCachedDocument(String url,
      {bool update = false,
      Duration cacheDuration = const Duration(minutes: 15)}) async {
    final cachedHtmlBox =
            Hive.box<CachedHtml>(SharedConstants.cachedHtmlBoxName),
        cached = cachedHtmlBox.get(url);

    if (!update && cached != null && cached.expires.isAfter(DateTime.now())) {
      return _parseHtmlComputed(cached.document);
    }

    final response = await _get(url),
        document = await _parseHtmlComputed(response.body),
        expires = DateTime.now().add(cacheDuration);

    if (cached != null) {
      cached.document = response.body;
      cached.expires = expires;
      await cached.save();
    } else {
      cachedHtmlBox.put(url, CachedHtml(url, expires, response.body));
    }

    return document;
  }

  // из-за небольшого фриза
  static Future<Document> _parseHtmlComputed(String html) {
    return compute<String, Document>(parse, html);
  }

  Future<String> _parseBadge(String url, String elementId) async {
    final document = await _getCachedDocument(DiUrls.homeUrl);

    final badgeElement = document.getElementById(elementId);
    if (badgeElement == null) throw '';

    return badgeElement.text;
  }

  Future<int> getMessageCount() async {
    return int.parse(
        await _parseBadge(DiUrls.homeUrl, DiElementsId.testsCounterId));
  }

  Future<int> getTestCount() async {
    return int.parse(
        await _parseBadge(DiUrls.homeUrl, DiElementsId.messageCounterId));
  }

  Future<int> getDisciplinesCount() async {
    return int.parse(
        await _parseBadge(DiUrls.homeUrl, DiElementsId.disciplinesCounterId));
  }

  Future<int> getCalendarCount() async {
    return int.parse(
        await _parseBadge(DiUrls.homeUrl, DiElementsId.disciplinesCounterId));
  }

  Future<DiUser> getUserById(int id, {bool update = false}) async {
    final document = await _getCachedDocument("${DiUrls.personalUrl}/index/$id",
        update: update);
    final userInput = document.getElementById("user_info");

    if (userInput == null) throw '';

    return DiUser.fromHTML(id, document);
  }

  Future<UnmodifiableListView<DiChip>> getSemesterList(
      {bool update = false}) async {
    final document = await _getCachedDocument(DiUrls.disciplineUrl,
        cacheDuration: Duration(days: 1), update: update);
    final elements = document.getElementsByClassName("chip");

    List<DiChip> semesters = [];

    for (Element element in elements) {
      if (element.text.contains("семестр")) {
        final url = "",
            label = element.text,
            selected = element.classes.contains("selected");

        semesters.add(DiChip(url, label, selected));
      }
    }

    return UnmodifiableListView(semesters);
  }
}
