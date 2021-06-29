import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:match_cafe/config/mediasoup/mediasoup_client/transport.dart';
import 'ortc.dart';
import 'sdp_utils.dart';

part 'device.g.dart';

@JsonSerializable(nullable: false)
class Device {
  String flag;
  String name;
  String version;

  Map _extendedRtpCapabilities;
  Map _recvRtpCapabilities;
  Map _sendingRemoteRtpParametersByKind = Map();

  Map<String, dynamic> config = {
    'iceServers'         : [{"url": "stun:stun.l.google.com:19302"},],
    'iceTransportPolicy' : 'all',
    'bundlePolicy'       : 'max-bundle',
    'rtcpMuxPolicy'      : 'require',
    'sdpSemantics'       : 'plan-b',
    'startAudioSession'  : false
  };

  final Map<String, dynamic> constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [
      {'`DtlsSrtpKeyAgreement`': true},
    ],
  };

  toMap() => _$DeviceToJson(this);

  get rtpCapabilities => _recvRtpCapabilities;

  getNativeRtpCapabilities() async {
    RTCPeerConnection pc = await createPeerConnection(config, constraints);

    RTCSessionDescription offer = await pc.createOffer(constraints);    
    await pc.close();
    pc.dispose();

    Map sdpObject = parse(offer.sdp);
    return extractRtpCapabilities(sdpObject);
  }

  load(Map routerRtpCapabilities) async {
    Map nativeRtpCapabilities = await getNativeRtpCapabilities();

    _extendedRtpCapabilities = getExtendedRtpCapabilities(nativeRtpCapabilities, routerRtpCapabilities);

    _sendingRemoteRtpParametersByKind["video"] = getSendingRemoteRtpParameters("video", _extendedRtpCapabilities);
    _sendingRemoteRtpParametersByKind["audio"] = getSendingRemoteRtpParameters("audio", _extendedRtpCapabilities);

    _recvRtpCapabilities = getRecvRtpCapabilities(_extendedRtpCapabilities);
  }

  sendingRemoteRtpParameters(String kind) => _sendingRemoteRtpParametersByKind[kind];

  createSendTransport(peerId, {
    id,
    iceParameters,
    iceCandidates,
    dtlsParameters,
    sctpParameters,
    startAudioSession = true
  }) async {
    return _createTransport("send", peerId,
      id: id,
      iceParameters: iceParameters,
      iceCandidates: iceCandidates,
      dtlsParameters: dtlsParameters,
      sctpParameters: sctpParameters);
  }

  createRecvTransport(peerId, {
    id,
    iceParameters,
    iceCandidates,
    dtlsParameters,
    sctpParameters,
  }) async {
    return _createTransport("recv", peerId,
      id: id,
      iceParameters: iceParameters,
      iceCandidates: iceCandidates,
      dtlsParameters: dtlsParameters,
      sctpParameters: sctpParameters);
  }

  _createTransport(direction, peerId, {
    id,
    iceParameters,
    iceCandidates,
    dtlsParameters,
    sctpParameters,
    startAudioSession = false
  }) {
    return Transport.fromMap({
      "id": id,
      "iceParameters": iceParameters,
      "iceCandidates": iceCandidates,
      "dtlsParameters": dtlsParameters,
      "sctpParameters": sctpParameters,
      "direction": direction,
      "startAudioSession": startAudioSession
    });
  
  }
  
  static fromJson(Map json) => _$DeviceFromJson(json);
}