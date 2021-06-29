import 'dart:io';

class CookieUtils {
  static String stringifyCookies(List<Cookie> cookies) =>
      cookies.map((e) => '${e.name}=${e.value}').join('; ');

  static String getCookieValue(String name, List<Cookie> cookies) =>
      cookies.singleWhere((element) => element.name == name).value;
}
