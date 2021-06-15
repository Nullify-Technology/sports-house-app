import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/lineup.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/models/team.dart';
import 'package:sports_house/provider/agora_provider.dart';
import 'package:sports_house/screens/event_rooms/event_room.dart';
import 'package:sports_house/utils/classes/event_classes.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/EventsCard.dart';
import 'package:sports_house/utils/reusable_components/error_components.dart';
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
                    child: buildRoomHeader(widget.arguments.agoraRoom.room),
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
                  widget.arguments.agoraRoom.room,
                ),
                buildMatchXI(widget.arguments.agoraRoom.room),
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
        width: 30,
        height: 30,
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

  Column buildRoomHeader(Room room) {
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
                            Text(
                              '${room.count} $kListners',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 17,
                              ),
                            )
                          ],
                        ),
                      ),
                      StreamBuilder<Event>(
                        stream: databaseReference.child("status").onValue,
                        builder: (context, snapShot) {
                          if (snapShot.hasData) {
                            if (snapShot.data!.snapshot.value != null) {
                              Map<String, dynamic> status =
                                  new Map<String, dynamic>.from(
                                      snapShot.data!.snapshot.value);

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

  static Widget buildTimerWidget(Map<String, dynamic> status) {
    bool isStatus = status['short'] != null &&
        (status['short'] != "1H" &&
            status['short'] != "2H" &&
            status['short'] != "ET" &&
            status['short'] != "P");
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: new BoxDecoration(
        color: isStatus ? kCardBgColor : Colors.redAccent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(40.0)),
      ),
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
            isStatus && status['long'] != null
                ? status['long']
                : status['elapsed'].toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMatchXI(Room room) {
    if (room.fixture.teams.home.lineups.startXI != null &&
        room.fixture.teams.home.lineups.startXI != null) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTeamTitle(room.fixture.teams.home),
              SizedBox(
                height: 20,
              ),
              buildStartingXI(room, 'home'),
              SizedBox(
                height: 40,
              ),
              buildTeamTitle(room.fixture.teams.away),
              SizedBox(
                height: 20,
              ),
              buildStartingXI(room, 'home'),
              SizedBox(
                height: 90,
              ),
            ],
          ),
        ),
      );
    } else
      return buildSquadDetailsUnavilable(
        context: context,
        error: kSquadDetailsUnavailable,
        icon: Icons.sports_soccer,
      );
    ;
  }

  Row buildTeamTitle(Team team) {
    return Row(
      children: [
        SizedBox(
          width: 20,
        ),
        CachedNetworkImage(
          width: 40,
          imageUrl: team.logoUrl,
        ),
        SizedBox(
          width: 15,
        ),
        Text(
          team.name,
          style: TextStyle(
            // color: kColorGreen,
            fontSize: kHeadingFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildSubstitutesHomeAndAway(Room room) {
    if (room.fixture.teams.home.lineups.substitutes != null &&
        room.fixture.teams.home.lineups.substitutes != null) {
      return SingleChildScrollView(
        child: Card(
          color: kCardBgColor,
          margin: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
        ),
      );
    } else
      return buildSquadDetailsUnavilable(
        context: context,
        error: kSquadDetailsUnavailable,
        icon: Icons.change_circle,
      );
  }

  Widget buildStartingXI(Room room, String team) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
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
              '${lineup.startXI![i].name} ( ${lineup.startXI![i].number} )',
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
              child: CircleAvatar(
                foregroundImage: CachedNetworkImageProvider(room.fixture
                        .players![lineup.startXI![i].id.toString()]!.photo ??
                    kDummyProfileImageUrl),
              ),
            ),
          );
        },
      ),
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
        return buildSquadDetailsUnavilable(
          context: context,
          error: kTimeLineUnavailable,
          icon: Icons.timeline,
        );
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
            GridView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index) {
                return buildParticipant(
                  imageUrl: context
                      .watch<AgoraProvider>()
                      .roomUsers[index]
                      .profilePictureUrl,
                  name: context.watch<AgoraProvider>().roomUsers[index].name!,
                  isMuted: (context
                              .watch<AgoraProvider>()
                              .roomUsers[index]
                              .muted ==
                          null ||
                      context.watch<AgoraProvider>().roomUsers[index].muted!),
                );
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
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
