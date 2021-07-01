import 'package:hive/hive.dart';

part 'credentials.g.dart';

@HiveType(typeId: 2)
class Credentials extends HiveObject {
  Credentials(this.email, this.password, this.label);

  @HiveField(0)
  String email;

  @HiveField(1)
  String password;

  @HiveField(2)
  String label;
}
