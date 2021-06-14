import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_bottom_bar/expandable_bottom_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/lineup.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/provider/agora_provider.dart';
import 'package:sports_house/screens/event_rooms/event_room.dart';
import 'package:sports_house/utils/classes/event_classes.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:timeline_tile/timeline_tile.dart';

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

class _RoomScreenState extends State<RoomScreen> with TickerProviderStateMixin {
  late DatabaseReference databaseReference =
      FirebaseDatabase(databaseURL: kRTDBUrl)
          .reference()
          .child("fixture")
          .child("fixture_${widget.arguments.agoraRoom.room.fixture.id}");
  late BottomBarController _bottomBarController;

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
    _bottomBarController = new BottomBarController(
      vsync: this,
    );
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
      body: SingleChildScrollView(
        child: buildUi(
          widget.arguments.agoraRoom.room,
        ),
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        //
        // Set onVerticalDrag event to drag handlers of controller for swipe effect
        onVerticalDragUpdate: _bottomBarController.onDrag,
        onVerticalDragEnd: _bottomBarController.onDragEnd,
        child: FloatingActionButton.extended(
          label: AnimatedBuilder(
            animation: _bottomBarController.state,
            builder: (context, child) => Row(
              children: [
                Text(
                  _bottomBarController.isOpen ? kParticipants : kParticipants,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Product Sans',
                    letterSpacing: 0,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4.0),
                AnimatedBuilder(
                  animation: _bottomBarController.state,
                  builder: (context, child) => Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(
                      1,
                      _bottomBarController.state.value * 2 - 1,
                      1,
                    ),
                    child: child,
                  ),
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          elevation: 2,
          backgroundColor: kColorGreen,
          foregroundColor: kColorBlack,
          //
          //Set onPressed event to swap state of bottom bar
          onPressed: () => _bottomBarController.swap(),
        ),
      ),
      bottomNavigationBar: BottomExpandableAppBar(
        appBarHeight: 70,
        bottomAppBarColor: Colors.transparent,
        controller: _bottomBarController,
        horizontalMargin: 0,
        shape: AutomaticNotchedShape(
            RoundedRectangleBorder(), StadiumBorder(side: BorderSide())),
        expandedBackColor: Colors.transparent,
        expandedBody: buildParticipantsView(),
        bottomAppBarBody: buildBottomNavigationBar(context),
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        buildMatchTimeline(room),
        buildStartingXIHomeAndAway(room),
        buildSubstitutesHomeAndAway(room),
      ],
    );
  }

  Widget buildStartingXIHomeAndAway(Room room) {
    return Card(
      color: kCardBgColor,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 15,
              ),
              child: Text(
                kStartingXI,
                style: TextStyle(
                  color: kColorGreen,
                  fontSize: kHeadingFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: buildStartingXI(room, 'home'),
                ),
                Expanded(
                  child: buildStartingXI(room, 'away'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSubstitutesHomeAndAway(Room room) {
    return Card(
      color: kCardBgColor,
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 15,
              ),
              child: Text(
                kSubtitutes,
                style: TextStyle(
                  color: kColorGreen,
                  fontSize: kHeadingFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: buildSubstitutes(room, 'home'),
                ),
                Expanded(
                  child: buildSubstitutes(room, 'away'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ListView buildStartingXI(Room room, String team) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: team == 'home'
          ? room.fixture.teams.home.lineups.startXI!.length
          : room.fixture.teams.away.lineups.startXI!.length,
      itemBuilder: (context, i) {
        Lineup lineup = team == 'home'
            ? room.fixture.teams.home.lineups
            : room.fixture.teams.away.lineups;
        return ListTile(
          title: Text(
            '${lineup.startXI![i].name}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          leading: Container(
            height: 40,
            width: 40,
            // padding: EdgeInsets.all(15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kDropdownBgColor,
            ),
            child: Text(
              '${lineup.startXI![i].pos}',
              style: TextStyle(
                color: kColorGreen,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  ListView buildSubstitutes(Room room, String team) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: team == 'home'
          ? room.fixture.teams.home.lineups.substitutes!.length
          : room.fixture.teams.away.lineups.substitutes!.length,
      itemBuilder: (context, i) {
        Lineup lineup = team == 'home'
            ? room.fixture.teams.home.lineups
            : room.fixture.teams.away.lineups;
        return ListTile(
          title: Text(
            '${lineup.substitutes![i].name}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          leading: Container(
            height: 40,
            width: 40,
            // padding: EdgeInsets.all(15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kDropdownBgColor,
            ),
            child: Text(
              '${lineup.substitutes![i].pos}',
              style: TextStyle(
                color: kColorGreen,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  StreamBuilder<Event> buildMatchTimeline(Room room) {
    return StreamBuilder<Event>(
      stream: databaseReference.child("events").onValue,
      builder: (context, snapShot) {
        if (snapShot.hasData) {
          if (snapShot.data!.snapshot.value != null) {
            var events = snapShot.data!.snapshot.value;
            List<dynamic> matchEvents = events
                .map((event) => MatchEvent.fromDb(event))
                .toList() as List<dynamic>;
            // for (var event in events) {

            matchEvents = List.from(matchEvents.reversed);
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: matchEvents.length,
              itemBuilder: (context, int i) {
                MatchEvent event = matchEvents[i];
                return TimelineTile(
                  alignment: TimelineAlign.center,
                  isFirst: i == 0,
                  isLast: i == matchEvents.length - 1,
                  indicatorStyle: IndicatorStyle(
                    color: kColorGreen,
                    indicatorXY: 0.5,
                    indicator: Container(
                      // padding: EdgeInsets.all(),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kColorGreen,
                      ),
                      child: Center(
                        child: Text(
                          event.time.elapsed.toString(),
                          style: TextStyle(
                            color: kCardBgColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  startChild: (event.team.name == room.fixture.teams.home.name)
                      ? buildEventCard(event, Position.left)
                      : Center(),
                  endChild:
                      (matchEvents[i].team.name == room.fixture.teams.away.name)
                          ? buildEventCard(event, Position.right)
                          : Center(),
                );
              },
            );
          }
        }
        return Center();
      },
    );
  }

  Container buildEventCard(MatchEvent event, Position position) {
    IconData icon = Icons.sports;
    Color color = kColorGreen;

    switch (event.type) {
      case 'Goal':
        // color = Colors.white;
        icon = Icons.sports_soccer;
        break;
      case 'subst':
        icon = Icons.change_circle_outlined;
        color = Colors.white54;
        break;
      case 'Card':
        icon = Icons.crop_portrait;
        if (event.detail == 'Yellow Card')
          color = Colors.yellowAccent;
        else if (event.detail == 'Red Card') color = Colors.redAccent;
        break;
    }
    return Container(
        child: Card(
      color: kCardBgColor,
      margin: EdgeInsets.all(7),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Icon( == 'Goal'?),
            if (position == Position.right) buildEventTypeIcon(icon, color),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(event.detail),
                  Text(
                    '${event.player.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (event.type != 'Card' &&
                      event.assist.id != -1 &&
                      event.assist.name != '')
                    Text(
                      event.type == 'subst'
                          ? 'Sub: ' + event.assist.name
                          : 'Assist: ' + event.assist.name,
                    )
                  else if (event.type == 'Card')
                    Text(
                      'For: ' + event.comments,
                    ),
                ],
              ),
            ),
            if (position == Position.left) buildEventTypeIcon(icon, color),
          ],
        ),
      ),
    ));
  }

  Padding buildEventTypeIcon(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 3,
      ),
      child: icon != Icons.crop_portrait
          ? Icon(
              icon,
              color: color,
            )
          : Container(
              width: 12,
              height: 18,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(
                horizontal: 6,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
    );
  }

  Expanded buildParticipantsView() {
    return Expanded(
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
                  itemCount: context.watch<AgoraProvider>().roomUsers.length,
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
    );
  }
}
