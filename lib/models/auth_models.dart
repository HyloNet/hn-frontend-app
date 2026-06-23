class UserRegister {
  final String mobileNumber;
  final String password;
  final String? country;
  final String? state;
  final String? district;
  final String? cityVillage;

  UserRegister({
    required this.mobileNumber,
    required this.password,
    this.country,
    this.state,
    this.district,
    this.cityVillage,
  });

  Map<String, dynamic> toJson() => {
        'mobile_number': mobileNumber,
        'password': password,
        if (country != null) 'country': country,
        if (state != null) 'state': state,
        if (district != null) 'district': district,
        if (cityVillage != null) 'city_village': cityVillage,
      };
}

class UserLogin {
  final String mobileNumber;
  final String password;

  UserLogin({
    required this.mobileNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'mobile_number': mobileNumber,
        'password': password,
      };
}

class UserOut {
  final int id;
  final String mobileNumber;
  final String? country;
  final String? state;
  final String? district;
  final String? cityVillage;
  final String createdAt;
  final bool isAdmin;

  UserOut({
    required this.id,
    required this.mobileNumber,
    this.country,
    this.state,
    this.district,
    this.cityVillage,
    required this.createdAt,
    this.isAdmin = false,
  });

  factory UserOut.fromJson(Map<String, dynamic> json) => UserOut(
        id: json['id'] ?? 0,
        mobileNumber: json['mobile_number'] ?? '',
        country: json['country'],
        state: json['state'],
        district: json['district'],
        cityVillage: json['city_village'],
        createdAt: json['created_at'] ?? '',
        isAdmin: json['is_admin'] ?? false,
      );
}
