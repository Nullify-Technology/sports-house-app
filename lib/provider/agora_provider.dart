import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:sports_house/blocs/rooms_bloc.dart';
import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/utils/constants.dart';

class AgoraProvider with ChangeNotifier {
  RtcEngine? _engine;
  List<AuthUser> roomUsers = [];
  late DatabaseReference _rtDbReference;
  late RoomsBloc _roomsBloc;
  bool muted = false;
  bool isJoined = false;
  late AuthUser? currentUser;
  AgoraRoom? room;

  AgoraProvider({this.currentUser}) {
    _roomsBloc = RoomsBloc(client: RestClient.create());
    _rtDbReference =
        FirebaseDatabase(databaseURL: kRTDBUrl).reference().child("rooms");
  }

  Future joinAgoraRoom(String token, AgoraRoom room) async {
    _engine = await RtcEngine.create(kAgoraAppId);
    await _engine?.disableVideo();
    await _engine?.enableAudio();
    await _engine?.setChannelProfile(ChannelProfile.Game);
    await _engine?.setDefaultAudioRoutetoSpeakerphone(true);
    await _engine?.registerLocalUserAccount(kAgoraAppId, currentUser!.id);
    await _engine?.adjustRecordingSignalVolume(130);
    await _engine?.adjustPlaybackSignalVolume(130);
    muted = true;
    this.room = room;
    addEventHandlers(token, room.room.id);
    addFireBaseStorageHandler(room.room.id);
    notifyListeners();
  }

  Future leaveRoom(String roomId) async {
    isJoined = false;
    notifyListeners();
    await _engine?.leaveChannel();
    await _rtDbReference.child("rooms_$roomId").child(currentUser!.id).remove();
    await _roomsBloc.leaveRoom(roomId);
  }

  Future toggleMute() async {
    muted = !muted;
    currentUser!.muted = muted;
    await _rtDbReference
        .child("rooms_${room!.room.id}").child(currentUser!.id).set(currentUser!.toJson());
    await _engine?.muteLocalAudioStream(muted);
    notifyListeners();
  }

  void addEventHandlers(token, channelName) {
    _engine?.setEventHandler(RtcEngineEventHandler(error: (code) {

      print("join failed $code");
    }, joinChannelSuccess: (channel, uid, elapsed) async {
      await _engine?.muteLocalAudioStream(true);
      _rtDbReference
          .child("rooms_$channelName")
          .child(currentUser!.id)
          .set(currentUser!.toJson());
      isJoined = true;
      notifyListeners();
    }, localUserRegistered: (uid, userAccount) async {
      await _engine?.joinChannelWithUserAccount(token, channelName, userAccount);
    }));
  }

  void addFireBaseStorageHandler(String channelName) {
    _rtDbReference.child("rooms_$channelName").onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<String, dynamic> users =
            new Map<String, dynamic>.from(event.snapshot.value);
        roomUsers = users.values
            .map((user) =>
                AuthUser.fromJson(new Map<String, dynamic>.from(user)))
            .toList();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (room != null && isJoined) {
      _roomsBloc.leaveRoom(room!.room.id);
      _rtDbReference.child(currentUser!.id).remove();
    }
    _engine?.destroy();
    _roomsBloc.dispose();
  }
}
