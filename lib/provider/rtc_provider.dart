

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/services/web_rtc_service.dart';
import 'package:sports_house/utils/constants.dart';

class RTCProvider with ChangeNotifier {

  AuthUser? currentUser;
  late DatabaseReference _databaseReference;
  final Map<String, WebRTCPeerConnection> _userConnections = new Map();
  late MediaStream _localStream;
  bool get muted => (currentUser == null || currentUser?.muted == null || currentUser!.muted!);
  String get userId => currentUser!.id;

  late StreamSubscription<Event> _offerListener;
  late StreamSubscription<Event> _answerListener;
  late StreamSubscription<Event> _candidateListener;

  RTCProvider({this.currentUser}){
    _databaseReference = FirebaseDatabase(databaseURL: kRTDBUrl).reference().child(kRTCRoom);
  }

  Future joinRTCRoom(String roomId) async {
    DatabaseReference roomRef = _databaseReference.child(roomId);
    await roomRef.child(userId).set(currentUser!.toJson());
    _localStream = await WebRTCPeerConnection.getUserMedia();
    _localStream.getAudioTracks()[0].enabled = !muted;
    _offerListener = roomRef.child(userId).child(kOffer).onChildAdded.listen((event){
      if(event.snapshot.value != null && event.snapshot.key != null){
        _createPeerConnection(userId,event.snapshot.key!,event.snapshot.value, roomRef);
      }
    });

    _answerListener = roomRef.child(userId).child("answer").onChildAdded.listen((event) {
      if(event.snapshot.value!=null && event.snapshot.key !=null){
        if(_userConnections.containsKey(event.snapshot.key)){
          _userConnections[event.snapshot.key]!.setRemoteDescription(event.snapshot.value, DescriptionMode.answer);
        }
      }
    });

    _candidateListener = roomRef.child(userId).child("candidates").onChildAdded.listen((event){
      if(event.snapshot.value != null && event.snapshot.key != null){
        if(_userConnections.containsKey(event.snapshot.key)){
          Map<String, dynamic> candidates = new Map<String, dynamic>.from(event.snapshot.value);
          candidates.values.forEach((candidate) {
            _userConnections[event.snapshot.key]!.addCandidate(candidate);
          });
        }
      }
    });

    roomRef.once().then((value){
      Map<String, dynamic> rUsers = new Map<String, dynamic>.from(value.value);
      rUsers.keys.forEach((element) {
        if(element != userId){
          _createPeerConnection(userId, element, null, roomRef);
        }
      });
    });

  }

  Future _createPeerConnection(String userId,String rUserId,String? offerJson, DatabaseReference roomRef) async{
    final WebRTCPeerConnection connection = WebRTCPeerConnection();
    await connection.createPeer(_localStream);

    connection.onAddStream((stream) {
      print('addStream: ' + stream.id);
    });

    connection.onIceCandidate((candidate) {
      roomRef.child(rUserId).child("candidates").child(userId).push().set(candidate);
      print(candidate);
    });

    connection.onIceConnectionState((e) {
      print(e);
    });

    if(offerJson == null){
      String offer = await connection.createOffer();
      roomRef.child(rUserId).child("offer").child(userId).set(offer);
    }else{
      String answer = await connection.createAnswer(offerJson);
      roomRef.child(rUserId).child("answer").child(userId).set(answer);
    }
    _userConnections[rUserId] = connection;
    notifyListeners();
  }

  Future leaveRoom(String roomId) async{
    DatabaseReference roomRef = _databaseReference.child(roomId);
    await _offerListener.cancel();
    await _answerListener.cancel();
    await _candidateListener.cancel();
    await roomRef.child(userId).remove();
    for(WebRTCPeerConnection connection in _userConnections.values){
      await connection.dispose(_localStream);
    }
    await _localStream.dispose();
    _userConnections.clear();
  }

  Future toggleMute() async {
    currentUser!.muted = !muted;
   _localStream.getAudioTracks()[0].enabled = !muted;
    print("status muted $muted");
  }


  @override
  void dispose() {
    super.dispose();
  }
}
