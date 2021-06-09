import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sports_house/models/auth.dart';
import 'package:sports_house/models/response.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/utils/constants.dart';

class UserBloc{

  final FirebaseAuth auth = FirebaseAuth.instance;
  final RestClient client;
  late StreamController<Response<AuthUser>> _userController;
  final flutterStorage = FlutterSecureStorage();
  final ImagePicker picker = ImagePicker();
  FirebaseStorage _storage = FirebaseStorage.instance;

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
      await flutterStorage.write(key: kAccessToken, value: response.accessToken);
      await flutterStorage.write(key: kUser, value: jsonEncode(response.user));
      userSink.add(Response.completed(response.user!));
    }catch(e){
      userSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<void> updateUserName({String? name}) async {
    userSink.add(Response.loading('Updating User name'));
    try{
      Auth response = await client.updateUser(name: name);
      await flutterStorage.write(key: kUser, value: jsonEncode(response.user));
      userSink.add(Response.completed(response.user!));
    }catch(e){
      userSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<void> updateProfilePicture(String userId) async {
    userSink.add(Response.loading('Updating User profile picture'));
    try{
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      File image = File(pickedFile!.path);
      TaskSnapshot snapshot = await _storage.ref("user_profiles/$userId.png").putFile(image);
      String url = (await snapshot.ref.getDownloadURL()).toString();
      Auth response = await client.updateUser(profileUrl: url);
      await flutterStorage.write(key: kUser, value: jsonEncode(response.user));
      userSink.add(Response.completed(response.user!));
    }catch(e){
      userSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<void> getUserProfileImage() async {
      userSink.add(Response.loading('Getting User image'));
      String? user = await flutterStorage.read(key: kUser);
      if(user == null){
        getUser();
      }else{
        userSink.add(Response.completed(AuthUser.fromJson(jsonDecode(user))));
      }
  }

  dispose() {
    _userController.close();
  }
}