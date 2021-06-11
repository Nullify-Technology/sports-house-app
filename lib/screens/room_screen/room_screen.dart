import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sports_house/blocs/rooms_bloc.dart';
import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/provider/user_provider.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:provider/provider.dart';

class RoomScreenArguments {
  final AgoraRoom room;

  RoomScreenArguments(this.room);
}

class RoomScreen extends StatefulWidget {
  RoomScreen({Key? key}) : super(key: key);
  static String pageId = 'RoomScreen';
  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late RoomScreenArguments arguments;
  late RoomsBloc roomsBloc;
  late RtcEngine _engine;
  late AuthUser currentUser;
  bool _joined = false;
  bool _muted = true;
  @override
  void initState() {
    roomsBloc = RoomsBloc(client: RestClient.create());
    _handleMicPermission();
    super.initState();
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    roomsBloc.dispose();
    _engine.destroy();
    super.dispose();
  }

  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _engine.muteLocalAudioStream(_muted);
  }

  @override
  Widget build(BuildContext context) {
    arguments =
        ModalRoute.of(context)!.settings.arguments as RoomScreenArguments;
    currentUser = context.watch<UserProvider>().currentUser!;
    initializeAgoraEngine(
        arguments.room.token, arguments.room.room.id, currentUser.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          kAppName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: kColorBlack,
      body: buildUi(arguments.room.room),
      extendBody: true,
      bottomNavigationBar: Card(
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.all(0),
        elevation: 10,
        color: kBottomBarBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: kCreateRoomCardRadius,
            topRight: kCreateRoomCardRadius,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  primary: Colors.redAccent,
                  backgroundColor: kMuteButtonBgColor,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.redAccent,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      kLeaveRoom,
                      style: TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _onToggleMute,
                style: TextButton.styleFrom(
                  backgroundColor: kMuteButtonBgColor,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(10),
                ),
                child: _muted
                    ? Icon(
                        Icons.mic_off_rounded,
                        color: kMutedButtonColor,
                      )
                    : Icon(
                        Icons.mic_rounded,
                        color: kUnmutedButtonColor,
                      ),
              )
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: _muted
      //       ? Icon(
      //           Icons.mic_off_rounded,
      //           color: kUnmutedButtonColor,
      //         )
      //       : Icon(
      //           Icons.mic_rounded,
      //           color: kMutedButtonColor,
      //         ),
      //   backgroundColor: _muted ? kMutedButtonColor : kUnmutedButtonColor,
      //   onPressed: _onToggleMute,
      // ),
    );
  }

  Container buildTeamIcon(String url) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: new BoxDecoration(
        color: kCardBgColor,
        shape: BoxShape.circle,
      ),
      child: Image.network(
        url,
        width: 40,
        height: 40,
      ),
    );
  }

  Container buildParticipant({
    required String imageUrl,
    required String name,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            foregroundImage: NetworkImage(
              imageUrl,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            name,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildUi(Room room) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            room.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          // if (widget.room.isVerified)
                          //   Icon(
                          //     Icons.verified,
                          //     color: kColorGreen,
                          //     size: 18,
                          //   ),
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      // if (widget.room.hostedBy != '')
                      //   Text(
                      //     '$kHostedBy ${widget.room.hostedBy}',
                      //     style: TextStyle(
                      //       // color: Colors.white54,
                      //       fontSize: 14,
                      //     ),
                      //   ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.hearing,
                            size: 18,
                            color: Colors.white54,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            '${room.count} $kListners',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 17,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 6,
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildTeamIcon(room.fixture.teams.home.logoUrl),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                            decoration: new BoxDecoration(
                              color: kCardBgColor,
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40.0)),
                            ),
                            child: Text(
                              "2",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          buildTeamIcon(room.fixture.teams.away.logoUrl),
                        ],
                      ),
                      // Text(
                      //   widget.room.eventName,
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 12,
                      //     color: Colors.white54,
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: Card(
            margin: EdgeInsets.all(0),
            color: kCardBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: kCreateRoomCardRadius,
                topRight: kCreateRoomCardRadius,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          kParticipants,
                          style: TextStyle(
                            fontSize: kHeadingFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    //TODO : @Abhishek Change this row with StreamBuilder Listview
                    Row(
                      children: [
                        Expanded(
                          child: buildParticipant(
                            imageUrl: kDummyImageUrl,
                            name: kDummyUserName,
                          ),
                        ),
                        Expanded(
                          child: buildParticipant(
                            imageUrl: kDummyImageUrl,
                            name: kDummyUserName,
                          ),
                        ),
                        Expanded(
                          child: buildParticipant(
                            imageUrl: kDummyImageUrl,
                            name: kDummyUserName,
                          ),
                        ),
                        Expanded(
                          child: buildParticipant(
                            imageUrl: kDummyImageUrl,
                            name: kDummyUserName,
                          ),
                        ),
                      ],
                    ),

                    //Needed for padding bottomNavBar
                    SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> initializeAgoraEngine(
      String token, String channelName, String userId) async {
    _engine = await RtcEngine.create(kAgoraAppId);
    await _engine.registerLocalUserAccount(kAgoraAppId, userId);
    await _engine.disableVideo();
    await _engine.enableAudio();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
    await _engine.muteLocalAudioStream(_muted);
    addEventHandlers();
    await _engine.joinChannel(token, channelName, null, 0);
  }

  void addEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          print(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) async {
        final info = 'onJoinChannel: $channel, uid: $uid';
        print(info);
        setState(() {
          _joined = true;
        });
      },
      leaveChannel: (stats) async {
        print("leaved");
      },
      userJoined: (uid, elapsed) async {
        final info = 'userJoined: $uid';
        UserInfo uInfo = await _engine.getUserInfoByUid(uid);
        print("User Account" + uInfo.userAccount!);
      },
      userOffline: (uid, reason) {
        final info = 'userOffline: $uid , reason: $reason';
        print(info);
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {},
    ));
  }

  void _handleMicPermission() {
    final status = Permission.microphone.request();
    print(status);
  }
}
