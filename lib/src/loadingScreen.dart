import 'package:better_libria/src/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_libria/src/home_upd.dart';
import 'package:better_libria/anilibria3/api.dart';
import 'package:flutter/services.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool? skipLoginPage;
  late String sessionID;
  String currentStatus = 'Смотрим настройки';

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('askAlways', true);
    final client = Libria();
    skipLoginPage = prefs.getBool('skipLoginPage');
    sessionID = prefs.getString('sessionId') ?? '';
    await Future.delayed(const Duration(seconds: 2));
    if (skipLoginPage != null && skipLoginPage!) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(sessionID: sessionID)));
    } else if (sessionID != '') {
      setState(() {
        currentStatus = 'Проверяем авторизацию';
      });
      final testedUser = await client.getUserBySessionID(sessionID);
      if (testedUser!.containsKey('error')) {
        await prefs.remove('sessionId');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      }
      else {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => HomePage(sessionID: sessionID)));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).colorScheme.surfaceContainer,
      systemNavigationBarIconBrightness:
      Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    ));
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
              image:
              const AssetImage('assets/landing/libria_tyan256x256.png'),
              height: size.height > 400
                  ? MediaQuery.of(context).viewInsets.bottom == 0
                  ? size.height * 0.3
                  : size.height * 0.2
                  : 0),
          const Padding(padding: EdgeInsets.only(top: 10)),
          const Text(
            'Загружаем BetterLibria',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Padding(padding: EdgeInsets.only(top: 15)),
          const CircularProgressIndicator(),
          const Padding(padding: EdgeInsets.only(top: 20)),
          Text(currentStatus)
        ],
      ),
    ));
  }
}
