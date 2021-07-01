import 'package:dispace/models/account.dart';
import 'package:dispace/models/auth.dart';
import 'package:dispace/models/cached_html.dart';
import 'package:dispace/models/credentials.dart';
import 'package:dispace/services/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> initializeHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AuthAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(CredentialsAdapter());
  Hive.registerAdapter(CachedHtmlAdapter());

  await Hive.openBox<Auth>(SharedConstants.authBoxName);
  await Hive.openBox<Account>(SharedConstants.accountBoxName);
  await Hive.openBox<Credentials>(SharedConstants.credentialsBoxName);
  await Hive.openBox<CachedHtml>(SharedConstants.cachedHtmlBoxName);
}
