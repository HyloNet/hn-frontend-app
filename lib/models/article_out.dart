class ArticleOut {
  final int id;
  final String title;
  final String description;
  final String url;
  final String? sourceSite;
  final String? category;
  final String? publishedAt;
  final String fetchedAt;

  ArticleOut({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    this.sourceSite,
    this.category,
    this.publishedAt,
    required this.fetchedAt,
  });

  factory ArticleOut.fromJson(Map<String, dynamic> json) => ArticleOut(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        url: json['url'] ?? '',
        sourceSite: json['source_site'],
        category: json['category'],
        publishedAt: json['published_at'],
        fetchedAt: json['fetched_at'] ?? '',
      );
}
