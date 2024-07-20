import 'package:flutter/material.dart';
import 'package:better_libria/anilibria3/api.dart';
import 'package:better_libria/anilibria3/utils.dart';
import 'package:better_libria/src/release.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Libria client = Libria();
  final SearchController controller = SearchController();
  late Map quickSearched;
  List homeSearched = [];
  int currentPageIndex = 0;
  final ScrollController _scrollHomeController = ScrollController();
  int page = 1;

  Future<List> getHomePageData() async {
    Map homeReleases = await client.asyncUpdatesToHome(page:page, itemsPerPage: 6);
    homeSearched.addAll(homeReleases['list']);
    return homeSearched;
  }

  @override
  void initState() {
    super.initState();
    _scrollHomeController.addListener(() {
      if (_scrollHomeController.position.pixels >= _scrollHomeController.position.maxScrollExtent - 200) {
        page++;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
              icon: Icon(Icons.home_rounded), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.star), label: 'Избранное'),
          NavigationDestination(
              icon: Icon(Icons.account_circle_rounded), label: 'Расписание'),
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
                title: SearchAnchor(
                  builder: (BuildContext context, SearchController controller) {
                    return SearchBar(
                      shadowColor: WidgetStateColor.resolveWith((states) => Colors.transparent),
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
                            message: 'Open settings',
                            child: IconButton(
                              onPressed: () {},
                              isSelected: false,
                              icon: const Icon(Icons.settings_rounded),
                            ))
                      ],
                    );
                  },
                  suggestionsBuilder: (BuildContext context,
                      SearchController controller) async {
                    quickSearched =
                    await client.asyncQuickSearch(controller.text);
                    final List<String> names = extractNames(quickSearched);
                    return List.generate(names.length, (int index) {
                      final String item = '${names[index]}';
                      return ListTile(
                        title: Text(item),
                        onTap: () {
                          setState(() {
                            print('Printed');
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => ReleasePage(releaseId: releaseId)))
                          });
                        },
                      );
                    });
                  },
                ),
              ),
              body: CustomScrollView(
                controller: _scrollHomeController,
                slivers: [
                  FutureBuilder(
                    future: getHomePageData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                          return SliverToBoxAdapter(
                            child: Center(child: Text('Ошибка: ${snapshot.error}')),
                          );
                      } else{
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                Map posterMap = snapshot.data?[index]['posters'] ?? {}; // Если значение равно null, присваиваем пустую строку
                                String ruName = snapshot.data?[index]['names']['ru'] ?? '';
                                String description = snapshot.data?[index]['description'] ?? '';
                                return Card(
                                  child: ListTile(
                                    leading: posterMap != {} ? Image.network(getPosterUrl(posterMap)) : const Icon(Icons.video_label_rounded),
                                    title: Text(ruName),
                                    subtitle: Text(trimDescription(snapshot.data?[index]['description']), style: const TextStyle(fontSize: 10),),
                                  ),
                                );
                              },
                            childCount: snapshot.data?.length,
                          ),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),

          const SafeArea(
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
        ],
      ),
    );
  }
}
