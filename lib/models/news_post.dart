class NewsPost {
  final String id;
  final String title;
  final String description;
  final String? imageUrl; // Made optional
  final String category;
  final String location;
  final String distance;
  final String timeAgo;
  final String? url; // Link to full story

  NewsPost({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.location,
    required this.distance,
    required this.timeAgo,
    this.url,
  });
}

// Dummy data for UI building
final List<NewsPost> dummyNews = List.generate(20, (index) => NewsPost(
  id: '$index',
  title: 'News Headline #$index for $index City Area',
  description: 'This is a brief description of the news event happening in your local neighborhood. It provides enough detail to interest the reader.',
  category: 'Local',
  location: 'Area $index',
  distance: '${(index * 0.5).toStringAsFixed(1)} km',
  timeAgo: '${index + 1}h ago',
  url: 'https://google.com/news/$index',
));
