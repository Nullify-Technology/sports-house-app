import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sports_house/blocs/rooms_bloc.dart';
import 'package:sports_house/models/room.dart';
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
  Room? room;

  AgoraProvider({this.currentUser}) {
    _roomsBloc = RoomsBloc(client: RestClient.create());
    _rtDbReference =
        FirebaseDatabase(databaseURL: kRTDBUrl).reference().child("rooms");
  }

  Future joinAgoraRoom(String token, Room room) async {
    _engine = await RtcEngine.create(kAgoraAppId);
    await _engine?.disableVideo();
    await _engine?.enableAudio();
    await _engine?.setChannelProfile(ChannelProfile.Game);
    await _engine?.setDefaultAudioRoutetoSpeakerphone(true);
    await _engine?.registerLocalUserAccount(kAgoraAppId, currentUser!.id);
    print("room token $token ${room.id}");
    muted = true;
    this.room = room;
    addEventHandlers(token, room.id);
    addFireBaseStorageHandler(room.id);
    notifyListeners();
  }

  Future leaveRoom(String roomId) async {
    isJoined = false;
    notifyListeners();
    await _roomsBloc.leaveRoom(roomId);
    await _rtDbReference.child("rooms_$roomId").child(currentUser!.id).remove();
    await _engine?.leaveChannel();
  }

  Future toggleMute() async {
    final status = await Permission.microphone.request();
    // if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
    //   return;
    // }
    print(status.isDenied);
    muted = !muted;
    currentUser!.muted = muted;
    await _rtDbReference.child(currentUser!.id).set(currentUser!.toJson());
    await _engine?.muteLocalAudioStream(muted);
    notifyListeners();
  }

  void addEventHandlers(token, channelName) {
    _engine?.setEventHandler(RtcEngineEventHandler(error: (code) {
      print("join failed $code");
    }, joinChannelSuccess: (channel, uid, elapsed) async {
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
      _roomsBloc.leaveRoom(room!.id);
      _rtDbReference.child(currentUser!.id).remove();
    }
    _engine?.destroy();
    _roomsBloc.dispose();
  }
}
