import 'package:dispace/models/account.dart';
import 'package:dispace/models/auth.dart';
import 'package:dispace/models/credentials.dart';
import 'package:dispace/services/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> initializeHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AuthAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(CredentialsAdapter());

  await Hive.openBox<Auth>(Constants.authBoxName);
  await Hive.openBox<Account>(Constants.accountBoxName);
  await Hive.openBox<Credentials>(Constants.credentialsBoxName);
}
