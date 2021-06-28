import 'package:hive_flutter/hive_flutter.dart';

Future<void> initializeHive() async {
  await Hive.initFlutter();

  final box = await Hive.openBox('api');
  box.put("session", "");
  box.put("sso_token", "");
}