import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';

enum DescriptionMode{
  offer, answer
}

class WebRTCPeerConnection {
  late RTCPeerConnection _peerConnection;
  RTCPeerConnection get peer => _peerConnection;

  static Future getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': {
        "echoCancellation" : true,
        "autoGainControl" : true,
        "noiseSuppression" : true,
        "googEchoCancellation" : true,
        "googDAEchoCancellation" : true,
        "googAutoGainControl" : true,
        "googAutoGainControl2" : true,
        "googNoiseSuppression" : true,
        "googNoiseSuppression2" : true,
        "googAudioMirroring" : false,
        "googHighpassFilter" : true
      },
      'video': false,
    };
    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    return stream;
  }

  Future createPeer(MediaStream localStream) async {

    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": false,
        "googEchoCancellation" : true,
        "googDAEchoCancellation" : true,
        "googAutoGainControl" : true,
        "googAutoGainControl2" : true,
        "googNoiseSuppression" : true,
        "googNoiseSuppression2" : true,
        "googAudioMirroring" : false,
        "googHighpassFilter" : true
      },
      "optional": [],
    };

    _peerConnection = await createPeerConnection(configuration, offerSdpConstraints);
    await _peerConnection.addStream(localStream);
  }

  onIceCandidate(Function callback){
    _peerConnection.onIceCandidate = (e) {
      if (e.candidate != null) {
        callback(json.encode({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMlineIndex,
        }));
      }
    };
  }

  onIceConnectionState(Function callback){
    _peerConnection.onIceConnectionState = (e) {
      callback(e);
    };
  }

  onAddStream(Function callback){
    _peerConnection.onAddStream = (stream) {
      callback(stream);
    };
  }

  Future<String> createOffer() async {
    RTCSessionDescription description = await _peerConnection.createOffer();
    var session = parse(description.sdp!);
    await _peerConnection.setLocalDescription(description);
    return json.encode(session);
  }

  Future<String> createAnswer(String offer) async {
    await this.setRemoteDescription(offer, DescriptionMode.offer);
    RTCSessionDescription description = await _peerConnection.createAnswer();
    var session = parse(description.sdp!);
    await _peerConnection.setLocalDescription(description);
    return json.encode(session);
  }

  Future setRemoteDescription(String jsonString, DescriptionMode mode) async {
    dynamic session = await jsonDecode('$jsonString');
    String sdp = write(session, null);
    RTCSessionDescription description = new RTCSessionDescription(sdp, describeEnum(mode));
    await _peerConnection.setRemoteDescription(description);
  }

  Future addCandidate(String jsonString) async {
    dynamic session = await jsonDecode('$jsonString');
    dynamic candidate = new RTCIceCandidate(session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await _peerConnection.addCandidate(candidate);
  }

  dispose(MediaStream stream) async {
    await _peerConnection.removeStream(stream);
    await _peerConnection.close();
    await _peerConnection.dispose();
  }

}