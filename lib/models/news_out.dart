class NewsOut {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final String url;
  final String category;
  final String? location;

  NewsOut({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.url,
    required this.category,
    this.location,
  });

  factory NewsOut.fromJson(Map<String, dynamic> json) => NewsOut(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        timeAgo: json['timeAgo'] ?? 'Just now',
        url: json['url'] ?? '',
        category: json['category'] ?? 'Local',
        location: json['location'],
      );
}
