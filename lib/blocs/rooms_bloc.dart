import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:agora_rtc_engine/rtc_channel.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/auth.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/models/api_response.dart';
import 'package:sports_house/models/response.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/utils/constants.dart';

class RoomsBloc{

  final RestClient client;
  late StreamController<Response<List<Room>>> _roomsController;
  late RtcEngine engine;
  late List<Room> rooms;
  StreamSink<Response<List<Room>>> get roomsSink =>
      _roomsController.sink;

  Stream<Response<List<Room>>> get roomsStream =>
      _roomsController.stream;


  RoomsBloc({required this.client}){
    this._roomsController = StreamController<Response<List<Room>>>.broadcast();
  }

  Future getRooms(fixtureId) async {
    roomsSink.add(Response.loading('Getting fixtures Details'));
    try{
      ApiResponse<Room> response = await client.getRooms(fixtureId);
      rooms = response.results;
      roomsSink.add(Response.completed(rooms));
    }catch(e){
      roomsSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<AgoraRoom?> createRoom(fixtureId, userId, name) async {
    roomsSink.add(Response.loading('Getting fixtures Details'));
    try{
      engine = await RtcEngine.create(kAgoraAppId);
      AgoraRoom response = await client.createRoom(fixtureId, "0", name);
      roomsSink.add(Response.completed([response.room]));
      return response;
    }catch(e){
      roomsSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<AgoraRoom?> joinRoom(String roomId) async {
    roomsSink.add(Response.loading('Getting fixtures Details'));
    try{
      // AgoraRoom response = await client.(fixtureId, userId, name);
      roomsSink.add(Response.completed(rooms));
      // return response;
    }catch(e){
      roomsSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  // Future joinChannel(String token, String channel, String userId) async {
  //   engine = await RtcEngine.create(kAgoraAppId);
  //   await engine.registerLocalUserAccount(kAgoraAppId, userId);
  //   await engine.disableVideo();
  //   await engine.enableAudio();
  //   await engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
  //   await engine.setClientRole(ClientRole.Broadcaster);
  //   await engine.joinChannelWithUserAccount(token, channel, userId);
  // }

  dispose() {
    engine.destroy();
    _roomsController.close();
  }
}