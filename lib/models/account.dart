import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 1)
class Account extends HiveObject {
  Account(this.userId, this.surname, this.name, this.patronymic);

  @HiveField(0)
  int userId;

  @HiveField(1)
  String surname;

  @HiveField(2)
  String name;

  @HiveField(3)
  String patronymic;
}
