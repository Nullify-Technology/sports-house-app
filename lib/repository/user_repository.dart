import 'package:sports_house/models/auth.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sports_house/utils/constants.dart';
class UserRepository {
  final RestClient client;
  final storage = FlutterSecureStorage();
  UserRepository({required this.client});

  Future<AuthUser> getUser(idToken, phoneNumber) async {

  }

  Future<AuthUser> updateUser(name, profileUrl) async {
    AuthUser response = await client.updateUser(name, profileUrl);
    return response.user;
  }

}