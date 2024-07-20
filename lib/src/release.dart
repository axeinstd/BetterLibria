import 'package:android_intent_plus/android_intent.dart';
import 'package:better_libria/src/login.dart';
import 'package:flutter/material.dart';
import 'package:better_libria/anilibria3/api.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_libria/src/player.dart';

class ReleasePage extends StatefulWidget {
  const ReleasePage({super.key, required this.releaseId});

  final int releaseId;

  @override
  State<ReleasePage> createState() => _ReleasePageState();
}

class _ReleasePageState extends State<ReleasePage> {
  LRelease? release;
  Libria client = Libria();
  int player = 0;
  bool askAlways = true;
  late int playFromEpisode;
  bool loadingFavs = true, favourite = false, needToLogin = false;
  late String sessionID;

  void isInFavs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('sessionId');
    if (sessionId == null) {
      loadingFavs = false;
      needToLogin = true;
      setState(() {});
    } else {
      sessionID = sessionId;
      List? favourites = await client.getFavourites(sessionId);
      if (favourites == null) {
        loadingFavs = false;
        setState(() {});
      } else {
        for (Map i in favourites) {
          if (i['id'] == widget.releaseId) {
            loadingFavs = false;
            favourite = true;
            setState(() {});
            break;
          }
        }
        if (loadingFavs = true) {
          loadingFavs = false;
          setState(() {});
        }
      }
    }
  }

  Future<void> loadRelease() async {
    release = await client.getFullTitle(widget.releaseId);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    playFromEpisode = prefs.getInt('${release!.id}playFromEpisode') ?? 0;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    loadRelease();
    isInFavs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showPlayerDialog(BuildContext context, List<String> urls, int episode) {
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
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
                                    setState(() {
                                      player = 0;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: player == 0 ? 3 : 1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outlineVariant),
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    child: const ListTile(
                                      title: Text('Встроенный плеер'),
                                      subtitle: Text(
                                          'Воспроизвести в нашем плеере, который улучшается и дорабатывается по мере развития приложения.'),
                                    ),
                                  )),
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
                                        border: Border.all(
                                            width: player == 1 ? 3 : 1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outlineVariant),
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    child: const ListTile(
                                      title: Text('Сторонний плеер'),
                                      subtitle: Text(
                                        'Воспроизвести в стороннем плеере, установленном на вашем устройстве. Качество воспроизведения можно изменить в настройках приложения.',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  )),
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
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool('askAlways', askAlways);
                          await prefs.setInt('defaultPlayer', player);
                        },
                        title: const Text('Спрашивать всегда'),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: const Text('Продолжить'),
                        onPressed: () async {
                          Navigator.pop(context);
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          if (player == 0) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Player(
                                          urls: urls,
                                          releaseId: release!.id,
                                          releaseName: release!.ruName,
                                          episode: episode,
                                        )));
                          } else {
                            int defaultQuality =
                                prefs.getInt('defaultQuality') ?? 0;
                            AndroidIntent intent = AndroidIntent(
                                action: 'action_view',
                                type: 'video/*',
                                data: urls[defaultQuality]);
                            await intent.launch();
                          }
                        },
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
  Widget build(BuildContext context) {
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
    if (release == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Релиз'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Загружаем релиз',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            )
          ],
        )),
      );
    } else if (release!.isError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Релиз'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Не удалось загрузить релиз',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: Theme.of(context).colorScheme.secondary,
            )
          ],
        )),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Релиз'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (needToLogin) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Авторизуйтесь'),
                            content: const SizedBox(
                              child: Text(
                                  'Авторизуйтесь, чтобы добавить тайтл в избранное'),
                            ),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Отмена')),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage()));
                                  },
                                  child: const Text('Войти')),
                            ],
                          );
                        });
                  } else if (favourite) {
                    setState(() {
                      loadingFavs = true;
                    });
                    await client.deleteFavourite(sessionID, widget.releaseId);
                    favourite = false;
                    loadingFavs = false;
                    setState(() {});
                  } else if (!favourite) {
                    setState(() {
                      loadingFavs = true;
                    });
                    await client.addFavourite(sessionID, widget.releaseId);
                    loadingFavs = false;
                    favourite = true;
                    setState(() {});
                  }
                },
                label: Text(release!.inFavourites.toString()),
                icon: loadingFavs
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ))
                    : favourite
                        ? const Icon(Icons.star_rounded)
                        : const Icon(Icons.star_outline_rounded),
              ),
            )
          ],
        ),
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: ListView(
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              release!.posterUrl,
                              width: 150,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  release!.player['episodes'] != null
                      ? ElevatedButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            int currentReleaseIndex = playFromEpisode;
                            Map<dynamic, dynamic> currentEpisode = release!
                                .player['list'][currentReleaseIndex.toString()];
                            player = prefs.getInt('defaultPlayer') ?? 0;
                            bool askAlways = prefs.getBool('askAlways') ?? true;
                            List<String> urls = [
                              'https://${release!.player['host']}${currentEpisode['hls']['fhd']}',
                              'https://${release!.player['host']}${currentEpisode['hls']['hd']}',
                              'https://${release!.player['host']}${currentEpisode['hls']['sd']}'
                            ];
                            if (askAlways) {
                              showPlayerDialog(
                                  context, urls, currentReleaseIndex);
                            } else if (player == 0) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Player(
                                            urls: urls,
                                            releaseId: release!.id,
                                            releaseName: release!.ruName,
                                            episode: currentReleaseIndex,
                                          )));
                            } else {
                              int defaultQuality =
                                  prefs.getInt('defaultQuality') ?? 0;
                              AndroidIntent intent = AndroidIntent(
                                  action: 'action_view',
                                  type: 'video/*',
                                  data: urls[defaultQuality]);
                              await intent.launch();
                            }
                          },
                          child: Text(playFromEpisode == 0
                              ? 'Начать смотреть'
                              : 'Продолжить с $playFromEpisode серии'))
                      : ElevatedButton(
                          onPressed: () {},
                          child: const Text('Контент недоступен')),
                  Card(
                      child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          release!.ruName,
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          release!.names['en'],
                          style: const TextStyle(fontSize: 10),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 5)),
                        Text(
                            'Сезон: ${release!.season['year']} ${release!.season['string']}'),
                        Text('Тип: ${release!.type['full_string']}'),
                        Text(
                            'Жанры: ${release!.genres.toString().substring(1, release!.genres.toString().length - 1)}'),
                        Text(
                            'Озвучка: ${release!.team['voice'].toString().substring(1, release!.team['voice'].toString().length - 1)}'),
                        Text(
                            'Тайминг: ${release!.team['timing'].toString().substring(1, release!.team['timing'].toString().length - 1)}'),
                        Text(
                            'Работа над субритрами: ${release!.team['translator'].toString() != '[]' ? release!.team['translator'].toString().substring(1, release!.team['translator'].toString().length - 1) : 'не найдено'}'),
                        Text('Состояние релиза: ${release!.status['string']}')
                      ],
                    ),
                  )),
                  Card(
                    clipBehavior: Clip.hardEdge,
                    child: ExpansionTile(
                      title: const Text('Описание'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          child: Text(release!.description),
                        )
                      ],
                    ),
                  ),
                  Card(
                    clipBehavior: Clip.hardEdge,
                    child: ExpansionTile(
                      title: const Text('Франшиза'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          child: release!.franchises.toString() != '[]'
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      release!.franchises[0]['releases'].length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Map currentRelease = release!.franchises[0]
                                        ['releases'][index];
                                    return ListTile(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ReleasePage(
                                                        releaseId:
                                                            currentRelease[
                                                                'id'])));
                                      },
                                      title: Text(
                                        currentRelease['names']['ru'],
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                      subtitle:
                                          const Text('Нажмите, чтобы открыть'),
                                    );
                                  },
                                )
                              : const Text(
                                  'Этот тайтл не находится во франшизе'),
                        )
                      ],
                    ),
                  ),
                  Card(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        if (release!.player['episodes'] != null) {
                          int last = release!.player['episodes']['last'];
                          int currentReleaseIndex = last - index;
                          Map currentEpisode = release!.player['list']
                              [(currentReleaseIndex).toString()];
                          var name = currentEpisode['name'] != null
                              ? ': ${currentEpisode['name']}'
                              : '';
                          return ListTile(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              playFromEpisode = currentReleaseIndex;
                              setState(() {});
                              await prefs.setInt(
                                  '${release!.id}playFromEpisode',
                                  currentReleaseIndex);
                              player = prefs.getInt('defaultPlayer') ?? 0;
                              bool askAlways =
                                  prefs.getBool('askAlways') ?? true;
                              List<String> urls = [
                                'https://${release!.player['host']}${currentEpisode['hls']['fhd']}',
                                'https://${release!.player['host']}${currentEpisode['hls']['hd']}',
                                'https://${release!.player['host']}${currentEpisode['hls']['sd']}'
                              ];
                              if (askAlways) {
                                showPlayerDialog(
                                    context, urls, currentReleaseIndex);
                              } else if (player == 0) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Player(
                                              urls: urls,
                                              releaseId: release!.id,
                                              releaseName: release!.ruName,
                                              episode: currentReleaseIndex,
                                            )));
                              } else {
                                int defaultQuality =
                                    prefs.getInt('defaultQuality') ?? 0;
                                AndroidIntent intent = AndroidIntent(
                                    action: 'action_view',
                                    type: 'video/*',
                                    data: urls[defaultQuality]);
                                await intent.launch();
                              }
                            },
                            leading: currentReleaseIndex <= playFromEpisode
                                ? const Icon(Icons.check_circle_outline_rounded)
                                : null,
                            title: Text(
                                'Эпизод ${currentEpisode['episode']}$name'),
                          );
                        } else {
                          return const ListTile(
                            title: Text(
                              'Контент не найден',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        }
                      },
                      itemCount: release!.player['episodes'] != null
                          ? release!.player['episodes']['last']
                          : 1,
                    ),
                  ),
                  Card(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return const ListTile(
                            title: Text(
                              'Торрент раздачи',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                        var currentTorrent =
                            release!.torrents['list'][index - 1];
                        return ListTile(
                          onTap: () async {
                            await Clipboard.setData(
                                ClipboardData(text: currentTorrent['magnet']));
                          },
                          title: Text(
                              '${currentTorrent['quality']['string']}, ${currentTorrent['episodes']['string']}'),
                          subtitle: Text(
                              'Размер: ${currentTorrent['size_string']}, Загрузок: ${currentTorrent['downloads']}, magnet ссылка'),
                        );
                      },
                      itemCount: release!.torrents['list'].length + 1,
                    ),
                  )
                ],
              )),
        ),
      );
    }
  }
}
