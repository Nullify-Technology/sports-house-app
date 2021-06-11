import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/provider/user_provider.dart';
import 'package:sports_house/utils/constants.dart';

class RoomScreenArguments {
  final AgoraRoom agoraRoom;

  RoomScreenArguments(this.agoraRoom);
}

class RoomScreen extends StatefulWidget {
  final RoomScreenArguments arguments;

  RoomScreen({Key? key, required this.arguments}) : super(key: key);
  static String pageId = 'RoomScreen';

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late RtcEngine _engine;
  late AuthUser currentUser;
  bool _muted = true;
  final List<String> _roomUsers = [];

  @override
  void initState() {
    super.initState();
    _handleMicPermission();
    currentUser = Provider.of<UserProvider>(context, listen: false).currentUser!;
    initializeAgoraEngine(widget.arguments.agoraRoom.token,
        widget.arguments.agoraRoom.room.id, currentUser.id);
  }

  @override
  void dispose() {
    _engine.leaveChannel();
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
      body: buildUi(widget.arguments.agoraRoom.room),
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
    bool isMuted = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            // color: Colors.red,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 30,
                  foregroundImage: NetworkImage(
                    imageUrl,
                  ),
                ),
                if (isMuted)
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kProfileMutedBgColor,
                    ),
                    child: Icon(
                      Icons.mic_off_rounded,
                      color: kMutedButtonColor,
                      size: 17,
                    ),
                  )
              ],
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            room.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                          // SizedBox(
                          //   width: 6,
                          // ),
                          // if (widget.room.isVerified)
                          //   Icon(
                          //     Icons.verified,
                          //     color: kColorGreen,
                          //     size: 18,
                          //   ),
                          TextButton(
                            onPressed: () {
                              //TODO : Add option for sharing room link
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: kMuteButtonBgColor,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(12),
                            ),
                            child: Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 18,
                            ),
                          )
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
                    GridView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        return buildParticipant(
                            imageUrl: kDummyImageUrl, name: kDummyUserName);
                      },
                      itemCount: _roomUsers.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: 10,
                          crossAxisCount: 4,
                          childAspectRatio: 0.7),
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
    await _engine.setChannelProfile(ChannelProfile.Game);
    // await _engine.setClientRole(ClientRole.Broadcaster);
    await _engine.setDefaultAudioRoutetoSpeakerphone(true);
    addEventHandlers(token, channelName);
    await _engine.registerLocalUserAccount(kAgoraAppId, userId);
  }

  void addEventHandlers(token, channelName) {
    _engine.setEventHandler(RtcEngineEventHandler(
        error: (code) {},
        joinChannelSuccess: (channel, uid, elapsed) async {
          UserInfo uInfo = await _engine.getUserInfoByUid(uid);
          await _engine.muteLocalAudioStream(_muted);
          print("onJoinChannel ${uInfo.userAccount}");
          setState(() {
            _roomUsers.add(uInfo.userAccount!);
          });
        },
        leaveChannel: (stats) async {
          print("left");
        },
        userJoined: (uid, elapsed) async {
          UserInfo uInfo = await _engine.getUserInfoByUid(uid);
          final info = 'userJoined: $uid';
          print(info, );
          setState(() {
            _roomUsers.add(uInfo.userAccount!);
          });
        },
        userOffline: (uid, reason) {
          final info = 'userOffline: $uid , reason: $reason';
          print(info);
        },
        firstRemoteVideoFrame: (uid, width, height, elapsed) {},
        localUserRegistered: (uid, userAccount) async {
          print("user registered $userAccount");
          await _engine.joinChannelWithUserAccount(
              token, channelName, userAccount);
        }));
  }

  Future<void> _handleMicPermission() async {
    final status = await Permission.microphone.request();
    print(status.isDenied);
  }
}
