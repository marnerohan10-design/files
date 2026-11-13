class UserModel {
  const UserModel({required this.name, required this.email, this.phone = ''});

  final String name;
  final String email;
  final String phone;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  String get initials => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  UserModel copyWith({String? name, String? phone}) {
    return UserModel(
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'phone': phone};
}
