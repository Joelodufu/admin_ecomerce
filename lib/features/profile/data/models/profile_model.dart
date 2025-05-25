import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  ProfileModel({
    required String name,
    required String email,
    required String phone,
  }) : super(name: name, email: email, phone: phone);

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'phone': phone};
  }
}
