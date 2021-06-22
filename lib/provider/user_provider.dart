import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sports_house/models/auth.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/utils/constants.dart';

class UserProvider with ChangeNotifier {
  final flutterStorage = FlutterSecureStorage();
  final ImagePicker picker = ImagePicker();
  FirebaseStorage _storage = FirebaseStorage.instance;
  final RestClient client = RestClient.create();
  AuthUser _authUser;
  final FirebaseAuth auth;

  AuthUser get currentUser => _authUser;

  UserProvider(this.auth) {
    authenticateUser();
  }

  Future authenticateUser() async {
    if (auth.currentUser != null) {
      String idToken = await auth.currentUser?.getIdToken(false);
      String phoneNumber = auth.currentUser?.phoneNumber;
      _authUser = await getUser(idToken, phoneNumber);
      auth.idTokenChanges().listen((user) async {
        if (user != null &&
            user.refreshToken != null &&
            user.refreshToken.isNotEmpty) {
          String idToken = user.refreshToken;
          String phoneNumber = user.phoneNumber;
          _authUser = await getUser(idToken, phoneNumber);
        }
      });
    }
    notifyListeners();
  }

  Future<AuthUser> getUser(idToken, phoneNumber) async {
    try {
      Auth response = await client.getUser(phoneNumber, idToken);
      await flutterStorage.write(
          key: kAccessToken, value: response.accessToken);
      return response.user;
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserName({String name}) async {
    try {
      Auth response = await client.updateUser(name: name);
      _authUser = response.user;
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<void> updateProfilePicture(String userId, File image) async {
    try {
      TaskSnapshot snapshot =
          await _storage.ref("user_profiles/$userId.png").putFile(image);
      String url = (await snapshot.ref.getDownloadURL()).toString();
      Auth response = await client.updateUser(profileUrl: url);
      _authUser = response.user;
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }
  // Future<void> updateProfilePicture(String userId) async {
  //   try{
  //     final pickedFile = await picker.getImage(source: ImageSource.gallery);
  //     File image = File(pickedFile.path);
  //     TaskSnapshot snapshot = await _storage.ref("user_profiles/$userId.png").putFile(image);
  //     String url = (await snapshot.ref.getDownloadURL()).toString();
  //     Auth response = await client.updateUser(profileUrl: url);
  //     _authUser = response.user;
  //   }catch(e){
  //     print(e);
  //   }
  //   notifyListeners();
  // }

}
