import 'dart:io';

String stringifyCookies(List<Cookie> cookies) =>
    cookies.map((e) => '${e.name}=${e.value}').join('; ');