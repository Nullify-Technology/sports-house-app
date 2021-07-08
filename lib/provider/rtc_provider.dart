import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:match_cafe/blocs/rooms_bloc.dart';
import 'package:match_cafe/helper/pion_service_helper.dart';
import 'package:match_cafe/models/response.dart';
import 'package:match_cafe/models/room.dart';
import 'package:match_cafe/models/user.dart';
import 'package:match_cafe/network/rest_client.dart';
import 'package:match_cafe/utils/constants.dart';

class RTCProvider with ChangeNotifier {
  AuthUser _currentUser;
  DatabaseReference _databaseReference;
  Room _room;
  RoomsBloc _roomBloc;
  Room get room => _room;
  bool get muted => (_currentUser == null || _currentUser?.muted == null || _currentUser.muted);
  bool get joined => (_currentUser != null && _currentUser.joined != null && _currentUser.joined);
  setMuted(muted) => _currentUser.muted = muted;
  IONService _ionService;
  MethodChannel _channel = MethodChannel(kMethodChannel);
  RTCProvider({AuthUser currentUser}) {
    this._currentUser = currentUser;
    _roomBloc = RoomsBloc(client: RestClient.create());
    _databaseReference =
        FirebaseDatabase(databaseURL: kRTDBUrl).reference().child(kRTCRoom);
  }

  Future<bool> internetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  Future joinRTCRoom(Room room) async {
    if (!(await internetConnectivity())) {
      throw Response.error("No network");
    }
    if (_ionService != null) {
      await this.leaveRoom(_room.id);
    }
    await _roomBloc.joinRoom(room.id);
    _ionService = new IONService(kIonMediaServer);

    _ionService.onJoin = (streamId) async {
      await _channel.invokeMethod("startService", {"roomId": room.id,"userId": _currentUser.id,"roomName": room.name, "createdBy" : room.createdBy.name});
      print("local_streamId $streamId");
      _room = room;
      _currentUser.muted = true;
      _currentUser.joined = true;
      _currentUser.peerId = streamId;
      notifyListeners();
      _databaseReference.child(room.id).child(_currentUser.id).set(_currentUser.toJson());
    };

    _ionService.onSpeaker = (speakers){
      print("Speakers $speakers");
    };

    await _ionService.connect(roomId: room.id, userId: _currentUser.id);
  }

  Future leaveRoom(String roomId) async {
    _channel.invokeMethod("stopService");
    _ionService.closePeer();
    _ionService = null;
    DatabaseReference roomRef = _databaseReference.child(room.id);
    _roomBloc.leaveRoom(room.id);
    _room = null;
    _currentUser.joined = false;
    roomRef.child(_currentUser.id).remove();
    notifyListeners();
  }

  Future toggleMute(String roomId) async {
    DatabaseReference roomRef = _databaseReference.child(room.id);
    setMuted(!muted);
    await _ionService.toggleMute(muted);
    roomRef.child(_currentUser.id).update(_currentUser.toJson());
    print("status muted $muted");
    notifyListeners();
  }

  @override
  void dispose() {
    if(_ionService != null){
      _ionService.closePeer();
      DatabaseReference roomRef = _databaseReference.child(room.id);
      _roomBloc.leaveRoom(room.id);
      roomRef.child(_currentUser.id).remove();
      _ionService = null;
    }
    super.dispose();
  }
}
