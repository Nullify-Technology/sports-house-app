import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:match_cafe/blocs/rooms_bloc.dart';
import 'package:match_cafe/config/mediasoup/websocket/signaling.dart';
import 'package:match_cafe/models/response.dart';
import 'package:match_cafe/models/room.dart';
import 'package:match_cafe/models/user.dart';
import 'package:match_cafe/network/rest_client.dart';
import 'package:match_cafe/utils/constants.dart';

class RTCProvider with ChangeNotifier {
  AuthUser currentUser;
  DatabaseReference _databaseReference;
  Room _room;
  RoomsBloc _roomBloc;
  Room get room => _room;
  Signaling _signaling;

  bool get muted =>
      (currentUser == null || currentUser?.muted == null || currentUser.muted);

  bool get joined =>
      (currentUser != null && currentUser.joined != null && currentUser.joined);
  setMuted(muted) => currentUser.muted = muted;

  RTCProvider({this.currentUser}) {
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
    if (_room != null) {
      await this.leaveRoom(_room.id);
    }
    if (!(await internetConnectivity())) {
      throw Response.error("No network");
    }
    await _roomBloc.joinRoom(room.id);
    _signaling = new Signaling(kMediaServer)..connect(room.id);
    DatabaseReference roomRef = _databaseReference.child(room.id);
    _signaling.onStateChange = (SignalingState state) {
      switch (state) {
        case SignalingState.CallStateNew:
          break;
        case SignalingState.CallStateBye:
          break;
        case SignalingState.CallStateInvite:
          print("connection inviting");
          break;
        case SignalingState.CallStateConnected:
          print("connection connected");
          break;
        case SignalingState.CallStateRinging:
          print("connection ringing");
          break;
        case SignalingState.ConnectionClosed:
          print("connection closed");
          break;
        case SignalingState.ConnectionError:
          print("connection error");
          throw Response.error("unable to connect");
        case SignalingState.ConnectionOpen:
          _room = room;
          currentUser.muted = false;
          currentUser.joined = true;
          notifyListeners();
          roomRef.child(currentUser.id).set(currentUser.toJson());
          break;
      }
    };

    _signaling.onPeersUpdate = ((event) {});

    _signaling.onLocalStream = ((stream) {});

    _signaling.onAddRemoteStream = ((stream) {});

    _signaling.onRemoveRemoteStream = ((stream) {});

    _signaling.invite();
  }

  Future leaveRoom(String roomId) async {
    DatabaseReference roomRef = _databaseReference.child(room.id);
    _roomBloc.leaveRoom(room.id);
    _room = null;
    if (_signaling != null) {
      _signaling.bye();
      _signaling.close();
    }
    currentUser.joined = false;
    await roomRef.child(currentUser.id).remove();
    notifyListeners();
  }

  Future toggleMute(String roomId) async {
    DatabaseReference roomRef = _databaseReference.child(room.id);
    setMuted(!muted);
    roomRef.child(currentUser.id).update(currentUser.toJson());
    _signaling.mute(muted);
    print("status muted $muted");
    notifyListeners();
  }
}
