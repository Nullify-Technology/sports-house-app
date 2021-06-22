import 'dart:async';

import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/api_response.dart';
import 'package:sports_house/models/response.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/network/rest_client.dart';

class RoomsBloc {
  final RestClient client;
   StreamController<Response<List<Room>>> _roomsController;
   List<Room> rooms;
  StreamSink<Response<List<Room>>> get roomsSink => _roomsController.sink;

  Stream<Response<List<Room>>> get roomsStream => _roomsController.stream;

  RoomsBloc({this.client}) {
    this._roomsController = StreamController<Response<List<Room>>>.broadcast();
  }

  Future getRooms(fixtureId) async {
    roomsSink.add(Response.loading('Getting fixtures Details'));
    try {
      ApiResponse<Room> response = await client.getRooms(fixtureId);
      rooms = response.results;
      roomsSink.add(Response.completed(rooms));
    } catch (e) {
      roomsSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future getTrendingRooms() async {
    roomsSink.add(Response.loading('Getting trending rooms'));
    try {
      ApiResponse<Room> response = await client.getTrendingRooms();
      rooms = response.results;
      roomsSink.add(Response.completed(rooms));
    } catch (e) {
      roomsSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<AgoraRoom> createRoom(fixtureId, userId, name) async {
    try {
      AgoraRoom response = await client.createRoom(fixtureId, "0", name);
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future<AgoraRoom> joinRoom(String roomId) async {
    try {
      AgoraRoom response = await client.joinRoom(roomId);
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future leaveRoom(String roomId) async {
    try {
      await client.leaveRoom(roomId);
    } catch (e) {
      print(e);
    }
  }

  dispose() {
    _roomsController.close();
  }
}
