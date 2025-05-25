import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../models/profile_model.dart';

abstract class ProfileDataSource {
  Future<ProfileModel> getProfile();
}

class ProfileDataSourceImpl implements ProfileDataSource {
  final http.Client client;

  ProfileDataSourceImpl(this.client);

  @override
  Future<ProfileModel> getProfile() async {
    final uri = Uri.parse('${AppConstants.baseUrl}/profile');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return ProfileModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load profile');
    }
  }
}
