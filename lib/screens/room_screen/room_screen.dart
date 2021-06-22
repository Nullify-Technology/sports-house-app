import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/provider/rtc_provider.dart';
import 'package:sports_house/screens/home/home_screen.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/CenterProgressBar.dart';
import 'package:sports_house/screens/room_screen/squad_tab.dart';
import 'package:sports_house/screens/room_screen/timeline_tab.dart';
import 'package:sports_house/screens/room_screen/timer_widget.dart';

class RoomScreenArguments {
  final Room room;

  RoomScreenArguments(this.room);
}

class RoomScreen extends StatefulWidget {
  final RoomScreenArguments arguments;

  RoomScreen({Key key, this.arguments}) : super(key: key);
  static String pageId = 'RoomScreen';

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> with TickerProviderStateMixin {
  DatabaseReference fixtureReference;
  DatabaseReference roomReference;

  Future _joinRTCRoom(Room room) async {
    try {
      Room currentRoom = Provider.of<RTCProvider>(context, listen: false).room;
      print("current room ${currentRoom == null ? currentRoom : currentRoom.id} , future room ${room.id}");
      if (currentRoom == null || currentRoom.id != room.id) {
        print("inside if");
        await Provider.of<RTCProvider>(context, listen: false)
            .joinRTCRoom(room);
      }
    } catch (e) {
      showAlertDialog(context);
    }
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Ok"),
      onPressed: () {
        Navigator.popUntil(context, ModalRoute.withName(HomeScreen.pageId));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(kRoomNetworkAlert),
      actions: [
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    fixtureReference = FirebaseDatabase(databaseURL: kRTDBUrl)
        .reference()
        .child("fixture")
        .child("fixture_${widget.arguments.room.fixture.id}");
    roomReference = FirebaseDatabase(databaseURL: kRTDBUrl)
        .reference()
        .child(kRTCRoom)
        .child(widget.arguments.room.id);
    _joinRTCRoom(widget.arguments.room);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBlack,
      extendBody: true,
      bottomNavigationBar: buildBottomNavigationBar(context),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 260.0,
                floating: false,
                backgroundColor: kHomeAppBarBgColor,
                pinned: true,
                title: Text(
                  kAppName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  // centerTitle: true,
                  background: Padding(
                    padding:
                        const EdgeInsets.only(top: 70, left: 15, right: 15),
                    child: buildRoomHeader(
                        widget.arguments.room, fixtureReference, roomReference),
                  ),
                ),
                bottom: TabBar(
                  indicatorColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: BoxDecoration(),
                  tabs: <Widget>[
                    Tab(
                      icon: Icon(Icons.group),
                    ),
                    Tab(
                      icon: Icon(Icons.timeline),
                    ),
                    Tab(
                      icon: Icon(Icons.sports_soccer),
                    ),
                    // Tab(icon: Icon(Icons.change_circle)),
                  ],
                ),
              ),
            ];
          },
          body: Padding(
            padding: const EdgeInsets.only(
              top: 10,
            ),
            child: TabBarView(
              children: [
                buildParticipantsView(),
                buildMatchTimeline(
                    widget.arguments.room.fixture, fixtureReference),
                buildMatchXI(widget.arguments.room.fixture, context),
                // buildSubstitutesHomeAndAway(widget.arguments.agoraRoom.room),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Card buildBottomNavigationBar(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.zero,
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
          horizontal: 10,
          vertical: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () async {
                context.read<RTCProvider>().leaveRoom();
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
              onPressed: () => context.read<RTCProvider>().toggleMute(),
              style: TextButton.styleFrom(
                backgroundColor: kMuteButtonBgColor,
                shape: CircleBorder(),
                padding: EdgeInsets.all(10),
              ),
              child: context.watch<RTCProvider>().muted
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
    );
  }

  Widget buildParticipantsView() {
    return Card(
      margin: EdgeInsets.all(0),
      color: kCardBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: kCreateRoomCardRadius,
          topRight: kCreateRoomCardRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          30,
          30,
          30,
          70,
        ),
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
            StreamBuilder<Event>(
              stream: roomReference.onValue,
              builder: (context, snapShot) {
                if (snapShot.hasData) {
                  if (snapShot.data.snapshot.value != null) {
                    Map<String, dynamic> userDetails =
                        new Map<String, dynamic>.from(
                            snapShot.data.snapshot.value);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.zero,
                      itemBuilder: (BuildContext context, int index) {
                        AuthUser user = AuthUser.fromJson(
                            Map<String, dynamic>.from(
                                userDetails.values.toList()[index]));
                        return buildParticipant(
                            imageUrl: user.profilePictureUrl,
                            name: user.name,
                            isMuted: user.muted);
                      },
                      itemCount: userDetails.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 10,
                        crossAxisCount: 4,
                        childAspectRatio: 0.5,
                      ),
                    );
                  }
                }
                return Container(
                  // height: MediaQuery.of(context).size.height - 600,
                  child: CenterProgressBar(),
                );
              },
            ),

            //Needed for padding bottomNavBar
            SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
    );
  }

  Container buildParticipant({
    String imageUrl,
    String name,
    bool isMuted = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 5,
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
}

Container buildTeamIcon(String url, {size = 30.0}) {
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
      width: size,
      height: size,
    ),
  );
}

Column buildRoomHeader(Room room, DatabaseReference fixtureReference, DatabaseReference roomReference) {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
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
                    Expanded(
                      child: Column(
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
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.hearing,
                            size: 18,
                            color: Colors.white54,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          StreamBuilder<Event>(
                            stream: roomReference.onValue,
                            builder: (context, snapShot) {
                              if (snapShot.hasData) {
                                if (snapShot.data.snapshot.value != null) {
                                  Map<String, dynamic> members =
                                  new Map<String, dynamic>.from(
                                      snapShot.data.snapshot.value);

                                  return Text(
                                    '${members.length} $kListners',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 17,
                                    ),
                                  );
                                }
                              }

                              return Text(
                                '${room.count} $kListners',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 17,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<Event>(
                      stream: fixtureReference.child("status").onValue,
                      builder: (context, snapShot) {
                        if (snapShot.hasData) {
                          if (snapShot.data.snapshot.value != null) {
                            Map<String, dynamic> status =
                                new Map<String, dynamic>.from(
                                    snapShot.data.snapshot.value);

                            return buildTimerWidget(status);
                          }
                        }
                        return Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 5,
                          ),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: kCardBgColor,
                              borderRadius: BorderRadius.circular(
                                20,
                              )),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer,
                                size: 16,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                kNotStarted,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
                        borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      ),
                      child: StreamBuilder<Event>(
                        stream: fixtureReference
                            .child("score")
                            .child("current")
                            .onValue,
                        builder: (context, snapShot) {
                          if (snapShot.hasData) {
                            if (snapShot.data.snapshot.value != null) {
                              Map<String, dynamic> score =
                                  new Map<String, dynamic>.from(
                                      snapShot.data.snapshot.value);
                              return Column(
                                children: [
                                  Text(
                                    '${score["home"]} - ${score["away"]}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
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
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
