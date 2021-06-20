import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_incall/flutter_incall.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/services/web_rtc_service.dart';
import 'package:sports_house/utils/constants.dart';

class RTCProvider with ChangeNotifier {
  AuthUser? currentUser;
  late DatabaseReference _databaseReference;
  final Map<String, RTCPeerConnection> _userConnections = new Map();
  MediaStream? _localStream;
  late Room _room;
  final IncallManager _incallManager = new IncallManager();

  Room get room => _room;

  String get userId => currentUser!.id;

  bool get muted => (currentUser == null ||
      currentUser?.muted == null ||
      currentUser!.muted!);

  setMuted(muted) => currentUser!.muted = muted;

  bool get joined => (currentUser != null &&
      currentUser?.joined != null &&
      currentUser!.joined!);
  List<StreamSubscription<Event>> listeners = [];

  RTCProvider({this.currentUser}) {
    _databaseReference =
        FirebaseDatabase(databaseURL: kRTDBUrl).reference().child(kRTCRoom);
  }

  Future joinRTCRoom(Room room) async {
    if (_userConnections.isEmpty) {
      setMuted(true);
      _room = room;
      DatabaseReference roomRef = _databaseReference.child(room.id);
      _localStream = await WebRTCPeerConnection.getUserMedia();
      _localStream!.getAudioTracks()[0].enabled = !muted;
      _localStream!.getAudioTracks()[0].enableSpeakerphone(true);

      listeners.add(roomRef.child(userId).child(kOffer).onValue.listen((event) {
        if (event.snapshot.value != null) {
          Map<String, dynamic> offers =
              new Map<String, dynamic>.from(event.snapshot.value);
          offers.forEach((key, value) {
            print("got offer $value from $key");
            _createPeerConnection(userId, key, value, roomRef);
          });
        }
      }));

      listeners.add(roomRef.onChildRemoved.listen((event) async {
        if(_userConnections.containsKey(event.snapshot.key)){
          RTCPeerConnection? pc = _userConnections[event.snapshot.key];
          if(pc != null){
            try{
              await pc.removeStream(_localStream!);
              await pc.close();
              await pc.dispose();
              _userConnections.remove(event.snapshot.key);
            }catch(e){
              print("error while terminating connection");
            }
          }
        }
      }));


      DataSnapshot snapshot = await roomRef.once();
      if (snapshot.value != null) {
        Map<String, dynamic> rUsers =
            new Map<String, dynamic>.from(snapshot.value);
        rUsers.forEach((key, value) {
          if (!_userConnections.containsKey(key) && key != userId) {
            print("creating peer for $key");
            _createPeerConnection(userId, key, null, roomRef);
          }
        });
      }

      await roomRef.child(userId).set(currentUser!.toJson());
      currentUser!.joined = true;
      notifyListeners();
    }
  }

  Future _createPeerConnection(String userId, String rUserId, String? offerJson,
      DatabaseReference roomRef) async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": 'stun:numb.viagenie.ca'},
        {"url": "stun:stun.l.google.com:19302"},
        {"url":'stun:stun1.l.google.com:19302'},
        {"url":'stun:stun2.l.google.com:19302'},
        {"url":'stun:stun3.l.google.com:19302'},
        {"url":'stun:stun4.l.google.com:19302'},
        {"url": "turn:numb.viagenie.ca", "username": 'giranir264@moxkid.com', "credentials": 'appu@025'}
      ]
    };
    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": false,
      },
      "optional": [],
    };

    RTCPeerConnection _peerConnection =
        await createPeerConnection(configuration, offerSdpConstraints);
    await _peerConnection.addStream(_localStream!);

    listeners.add(roomRef.child(userId).child(kCandidates).child(rUserId).onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<String, dynamic> rUsers =
            new Map<String, dynamic>.from(event.snapshot.value);
        rUsers.forEach((key, value) async {
          print("adding candidates of remote user $value");
          dynamic session = await jsonDecode('$value');
          dynamic candidate = new RTCIceCandidate(session['candidate'],
              session['sdpMid'], session['sdpMlineIndex']);
          await _peerConnection.addCandidate(candidate);
        });
      }
    }));

    _peerConnection.onIceCandidate = (e) {
      if (e.candidate != null) {
        print("adding candidates for remote user ${e.candidate.toString()}");
        roomRef.child(rUserId).child(kCandidates).child(userId).push().set(json.encode({
              'candidate': e.candidate.toString(),
              'sdpMid': e.sdpMid.toString(),
              'sdpMlineIndex': e.sdpMlineIndex,
            }));
      }
    };

    _peerConnection.onConnectionState = (e) async {
      print(e);
      if (e == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        var stat = await _peerConnection.getStats();
        for (StatsReport value in stat) {
          print("connection stats $value");
        }
      }
    };
    _peerConnection.onIceConnectionState = (e) {
      print(e);
    };

    if (offerJson == null) {
      RTCSessionDescription description = await _peerConnection.createOffer();
      var session = parse(description.sdp!);
      await _peerConnection.setLocalDescription(description);
      String offer = json.encode(session);
      print("offer created $offer");
      roomRef.child(rUserId).child(kOffer).child(userId).set(offer);
      listeners.add(roomRef.child(userId).child(kAnswer).child(rUserId).onValue.listen((event) async {
        if (event.snapshot.value != null) {
          print("got the answer ${event.snapshot.value}");
          dynamic offerSession = await jsonDecode('${event.snapshot.value}');
          String sdp = write(offerSession, null);
          RTCSessionDescription offerDescription =
              new RTCSessionDescription(sdp, "answer");
          await _peerConnection.setRemoteDescription(offerDescription);
        }
      }));
    } else {
      dynamic offerSession = await jsonDecode('$offerJson');
      String sdp = write(offerSession, null);
      RTCSessionDescription offerDescription =
          new RTCSessionDescription(sdp, "offer");
      await _peerConnection.setRemoteDescription(offerDescription);

      RTCSessionDescription description = await _peerConnection.createAnswer();
      var session = parse(description.sdp!);
      await _peerConnection.setLocalDescription(description);
      String answer = json.encode(session);
      print("answer created $answer");
      roomRef.child(rUserId).child(kAnswer).child(userId).set(answer);
    }

    _userConnections[rUserId] = _peerConnection;
    _incallManager.setSpeakerphoneOn(true);
    notifyListeners();
  }

  Future leaveRoom(String roomId) async {
    try{
      await _localStream!.dispose();
      listeners.forEach((element) {
        element.cancel();
      });
      _userConnections.values.forEach((element) {
        element.close();
        element.dispose();
      });
    }catch(e){
      print(e);
    }
    DatabaseReference roomRef = _databaseReference.child(roomId);
    _userConnections.clear();
    currentUser!.joined = false;
    notifyListeners();
    await roomRef.child(userId).remove();
  }

  Future toggleMute(String roomId) async {
    setMuted(!muted);
    notifyListeners();
    await _databaseReference
        .child(roomId)
        .child(userId)
        .update(currentUser!.toJson());
    _localStream!.getAudioTracks()[0].enabled = !muted;
    print("status muted $muted");
  }

  @override
  void dispose() {
    if (_localStream != null) _localStream!.dispose();
    super.dispose();
  }
}
