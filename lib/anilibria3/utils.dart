List<String> extractNames(Map releases, {lang = 'ru'}) {
  List<String> names = [];
  for (var release in releases['list']) {
    names.add(release['names'][lang]);
  }
  return names;
}

String trimDescription(String description) {
  if (description.length > 100) {
    return '${description.substring(0, 97)}...';
  }
  return description;
}

String getPosterUrl(Map all_posters) {
  return 'https://static-libria.weekstorm.us${all_posters['original']['url']}';
}


