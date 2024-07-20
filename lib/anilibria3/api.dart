import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Libria {
  final String _baseUrl = 'api.anilibria.tv';
  final String _unblockedBaseUrl = 'vk.anilib.moe';

  Future<Map> asyncQuickSearch(String releaseName, {int page=1, int itemsPerPage=5}) async {
    Map<String, dynamic> params = {
      'search': releaseName,
      'page': page.toString(),
      'items_per_page':  itemsPerPage.toString(),
      'filter': 'id,names,posters'
    };
    final searchUrl = Uri.https(_unblockedBaseUrl, '/api/v3/title/search', params);
    final response = await http.get(searchUrl);
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body) as Map<dynamic, dynamic>;
      case 400:
        return {'error': 'BadRequest'};
      default:
        return {'error': 'A Wild Error Appears'};
    }
  }
  Future<Map> asyncUpdatesToHome({int page=1, int itemsPerPage=5}) async {
    Map<String, dynamic> params = {
      'page': page.toString(),
      'items_per_page':  itemsPerPage.toString(),
      'filter': 'id,names,description,posters'
    };
    final searchUrl = Uri.https(_unblockedBaseUrl, '/api/v3/title/updates', params);
    final response = await http.get(searchUrl);
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body) as Map<dynamic, dynamic>;
      case 400:
        return {'error': 'BadRequest'};
      default:
        return {'error': 'A Wild Error Appears'};
    }
  }

  Future<Map> asyncQuickSearchToHome(String releaseName, {int page=1, int itemsPerPage=8}) async {
    Map<String, dynamic> params = {
      'search': releaseName,
      'page': page.toString(),
      'items_per_page':  itemsPerPage.toString(),
      'filter': 'id,names,posters,description'
    };
    final searchUrl = Uri.https(_unblockedBaseUrl, '/api/v3/title/search', params);
    final response = await http.get(searchUrl);
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body) as Map<dynamic, dynamic>;
      case 400:
        return {'error': 'BadRequest'};
      default:
        return {'error': 'A Wild Error Appears'};
    }
  }

  Future<LRelease> getFullTitle(int id) async {
    Map<String, dynamic> params = {
      'id': id.toString(),
    };
    final searchUrl = Uri.https(_unblockedBaseUrl, '/api/v3/title', params);
    final response = await http.get(searchUrl);
    switch (response.statusCode) {
      case 200:
        Map release = json.decode(response.body);
        return LRelease(release);
      default:
        return LRelease({'error': true});
    }
  }
  Future<String> auth(String username, String password) async {
    Map<String, String> body = {
      'mail': username,
      'passwd': password
    };
    final url = Uri.https(_unblockedBaseUrl, '/public/login.php');
    final response = await http.post(url, body: body);
    switch (response.statusCode) {
      case 200:
        Map session = json.decode(response.body);
        return session['sessionId'];
      default:
        return '';
    }
  }
  Future<List?> getFavourites(String sessionId) async {
    Map<String, String> params = {
      'session': sessionId,
      'items_per_page': '200'
    };
    final url = Uri.https(_unblockedBaseUrl, '/api/v3/user/favorites', params);
    final response = await http.get(url);
    switch (response.statusCode) {
      case 200:
        List releases = json.decode(response.body)['list'];
        return releases;
      default:
        return null;
    }
  }
  Future<Map?> getUserBySessionID(String sessionID) async {
    Map<String, String> params = {
      'session': sessionID
    };
    final url = Uri.https(_unblockedBaseUrl, '/api/v3/user', params);
    final response = await http.get(url);
    switch (response.statusCode) {
      case 200:
        Map userInfo = json.decode(response.body);
        return userInfo;
      default:
        return null;
    }
  }
  Future<void> logout(String sessionID) async {
    Map<String, String> body = {
      'id': sessionID
    };
    final url = Uri.https(_unblockedBaseUrl, '/public/close.php');
    final response = await http.post(
        url,
        body: body,
        headers: {'Cookie': 'PHPSESSID=$sessionID'}
    );
  }
  Future<void> deleteFavourite(String session, int titleId) async {
    Map<String, String> params = {
      'session': session,
      'title_id': titleId.toString()
    };
    final url = Uri.https(_unblockedBaseUrl, '/api/v3/user/favorites', params);
    final response = await http.delete(url);
  }
  Future<void> addFavourite(String session, int titleId) async {
    Map<String, String> params = {
      'session': session,
      'title_id': titleId.toString()
    };
    final url = Uri.https(_unblockedBaseUrl, '/api/v3/user/favorites', params);
    final response = await http.put(url);
  }
  Future<List> getSchedule() async {
    Map<String, String> params = {
      'filter': 'id,names,posters,description'
    };
    final url = Uri.https(_unblockedBaseUrl, '/api/v3/title/schedule', params);
    final response = await http.get(url);
    switch (response.statusCode) {
      case 200:
        List res = json.decode(response.body);
        return res;
      default:
        return [];
    }
  }
}

class LRelease {
  late Map release;
  late int id;
  late String code;
  late Map names;
  late String ruName;
  late List franchises;
  late String announce;
  late Map status;
  late String posterUrl;
  late Map type;
  late List genres;
  late Map team;
  late Map season;
  late String description;
  late int inFavourites;
  late Map player;
  late Map torrents;
  bool isError = false;

  LRelease(Map releaseData) {
    if (releaseData.containsKey('error')) {
      isError = true;
      return;
    }

    release = releaseData;
    id = release['id'];
    code = release['code'];
    names = release['names'];
    ruName = names['ru'];
    franchises = release['franchises'];
    announce = release['announce'] != null ? release['announce'] : '';
    status = release['status'];
    posterUrl = 'https://static-libria.weekstorm.us${release['posters']['original']['url']}';
    type = release['type'];
    genres = release['genres'];
    team = release['team'];
    season = release['season'];
    description = release['description'] ?? 'Описание отсутствует';
    inFavourites = release['in_favorites'];
    player = release['player'];
    torrents = release['torrents'];
  }
}