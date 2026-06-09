class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String age; // e.g. "group_a", "group_b"

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.age,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role']?.toString() ?? '0',
      age: json['age']?.toString() ?? '',
    );
  }
}
