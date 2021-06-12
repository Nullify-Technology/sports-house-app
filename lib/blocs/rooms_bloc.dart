import 'dart:async';

import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/api_response.dart';
import 'package:sports_house/models/response.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/network/rest_client.dart';

class RoomsBloc{

  final RestClient client;
  late StreamController<Response<List<Room>>> _roomsController;
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
      AgoraRoom response = await client.joinRoom(roomId);
      roomsSink.add(Response.completed(rooms));
      return response;
    }catch(e){
      roomsSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future leaveRoom(String roomId) async {
    try{
      await client.leaveRoom(roomId);
    }catch(e){
      print(e);
    }
  }

  dispose() {
    _roomsController.close();
  }
}