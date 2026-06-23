class LocationCreate {
  final String name;
  final String? pincode;
  final String? country;

  LocationCreate({
    required this.name,
    this.pincode,
    this.country,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (pincode != null) 'pincode': pincode,
        if (country != null) 'country': country,
      };
}

class LocationOut {
  final int id;
  final String name;
  final String slug;
  final String? pincode;
  final String? country;
  final String createdAt;

  LocationOut({
    required this.id,
    required this.name,
    required this.slug,
    this.pincode,
    this.country,
    required this.createdAt,
  });

  factory LocationOut.fromJson(Map<String, dynamic> json) => LocationOut(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        slug: json['slug'] ?? '',
        pincode: json['pincode'],
        country: json['country'],
        createdAt: json['created_at'] ?? '',
      );
}
