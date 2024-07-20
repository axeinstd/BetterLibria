import 'package:better_libria/src/home_upd.dart';
import 'package:flutter/material.dart';
import 'package:better_libria/main.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_libria/anilibria3/api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController controllerUser = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  String? sessionID;

  @override
  void initState() {
    super.initState();
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
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
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
              const Text(
                'BetterLibria Логин',
                style: TextStyle(fontSize: 23),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
              SizedBox(
                  width: 250,
                  child: TextField(
                    controller: controllerUser,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Логин / e-mail',
                    ),
                  )),
              const Padding(padding: EdgeInsets.only(top: 20)),
              SizedBox(
                  width: 250,
                  child: TextField(
                    controller: controllerPassword,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Пароль',
                    ),
                  )),
              const Padding(padding: EdgeInsets.only(top: 20)),
              Row(
                children: [
                  ButtonTheme(
                      child: ElevatedButton(
                          onPressed: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setBool('skipLoginPage', true);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(sessionID: '')),
                                (route) => false);
                          },
                          child: const Text('Пропустить'))),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  ButtonTheme(
                      child: ElevatedButton.icon(
                    onPressed: () async {
                      Libria client = Libria();
                      try {
                        String result = await client.auth(
                            controllerUser.value.text,
                            controllerPassword.value.text);
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString('sessionId', result);
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HomePage(sessionID: result)),
                            (route) => false);
                      } catch (e) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                title: Text('Ошибка'),
                                content: SizedBox(
                                  width: 250,
                                  child: Text('Авторизация не удалась.'),
                                ),
                              );
                            });
                      }
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Войти'),
                  )),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
