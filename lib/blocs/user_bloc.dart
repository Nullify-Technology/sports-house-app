import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sports_house/models/auth.dart';
import 'package:sports_house/models/response.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/utils/constants.dart';

class UserBloc{

  final FirebaseAuth auth = FirebaseAuth.instance;
  final RestClient client;
  late StreamController<Response<AuthUser>> _userController;
  final storage = FlutterSecureStorage();
  StreamSink<Response<AuthUser>> get userSink =>
      _userController.sink;

  Stream<Response<AuthUser>> get userStream =>
      _userController.stream;


  UserBloc({required this.client}){
    this._userController = StreamController<Response<AuthUser>>();
  }

  void getUser() async {
    String idToken = await auth.currentUser?.getIdToken(false) as String;
    String phoneNumber = auth.currentUser?.phoneNumber as String;
    userSink.add(Response.loading('Getting User Details'));
    try{
      Auth response = await client.getUser(phoneNumber, idToken);
      await storage.write(key: ACCESS_TOKEN, value: response.accessToken);
      userSink.add(Response.completed(response.user!));
    }catch(e){
      userSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<Auth> updateUser({String? name, String? profilePictureUrl}) async {
    userSink.add(Response.loading('Updating User Details'));
    Auth response = new Auth();
    try{
      Auth response = await client.updateUser(name: name, profileUrl: profilePictureUrl);
      userSink.add(Response.completed(response.user!));
    }catch(e){
      userSink.add(Response.error(e.toString()));
      print(e);
    }

    return response;
  }

  dispose() {
    _userController.close();
  }
}