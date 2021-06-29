import 'package:hive/hive.dart';

part 'auth.g.dart';

@HiveType(typeId: 0)
class Auth extends HiveObject {
  Auth(this.session, this.ssoToken, this.time);

  @HiveField(0)
  String session;

  @HiveField(1)
  String ssoToken;

  @HiveField(2)
  DateTime time;
}
