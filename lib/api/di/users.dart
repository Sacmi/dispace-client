import 'package:dispace/models/account.dart';
import 'package:dispace/services/constants.dart';
import 'package:hive/hive.dart';
import 'package:html/dom.dart';

class DiUser {
  final String surname;
  final String name;
  final String patronymic;
  final int userId;
  final String photoUrl;
  final String city;
  final String country;
  final String cipher;
  final String group;

  const DiUser(this.surname, this.name, this.patronymic, this.userId,
      this.photoUrl, this.city, this.country, this.cipher, this.group);

  factory DiUser.fromHTML(int userId, Document document) {
    final fullName =
        document.getElementsByClassName("subtitle")[0].attributes["title"]!;
    final fullNameSplit = fullName.split(" ");

    final surname = fullNameSplit[0];
    final name = fullNameSplit[1];
    final patronymic = fullNameSplit[2];

    String city = "", country = "", cipher = "", group = "";

    final cells = document.getElementsByClassName("person-cell");
    for (final cell in cells) {
      final label = cell.children[0].text.trim().replaceFirst(":", "");
      final value = cell.children[1].text.trim();

      switch (label) {
        case "Город":
          city = value;
          break;
        case "Страна":
          country = value;
          break;
        case "Шифр студента":
          cipher = value;
          break;
        case "Группа студента":
          group = value;
          break;
      }
    }

    // TODO: сделать загрузку фотографии
    String photoUrl = "";

    return new DiUser(surname, name, patronymic, userId, photoUrl, city,
        country, cipher, group);
  }
}

class DiAccount {
  final String surname;
  final String name;
  final String patronymic;
  final int userId;

  const DiAccount(this.surname, this.name, this.patronymic, this.userId);

  factory DiAccount.fromHiveBox() {
    final box = Hive.box<Account>(SharedConstants.accountBoxName);
    final account = box.getAt(0);

    if (account == null) throw "";

    return new DiAccount(
        account.surname, account.name, account.patronymic, account.userId);
  }
}
