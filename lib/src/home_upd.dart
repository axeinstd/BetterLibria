import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:better_libria/anilibria3/api.dart';
import 'package:better_libria/anilibria3/utils.dart';
import 'package:better_libria/src/release.dart';
import 'package:better_libria/src/login.dart';
import 'package:flutter/services.dart';
import 'package:better_libria/src/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.sessionID});

  String sessionID;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Libria client = Libria();
  final SearchController controller = SearchController();
  final SearchController _controller = SearchController();
  final ScrollController _scrollHomeController = ScrollController();
  late Map quickSearched;
  List? favourites;
  Map? userInfo;
  List homeSearched = [];
  int currentPageIndex = 0;
  bool isLast = false, isFromSearch = false;
  String searchTo = '';
  int page = 1, maxPage = 0;
  List? schedule;
  Map daysInSchedule = {
    0: 'Понедельник',
    1: 'Вторник',
    2: 'Среда',
    3: 'Четверг',
    4: 'Пятница',
    5: 'Суббота',
    6: 'Воскресенье'
  };

  Future getUpdatesHome() async {
    if (isLast) return;

    Map homeReleases =
        await client.asyncUpdatesToHome(page: page, itemsPerPage: 8);
    setState(() {
      homeSearched.addAll(homeReleases['list']);
      maxPage = homeReleases['pagination']['pages'];
      page++;
      if (page >= maxPage) {
        isLast = true;
      }
    });
  }

  void loadSchedule() async {
    schedule = await client.getSchedule();
    setState(() {});
  }

  void logout() async {
    if (widget.sessionID != '') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('sessionId');
      await client.logout(widget.sessionID);
      widget.sessionID = '';
      setState(() {});
    }
  }

  void loadFavourites() async {
    favourites = await client.getFavourites(widget.sessionID);
    setState(() {});
  }

  void getUserInfo() async {
    userInfo = await client.getUserBySessionID(widget.sessionID);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    getUpdatesHome();

    _scrollHomeController.addListener(() {
      if (_scrollHomeController.position.pixels ==
          _scrollHomeController.position.maxScrollExtent) {
        getUpdatesHome();
      }
    });
    if (widget.sessionID != '') {
      loadFavourites();
      getUserInfo();
    }
    loadSchedule();
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

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
          if (index == 1) {
            favourites = null;
            loadFavourites();
          }
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
              icon: Icon(Icons.home_rounded), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.star), label: 'Избранное'),
          NavigationDestination(
              icon: Icon(Icons.schedule_rounded), label: 'Расписание'),
          NavigationDestination(
              icon: Icon(Icons.account_circle_rounded), label: 'Профиль'),
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: <Widget>[
          SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  toolbarHeight: 75,
                  centerTitle: true,
                  forceMaterialTransparency: true,
                  title: SearchAnchor(
                    searchController: _controller,
                    viewLeading: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          setState(() {
                            _controller.closeView(null);
                            _controller.clear();
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          });
                        }),
                    builder:
                        (BuildContext context, SearchController controller) {
                      return SearchBar(
                        onTapOutside: (tap) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        onSubmitted: (searched) {
                          setState(() {
                            controller.closeView(searched);
                          });
                        },
                        shadowColor: WidgetStateColor.resolveWith(
                            (states) => Colors.transparent),
                        controller: controller,
                        onTap: () {
                          controller.openView();
                        },
                        onChanged: (_) {
                          controller.openView();
                        },
                        hintText: 'Искать на АниЛибрии',
                        leading: const Icon(Icons.search),
                        trailing: <Widget>[
                          Tooltip(
                              message: 'Открыть настройки',
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SettingsPage(
                                                bright: Theme.of(context)
                                                    .brightness,
                                              )),
                                      (route) => true);
                                },
                                isSelected: false,
                                icon: const Icon(Icons.settings_rounded),
                              ))
                        ],
                      );
                    },
                    suggestionsBuilder: (BuildContext context,
                        SearchController controller) async {
                      quickSearched = await client
                          .asyncQuickSearch(controller.text, itemsPerPage: 10);
                      final List<String> names = extractNames(quickSearched);
                      return List.generate(names.length, (int index) {
                        final String item = names[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 0),
                          child: ListTile(
                            leading: Image.network(getPosterUrl(
                                quickSearched['list'][index]['posters'])),
                            title: Text(item),
                            onTap: () {
                              setState(() {
                                _controller.closeView(item);
                                _controller.clear();
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReleasePage(
                                            releaseId: quickSearched['list']
                                                [index]['id'])),
                                    (route) => true);
                              });
                            },
                          ),
                        );
                      });
                    },
                  ),
                ),
                body: ListView.builder(
                  controller: _scrollHomeController,
                  itemCount: homeSearched.length + 1,
                  itemBuilder: (context, index) {
                    if (index < homeSearched.length) {
                      return Card(
                          child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReleasePage(
                                      releaseId: homeSearched[index]['id'])));
                        },
                        splashColor: Theme.of(context)
                            .colorScheme
                            .inversePrimary
                            .withAlpha(60),
                        child: ListTile(
                          leading: Image.network(
                              getPosterUrl(homeSearched[index]['posters'])),
                          title: Text(homeSearched[index]['names']['ru']),
                          subtitle: Text(
                            trimDescription(homeSearched[index]['description']),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ));
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        child: Center(
                            child: !isLast
                                ? const Text('Загружаем релизы...')
                                : const Text('Ничего нет')),
                        //child: Center(child: !isLast ? const CircularProgressIndicator() : const Text('Ничего нет')),
                      );
                    }
                  },
                )),
          ),
          widget.sessionID == ''
              ? const SafeArea(
                  child: Center(
                      child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Авторизуйтесь для просмотра',
                      style: TextStyle(
                          fontFamily: 'JetBrainsMono Nerd Font', fontSize: 16),
                    ),
                    Text(
                      'избранных релизов',
                      style: TextStyle(
                          fontFamily: 'JetBrainsMono Nerd Font', fontSize: 16),
                    ),
                    Padding(padding: EdgeInsets.only(top: 5)),
                    Icon(
                      Icons.star_rounded,
                      size: 40,
                    ),
                  ],
                )))
              : Scaffold(
                  appBar: AppBar(
                    title: const Text('Избранное'),
                    forceMaterialTransparency: true,
                  ),
                  body: favourites != null
                      ? ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                                child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReleasePage(
                                            releaseId: favourites![index]
                                                ['id'])));
                              },
                              child: ListTile(
                                leading: Image.network(getPosterUrl(
                                    favourites![index]['posters'])),
                                title: Text(favourites![index]['names']['ru']),
                                subtitle: Text(trimDescription(
                                    favourites![index]['description'])),
                              ),
                            ));
                          },
                          itemCount: favourites!.length)
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Загружаем избранное',
                                style: TextStyle(
                                    fontFamily: 'JetBrainsMono Nerd Font',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(padding: EdgeInsets.only(top: 10)),
                              CircularProgressIndicator()
                            ],
                          ),
                        )),
          Scaffold(
              appBar: AppBar(
                title: const Text('Расписание'),
                forceMaterialTransparency: true,
              ),
              body: schedule == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Загружаем избранное',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Padding(padding: EdgeInsets.only(top: 10)),
                          CircularProgressIndicator()
                        ],
                      ),
                    )
                  : schedule.toString() == '[]'
                      ? const Center(
                          child: Text(
                            'Не удалось загрузить',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: 7,
                          itemBuilder: (BuildContext context, int index) {
                            Map currentDay = schedule![index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      daysInSchedule[currentDay['day']],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 150,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: currentDay['list'].length,
                                        itemBuilder: (BuildContext context,
                                            int horizontalIndex) {
                                          Map currentRelease =
                                              currentDay['list']
                                                  [horizontalIndex];
                                          return Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: GestureDetector(
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
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.network(
                                                    getPosterUrl(currentRelease[
                                                        'posters']),
                                                    height: 100,
                                                  ),
                                                )),
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
          Scaffold(
              appBar: AppBar(
                title: const Text('Профиль & Ссылки'),
                forceMaterialTransparency: true,
              ),
              body: ListView(
                children: [
                  widget.sessionID == ''
                      ? Card(
                          child: ListTile(
                            leading: const Icon(Icons.account_circle_rounded),
                            title: const Text('Гость'),
                            subtitle: const Text('Нажмите, чтобы войти'),
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()));
                            },
                          ),
                        )
                      : userInfo != null
                          ? Card(
                              child: ListTile(
                                leading:
                                    const Icon(Icons.account_circle_rounded),
                                title: Text(userInfo!['nickname'] ??
                                    userInfo!['login']),
                                subtitle: const Text('Вход выполнен'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.logout_rounded),
                                  onPressed: logout,
                                ),
                              ),
                            )
                          : const Card(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 0),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          'Загружаем информацию о пользователе'),
                                      CircularProgressIndicator()
                                    ],
                                  ),
                                ),
                              ),
                            ),
                  Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ссылки АниЛибрии: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                            ListTile(
                              title: const Text('Группа VK'),
                              onTap: () {
                                launchUrl(Uri.parse('https://vk.com/anilibria'), mode: LaunchMode.externalApplication);
                              },
                            ),
                            ListTile(
                              title: const Text('Канал YouTube'),
                              onTap: () {
                                launchUrl(Uri.parse('https://www.youtube.com/@anilibriatv'), mode: LaunchMode.externalApplication);
                              },
                            ),
                            ListTile(
                              title: const Text('Patreon'),
                              onTap: () {
                                launchUrl(Uri.parse('https://www.youtube.com/@anilibriatv'), mode: LaunchMode.externalApplication);
                              },
                            ),
                            ListTile(
                              title: const Text('Канал Telegram'),
                              onTap: () {
                                launchUrl(Uri.parse('https://t.me/anilibria'), mode: LaunchMode.externalApplication);
                              },
                            ),
                            ListTile(
                              title: const Text('Чат Discord'),
                              onTap: () {
                                launchUrl(Uri.parse('https://discord.gg/M6yCGeGN9B'), mode: LaunchMode.externalApplication);
                              },
                            ),
                            ListTile(
                              title: const Text('Сайт AniLibria'),
                              onTap: () {
                                launchUrl(Uri.parse('https://vk.anilib.top'), mode: LaunchMode.externalApplication);
                              },
                            ),
                          ],
                        ),
                      )
                  ),
                  Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ссылки axeinstd: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                            ListTile(
                              title: const Text('Канал YouTube'),
                              onTap: () {
                                launchUrl(Uri.parse('https://youtube.com/@axeinstd'), mode: LaunchMode.externalApplication);
                              },
                            ),
                            ListTile(
                              title: const Text('Канал Telegram'),
                              onTap: () {
                                launchUrl(Uri.parse('https://t.me/axeinstd'), mode: LaunchMode.externalApplication);
                              },
                            ),
                          ],
                        ),
                      )
                  )
                ],
              ))
        ],
      ),
    );
  }
}
