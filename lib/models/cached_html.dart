import 'package:hive/hive.dart';

part 'cached_html.g.dart';

@HiveType(typeId: 3)
class CachedHtml extends HiveObject {
  CachedHtml(this.url, this.expires, this.document);

  @HiveField(0)
  String url;

  @HiveField(1)
  DateTime expires;

  @HiveField(2)
  String document;
}
