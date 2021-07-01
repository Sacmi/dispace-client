import 'package:dispace/api/di/chip.dart';
import 'package:dispace/api/di/users.dart';
import 'package:dispace/api/di_api.dart';
import 'package:dispace/api/sso_api.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SsoApi ssoApi = new SsoApi();
  DiApi diApi = DiApi();
  bool isGuest = false;
  DiUser? user;
  String session = "Empty";

  void login() async {
    ssoApi = new SsoApi();
    await ssoApi.initializeCookies();
    await ssoApi.getAuthId();
    await ssoApi.login("", "");

    setState(() {
      session = ssoApi.session;
    });
  }

  void testGuest() async {
    final _isGuest = await ssoApi.test();
    setState(() {
      isGuest = _isGuest;
    });
  }

  void link() async {
    await ssoApi.authToDispace();
  }

  void getUser() async {
    final _user = await diApi.getUserById(84873);

    setState(() {
      user = _user;
    });
    return;
  }

  Future<List<DiChip>> receiveSomething() async {
    return diApi.getSemesterList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DiSpace Demo Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'DiSpace Cookie: $session',
            ),
            Text(
                "Country of user: ${user == null ? "don't know" : user!.country}"),
            Text("Is guest: $isGuest"),
            TextButton(
              onPressed: login,
              child: const Text("Try to log in"),
            ),
            TextButton(
              onPressed: testGuest,
              child: const Text("Check for guest"),
            ),
            TextButton(
              onPressed: link,
              child: const Text("Send link request"),
            ),
            TextButton(
              onPressed: getUser,
              child: const Text("Get user by id"),
            ),
          ],
        ),
      ),
    );
  }
}
