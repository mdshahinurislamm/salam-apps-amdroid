class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String age;
  final String country;
  final String accessToken; // Sanctum Bearer token

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.age,
    this.country = '',
    this.accessToken = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '0',
      age: json['age']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      accessToken: json['access_token']?.toString() ?? '',
    );
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? age,
    String? country,
    String? accessToken,
  }) {
    return UserModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role,
      age: age ?? this.age,
      country: country ?? this.country,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'role': role,
        'age': age,
        'country': country,
        'access_token': accessToken,
      };
}
