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
  AuthUser? _currentUser;
  late DatabaseReference _databaseReference;
  Room? _room;
  late RoomsBloc _roomBloc;

  late StreamController<List<String>> _roomsController;
  StreamSink<List<String>> get roomsSink => _roomsController.sink;
  Stream<List<String>> get roomsStream => _roomsController.stream;

  Room? get room => _room;
  bool get muted => (_currentUser == null || _currentUser!.muted == null || _currentUser!.muted!);
  bool get joined => (_currentUser != null && _currentUser!.joined != null && _currentUser!.joined!);
  bool get isSpeaker => (_currentUser != null && _currentUser!.joined != null && _currentUser!.isSpeaker!);
  setMuted(muted) => _currentUser!.muted = muted;
  IONService? _ionService;
  MethodChannel _channel = MethodChannel(kMethodChannel);


  RTCProvider({AuthUser? currentUser}) {
    this._currentUser = currentUser;
    _roomBloc = RoomsBloc(client: RestClient.create());
    _databaseReference = FirebaseDatabase(databaseURL: kRTDBUrl).reference().child(kRTCRoom);
    this._roomsController = StreamController<List<String>>.broadcast();
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
      await this.leaveRoom(_room!.id!);
    }
    await _roomBloc.joinRoom(room.id!);
    _ionService = new IONService(kIonMediaServer);

    _ionService!.onJoin = (streamId) async {
      print("local_streamId $streamId");
      _room = room;
      _currentUser!.muted = true;
      _currentUser!.joined = true;
      _currentUser!.peerId = streamId;
      if(_room!.createdBy!.id == _currentUser!.id){
        _currentUser!.isModerator = true;
        _currentUser!.isSpeaker = true;
        _databaseReference.child(room.id!).child(kDBSpeaker).child(_currentUser!.id!).set(_currentUser!.toJson());
        await _channel.invokeMethod("startService", {"roomId": room.id,"userId": _currentUser!.id,"roomName": room.name, "createdBy" : room.createdBy!.name, "userType": kDBSpeaker});
      }else{
        _currentUser!.isModerator = false;
        _currentUser!.isSpeaker = false;
        _databaseReference.child(room.id!).child(kDBAudience).child(_currentUser!.id!).set(_currentUser!.toJson());
        await _channel.invokeMethod("startService", {"roomId": room.id,"userId": _currentUser!.id,"roomName": room.name, "createdBy" : room.createdBy!.name, "userType": kDBAudience});
      }

      _databaseReference.child(room.id!).child(kDBSpeaker).onChildAdded.listen((event) {
        if(event.snapshot.key != null){
          if(event.snapshot.key == _currentUser!.id){
            _currentUser!.isSpeaker = true;
            _databaseReference.child(room.id!).child(kDBSpeaker).child(_currentUser!.id!).child("isModerator").onValue.listen((event) {
              if(event.snapshot.value != null){
                _currentUser!.isModerator = event.snapshot.value;
              }
            });
            notifyListeners();
          }
        }
      });

      _databaseReference.child(room.id!).child(kDBAudience).onChildAdded.listen((event) {
        if(event.snapshot.key != null){
          if(event.snapshot.key == _currentUser!.id){
            _currentUser!.isSpeaker = false;
            _currentUser!.isModerator = false;
            setMuted(true);
            _ionService!.toggleMute(muted);
            notifyListeners();
          }
        }
      });

      notifyListeners();
      roomsSink.add([]);
    };

    _ionService!.onSpeaker = (speakers){
      if(speakers["method"] == "audioLevels"){
        roomsSink.add(List<String>.from(speakers["params"] as List));
      }
    };

    await _ionService!.connect(roomId: room.id!, userId: _currentUser!.id!);
  }

  Future promoteToSpeaker(AuthUser user) async {
    user.isSpeaker = true;
    user.muted = true;
    await _databaseReference.child(room!.id!).child(kDBAudience).child(user.id!).remove();
    await _databaseReference.child(room!.id!).child(kDBSpeaker).child(user.id!).set(user.toJson());
  }

  Future demoteToListener(AuthUser user) async {
    user.isSpeaker = false;
    user.isModerator = false;
    await _databaseReference.child(room!.id!).child(kDBSpeaker).child(user.id!).remove();
    await _databaseReference.child(room!.id!).child(kDBAudience).child(user.id!).set(user.toJson());
  }

  Future promoToModerator(AuthUser user) async {
    user.isModerator = true;
    user.isSpeaker = true;
    await _databaseReference.child(room!.id!).child(kDBSpeaker).child(user.id!).set(user.toJson());
  }

  Future leaveRoom(String roomId) async {
    _channel.invokeMethod("stopService");
    _ionService!.closePeer();
    _ionService = null;
    DatabaseReference roomRef = _databaseReference.child(room!.id!);
    if(_currentUser!.isSpeaker!){
      roomRef = roomRef.child(kDBSpeaker);
    }else{
      roomRef = roomRef.child(kDBAudience);
    }
    _roomBloc.leaveRoom(room!.id!);
    _room = null;
    _currentUser!.joined = false;
    roomRef.child(_currentUser!.id!).remove();
    notifyListeners();
  }

  Future toggleMute(String roomId) async {
    if(_currentUser!.isSpeaker!){
      DatabaseReference roomRef = _databaseReference.child(room!.id!).child(kDBSpeaker);
      setMuted(!muted);
      await _ionService!.toggleMute(muted);
      roomRef.child(_currentUser!.id!).update(_currentUser!.toJson());
      print("status muted $muted");
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if(_ionService != null){
      _ionService!.closePeer();
      DatabaseReference roomRef = _databaseReference.child(room!.id!);
      _roomBloc.leaveRoom(room!.id!);
      roomRef.child(_currentUser!.id!).remove();
      _ionService = null;
    }
    _roomsController.close();
    super.dispose();
  }
}
