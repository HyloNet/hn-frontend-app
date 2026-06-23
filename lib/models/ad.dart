class Ad {
  final String id;
  final String shopName;
  final String offer;
  final String phone;
  final String imageUrl;
  final String? area;

  Ad({
    required this.id,
    required this.shopName,
    required this.offer,
    required this.phone,
    required this.imageUrl,
    this.area,
  });

  factory Ad.fromJson(Map<String, dynamic> json) => Ad(
        id: json['id']?.toString() ?? '',
        shopName: json['shop_name'] ?? '',
        offer: json['offer'] ?? '',
        phone: json['phone'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        area: json['area'],
      );
}
