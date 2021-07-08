import 'package:flutter_ion/flutter_ion.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
class IONService {
  Function(String streamId) onJoin;
  Function(Map<String, dynamic> speakers) onSpeaker;
  Signal signal;
  Client client;
  String _localSteamId;
  LocalStream _localStream;
  RemoteStream _remoteStream;
  Constraints get _defaultConstraints => Constraints.defaults
    ..simulcast = false
    ..audio = true
    ..video = false;
  IONService(String sfuUrl){
    signal = GRPCWebSignal(sfuUrl);
  }

  Future connect({String roomId, String userId}) async{
    try{
      if(client == null){
        // _clientPub = await Client.create(sid: roomId, uid: userId, signal: _signalLocal);
        // await _clientPub.publish(_localStream);

        client = await Client.create(sid: roomId, uid: userId, signal: signal);
        client.ontrack = (track, RemoteStream stream){
          _remoteStream = stream;
        };
        client.onspeaker = (Map<String, dynamic> speakers) {
          if(speakers != null){
            onSpeaker?.call(speakers);
          }
        };



        _localStream = await LocalStream.getUserMedia(
            constraints: _defaultConstraints);
        List<MediaDeviceInfo> mediaDevices = await navigator.mediaDevices.enumerateDevices();
        mediaDevices.forEach((element) {
          print("media device ${element.label}, ${element.kind}, ${element.deviceId}, ${element.groupId}");
        });
        await client.publish(_localStream);

        _localStream.stream.getAudioTracks()[0].enabled = false;
        onJoin?.call(_localStream.stream.id);
      }
    }catch(e){
      throw e;
    }
  }

  Future toggleMute(muted) async{
    if(_localStream != null){
      _localStream.stream.getAudioTracks()[0].enabled = !muted;
    }
  }

  closePeer() async {
    if(client != null){
      if(_remoteStream != null) _remoteStream.stream.dispose();
      _localStream.stream.dispose();
      client.close();
    }
  }


}