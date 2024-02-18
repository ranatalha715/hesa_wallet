class ConnectedSites {
  final String urls;

  ConnectedSites({
    required this.urls,
  });

  factory ConnectedSites.fromJson(String json) {
    return ConnectedSites(urls: json);
  }
}
