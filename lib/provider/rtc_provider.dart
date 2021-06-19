

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_incall/flutter_incall.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/services/web_rtc_service.dart';
import 'package:sports_house/utils/constants.dart';

class RTCProvider with ChangeNotifier {

  AuthUser? currentUser;
  late DatabaseReference _databaseReference;
  final Map<String, WebRTCPeerConnection> _userConnections = new Map();
  late MediaStream _localStream;
  late Room _room;
  final IncallManager _incallManager = new IncallManager();

  Room get room => _room;
  String get userId => currentUser!.id;
  bool get muted => (currentUser == null || currentUser?.muted == null || currentUser!.muted!);
  setMuted(muted) => currentUser!.muted = muted;
  bool get joined => _userConnections.isNotEmpty;

  RTCProvider({this.currentUser}){
    _databaseReference = FirebaseDatabase(databaseURL: kRTDBUrl).reference().child(kRTCRoom);
  }

  Future joinRTCRoom(Room room) async {
    setMuted(true);
    _room = room;
    DatabaseReference roomRef = _databaseReference.child(room.id);
    await roomRef.child(userId).set(currentUser!.toJson());
    _localStream = await WebRTCPeerConnection.getUserMedia();
    _localStream.getAudioTracks()[0].enabled = !muted;
    _localStream.getAudioTracks()[0].enableSpeakerphone(true);

    roomRef.child(userId).child(kOffer).onChildAdded.listen((event){
      if(event.snapshot.value != null && event.snapshot.key != null){
        _createPeerConnection(userId,event.snapshot.key!,event.snapshot.value, roomRef);
      }
    });

    roomRef.child(userId).child(kAnswer).onChildAdded.listen((event) {
      if(event.snapshot.value!=null && event.snapshot.key !=null){
        if(_userConnections.containsKey(event.snapshot.key)){
          _userConnections[event.snapshot.key]!.setRemoteDescription(event.snapshot.value, DescriptionMode.answer);
        }
      }
    });

    roomRef.onChildRemoved.listen((event) {
      if(event.snapshot.key != null){
        _userConnections[event.snapshot.key]!.dispose(_localStream);
        _userConnections.removeWhere((key, value) => key == event.snapshot.key);
      }
    });

    roomRef.child(userId).child(kCandidates).onValue.listen((event){
      if(event.snapshot.value != null){
        Map<String, dynamic> candidates = new Map<String, dynamic>.from(event.snapshot.value);
        candidates.forEach((key, value) {
          if(_userConnections.containsKey(key)){
            Map<String, dynamic> candidate = new Map<String, dynamic>.from(value);
            candidate.values.forEach((candidate) {
              _userConnections[key]!.addCandidate(candidate);
            });
          }
        });
      }
    });

    DataSnapshot snapshot = await roomRef.once();
    Map<String, dynamic> rUsers = new Map<String, dynamic>.from(snapshot.value);
    rUsers.forEach((key, value) {
      if(!_userConnections.containsKey(key)){
        _createPeerConnection(userId, value, null, roomRef);
      }
    });

    notifyListeners();
  }

  Future _createPeerConnection(String userId,String rUserId,String? offerJson, DatabaseReference roomRef) async{
    final WebRTCPeerConnection connection = WebRTCPeerConnection();
    await connection.createPeer(_localStream);

    connection.onAddStream((stream) {
      print('addStream: ' + stream.id);
    });

    connection.onIceCandidate((candidate) {
      roomRef.child(rUserId).child(kCandidates).child(userId).push().set(candidate);
      print(candidate);
    });

    connection.onIceConnectionState((e) {
      print(e);
    });

    if(offerJson == null){
      String offer = await connection.createOffer();
      roomRef.child(rUserId).child(kOffer).child(userId).set(offer);
    }else{
      String answer = await connection.createAnswer(offerJson);
      roomRef.child(rUserId).child(kAnswer).child(userId).set(answer);
    }
    _userConnections[rUserId] = connection;
    _incallManager.setSpeakerphoneOn(true);
    notifyListeners();
  }

  Future leaveRoom(String roomId) async{
    DatabaseReference roomRef = _databaseReference.child(roomId);
    await roomRef.child(userId).remove();
    for(WebRTCPeerConnection connection in _userConnections.values){
      await connection.dispose(_localStream);
    }
    await _localStream.dispose();
    _userConnections.clear();
    notifyListeners();
  }

  Future toggleMute(String roomId) async {
    setMuted(!muted);
    notifyListeners();
    await _databaseReference.child(roomId).child(userId).update(currentUser!.toJson());
    // incallManager.setMicrophoneMute(muted);
   _localStream.getAudioTracks()[0].enabled = !muted;
    print("status muted $muted");
  }


  @override
  void dispose() {
    super.dispose();
  }
}
