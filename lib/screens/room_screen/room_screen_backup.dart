import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/provider/agora_provider.dart';
import 'package:sports_house/screens/event_rooms/event_room.dart';
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
  late DatabaseReference databaseReference =
      FirebaseDatabase(databaseURL: kRTDBUrl)
          .reference()
          .child("fixture")
          .child("fixture_${widget.arguments.agoraRoom.room.fixture.id}");
  Future handleMicroPhonePermission() async {
    final status = await Permission.microphone.request();
    if (!status.isDenied & !status.isPermanentlyDenied & !status.isRestricted) {
      Provider.of<AgoraProvider>(context, listen: false).joinAgoraRoom(
          widget.arguments.agoraRoom.token, widget.arguments.agoraRoom);
    } else {
      _showPermissionDialog();
    }
  }

  Future<void> _showPermissionDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(kPermissionText),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.popUntil(
                    context, ModalRoute.withName(EventRooms.pageId));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (!Provider.of<AgoraProvider>(context, listen: false).isJoined) {
      handleMicroPhonePermission();
    }
  }

  @override
  void dispose() {
    super.dispose();
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
                  context
                      .read<AgoraProvider>()
                      .leaveRoom(widget.arguments.agoraRoom.room.id);
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
                onPressed: context.read<AgoraProvider>().toggleMute,
                style: TextButton.styleFrom(
                  backgroundColor: kMuteButtonBgColor,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(10),
                ),
                child: context.watch<AgoraProvider>().muted
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
      padding: EdgeInsets.all(12),
      decoration: new BoxDecoration(
        color: kCardBgColor,
        shape: BoxShape.circle,
      ),
      child: CachedNetworkImage(
        imageUrl: url,
        //placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.flag),
        width: 40,
        height: 40,
      ),
    );
  }

  Container buildParticipant({
    required String? imageUrl,
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
                  backgroundImage: AssetImage(
                    kProfilePlaceHolder,
                  ),
                  foregroundImage: CachedNetworkImageProvider(
                    imageUrl ?? kProfilePlaceHolderUrl,
                  ),
                  onForegroundImageError: (exception, stackTrace) {
                    print(exception);
                  },
                ),
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kProfileMutedBgColor,
                  ),
                  child: Icon(
                    isMuted ? Icons.mic_off_rounded : Icons.mic,
                    color: isMuted ? kMutedButtonColor : kUnmutedButtonColor,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              if (room.createdBy.name != null)
                                Text(
                                  'Hosted By: ${room.createdBy.name}',
                                  style: TextStyle(
                                    // color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
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
                        height: 6,
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
                            child: StreamBuilder<Event>(
                              stream: databaseReference
                                  .child("score")
                                  .child("current")
                                  .onValue,
                              builder: (context, snapShot) {
                                if (snapShot.hasData) {
                                  if (snapShot.data!.snapshot.value != null) {
                                    Map<String, dynamic> score =
                                        new Map<String, dynamic>.from(
                                            snapShot.data!.snapshot.value);
                                    return Text(
                                      '${score["home"]} - ${score["away"]}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    );
                                  }
                                }
                                return Text(
                                  'Vs',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                );
                              },
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
                            imageUrl: context
                                .watch<AgoraProvider>()
                                .roomUsers[index]
                                .profilePictureUrl,
                            name: context
                                .watch<AgoraProvider>()
                                .roomUsers[index]
                                .name!,
                            isMuted: (context
                                        .watch<AgoraProvider>()
                                        .roomUsers[index]
                                        .muted ==
                                    null ||
                                context
                                    .watch<AgoraProvider>()
                                    .roomUsers[index]
                                    .muted!));
                      },
                      itemCount:
                          context.watch<AgoraProvider>().roomUsers.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 10,
                        crossAxisCount: 4,
                        childAspectRatio: 0.5,
                      ),
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
}
