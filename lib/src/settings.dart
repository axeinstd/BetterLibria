import 'package:better_libria/src/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:better_libria/src/about.dart';
import 'package:better_libria/src/themes/themes_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.bright});

  final Brightness bright;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int? defaultQuality;
  final List<String> qualities = ['1080p', '720p', '480p'];
  int player = 0;
  bool askAlways = true;

  void loadQuality() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    defaultQuality = prefs.getInt('defaultQuality') ?? 0;
    setState(() {});
  }

  void showPlayerDialog(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, StateSetter setState) {
                return AlertDialog(
                  title: const Text('Выберите плеер'),
                  content: SizedBox(
                    width: 400,
                    height: size.height > 500 ? 465 : 300,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Card.outlined(
                                  borderOnForeground: false,
                                  clipBehavior: Clip.hardEdge,
                                  child: InkWell(
                                      onTap: () async {
                                        setState((){
                                          player = 0;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(width: player == 0 ? 3 : 1, color: Theme.of(context).colorScheme.outlineVariant),
                                            borderRadius: BorderRadius.circular(14)
                                        ),
                                        child: const ListTile(
                                          title: Text('Встроенный плеер'),
                                          subtitle: Text(
                                              'Воспроизвести в нашем плеере, который улучшается и дорабатывается по мере развития приложения.'),
                                        ),
                                      )
                                  ),
                                ),
                                Card.outlined(
                                  clipBehavior: Clip.hardEdge,
                                  child: InkWell(
                                      onTap: () async {
                                        setState(() {
                                          player = 1;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(width: player == 1 ? 3 : 1, color: Theme.of(context).colorScheme.outlineVariant),
                                            borderRadius: BorderRadius.circular(14)
                                        ),
                                        child:  const ListTile(
                                          title: Text('Сторонний плеер'),
                                          subtitle: Text(
                                            'Воспроизвести в стороннем плеере, установленном на вашем устройстве. Качество воспроизведения можно изменить в настройках приложения.',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      )
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          clipBehavior: Clip.hardEdge,
                          child: CheckboxListTile(
                            value: askAlways,
                            onChanged: (bool? val) async {
                              setState(() {
                                askAlways = val!;
                              });
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('askAlways', askAlways);
                            },
                            title: const Text('Спрашивать всегда'),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            child: const Text('Сохранить'),
                            onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setInt('defaultPlayer', player);
                              Navigator.pop(context);
                            }
                          ),
                        )
                      ],
                    ),
                  ),
                );
              });
        });
  }

  @override
  void initState() {
    super.initState();
    loadQuality();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor:
      Theme.of(context).colorScheme.surfaceContainer,
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
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Сменить тему'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: const Text('Тема: '),
                        content: SizedBox(
                          height: 180,
                          child: Column(
                            children: [
                              RadioListTile(
                                  title: const Text('Светлая'),
                                  value: ThemeMode.light,
                                  groupValue: Provider.of<ThemeProvider>(
                                          context,
                                          listen: false)
                                      .themeMode,
                                  onChanged: (brightness) {
                                    setState(() {
                                      Provider.of<ThemeProvider>(context,
                                              listen: false)
                                          .setLight();
                                      Navigator.of(context).pop();
                                      SystemChrome.setSystemUIOverlayStyle(
                                          SystemUiOverlayStyle(
                                              systemNavigationBarColor:
                                                  lightTheme.colorScheme.surfaceContainer,
                                                  systemNavigationBarIconBrightness: Brightness.dark,
                                          statusBarColor: Colors.transparent,
                                          statusBarIconBrightness: Brightness.dark));
                                    });
                                  }),
                              RadioListTile(
                                  title: const Text('Темная'),
                                  value: ThemeMode.dark,
                                  groupValue: Provider.of<ThemeProvider>(
                                          context,
                                          listen: false)
                                      .themeMode,
                                  onChanged: (brightness) {
                                    setState(() {
                                      Provider.of<ThemeProvider>(context,
                                              listen: false)
                                          .setDark();
                                      Navigator.of(context).pop();
                                      SystemChrome.setSystemUIOverlayStyle(
                                          SystemUiOverlayStyle(
                                              systemNavigationBarColor:
                                              darkTheme.colorScheme.surfaceContainer,
                                              systemNavigationBarIconBrightness:
                                              Brightness.light,
                                              statusBarColor: Colors.transparent,
                                              statusBarIconBrightness: Brightness.light));
                                    });
                                  }),
                              RadioListTile(
                                  title: const Text('Системная'),
                                  value: ThemeMode.system,
                                  groupValue: Provider.of<ThemeProvider>(
                                          context,
                                          listen: false)
                                      .themeMode,
                                  onChanged: (brightness) {
                                    setState(() {
                                      Provider.of<ThemeProvider>(context,
                                              listen: false)
                                          .setSystem();
                                      Navigator.of(context).pop();
                                    });
                                    SystemChrome.setSystemUIOverlayStyle(
                                        SystemUiOverlayStyle(
                                            systemNavigationBarColor: MediaQuery.of(context).platformBrightness == Brightness.light
                                            ? lightTheme.colorScheme.surfaceContainer
                                            : darkTheme.colorScheme.surfaceContainer,
                                            systemNavigationBarIconBrightness: MediaQuery.of(context).platformBrightness == Brightness.light
                                            ? Brightness.dark : Brightness.light,
                                            statusBarColor: Colors.transparent,
                                            statusBarIconBrightness: MediaQuery.of(context).platformBrightness == Brightness.light ? Brightness.dark : Brightness.light,
                                        ));
                                  }),
                            ],
                          ),
                        ));
                  });
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_collection_outlined),
            title: const Text('Плеер по умолчанию'),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              player = prefs.getInt('defaultPlayer') ?? 0;
              askAlways = prefs.getBool('askAlways') ?? true;
              showPlayerDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.high_quality_outlined),
            title: Text('Качество видео: ${defaultQuality != null ? qualities[defaultQuality!] : ''}'),
            onTap: () {
              showDialog(context: context, builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Выберите разрешение'),
                  content: defaultQuality == null
                    ? const Center(
                    child: CircularProgressIndicator(),
                  )
                    : SizedBox(
                    height: 170,
                    child: Column(
                      children: [
                        RadioListTile(value: 0, groupValue: defaultQuality, title: const Text('1080p') , onChanged: (int? quality) async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          defaultQuality = quality!;
                          prefs.setInt('defaultQuality', quality);
                          setState(() {});
                          Navigator.pop(context);
                        }),
                        RadioListTile(value: 1, groupValue: defaultQuality, title: const Text('720p') , onChanged: (int? quality) async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          defaultQuality = quality!;
                          prefs.setInt('defaultQuality', quality);
                          setState(() {});
                          Navigator.pop(context);
                        }),
                        RadioListTile(value: 2, groupValue: defaultQuality, title: const Text('480p') , onChanged: (int? quality) async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          defaultQuality = quality!;
                          prefs.setInt('defaultQuality', quality);
                          setState(() {});
                          Navigator.pop(context);
                        }),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('О приложении'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
            },
          )
        ],
      ),
    );
  }
}
