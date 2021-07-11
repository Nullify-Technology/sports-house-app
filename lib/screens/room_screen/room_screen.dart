import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:match_cafe/utils/classes/event_classes.dart';
import 'package:match_cafe/provider/user_provider.dart';
import 'package:match_cafe/utils/client_events.dart';
import 'package:match_cafe/utils/reusable_components/custom_text.dart';
import 'package:provider/provider.dart';
import 'package:match_cafe/models/room.dart';
import 'package:match_cafe/models/user.dart';
import 'package:match_cafe/provider/rtc_provider.dart';
import 'package:match_cafe/screens/home/home_screen.dart';
import 'package:match_cafe/utils/constants.dart';
import 'package:match_cafe/utils/reusable_components/CenterProgressBar.dart';
import 'package:match_cafe/screens/room_screen/squad_tab.dart';
import 'package:match_cafe/screens/room_screen/timeline_tab.dart';
import 'package:match_cafe/screens/room_screen/timer_widget.dart';
import 'package:share/share.dart';

class RoomScreenArguments {
  final Room room;

  RoomScreenArguments(this.room);
}

class RoomScreen extends StatefulWidget {
  final RoomScreenArguments arguments;
  final Stream<ClientEvents> parentEvents;
  RoomScreen({Key? key, required this.arguments, required this.parentEvents})
      : super(key: key);
  static String pageId = 'RoomScreen';

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> with TickerProviderStateMixin {
  late DatabaseReference fixtureReference;
  late DatabaseReference roomReference;
  late AuthUser _currentUser;

  Future _joinRTCRoom(Room room) async {
    try {
      if (room.type == "public") {
        throw "public room is disabled for this build";
      }
      Room? currentRoom = Provider.of<RTCProvider>(context, listen: false).room;
      print(
          "current room ${currentRoom == null ? currentRoom : currentRoom.id} , future room ${room.id}");
      if ((currentRoom == null || currentRoom.id != room.id) &&
          !room.isClosed!) {
        print("inside if");
        await Provider.of<RTCProvider>(context, listen: false)
            .joinRTCRoom(room);
      }
    } catch (e) {
      print(e);
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

  showParticipantOptions(BuildContext context, AuthUser user) {
    // show the dialog
    if (user.id == widget.arguments.room.createdById ||
        user.id == _currentUser.id) {
      return;
    }
    List<Widget> options = [];
    if (user.isModerator!) {
      options.add(SimpleDialogOption(
        padding: EdgeInsets.all(15),
        child: Text("Move to listeners"),
        onPressed: () {
          Provider.of<RTCProvider>(context, listen: false)
              .demoteToListener(user);
          Navigator.of(context).pop();
        },
      ));
    } else if (!user.isModerator! && user.isSpeaker!) {
      options.add(SimpleDialogOption(
        padding: EdgeInsets.all(15),
        onPressed: () {
          Provider.of<RTCProvider>(context, listen: false)
              .promoToModerator(user);
          Navigator.of(context).pop();
        },
        child: Text("Promote to Moderator"),
      ));
      options.add(SimpleDialogOption(
        padding: EdgeInsets.all(15),
        onPressed: () {
          Provider.of<RTCProvider>(context, listen: false)
              .demoteToListener(user);
          Navigator.of(context).pop();
        },
        child: Text("Move to listeners"),
      ));
    } else if (!user.isSpeaker!) {
      options.add(SimpleDialogOption(
        padding: EdgeInsets.all(15),
        onPressed: () {
          Provider.of<RTCProvider>(context, listen: false)
              .promoteToSpeaker(user);
          Navigator.of(context).pop();
        },
        child: Text("Invite to speak"),
      ));
    }
    SimpleDialog alert = SimpleDialog(children: options);
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
        .child("fixture_${widget.arguments.room.fixture!.id}");
    roomReference = FirebaseDatabase(databaseURL: kRTDBUrl)
        .reference()
        .child(kRTCRoom)
        .child(widget.arguments.room.id!);
    _joinRTCRoom(widget.arguments.room);
    listenForGlobalEvents();
    super.initState();
  }

  void listenForGlobalEvents() {
    widget.parentEvents.listen((event) {
      if (event == ClientEvents.LeveRoom) {
        Room? room = Provider.of<RTCProvider>(context, listen: false).room;
        if (room != null) {
          Provider.of<RTCProvider>(context, listen: false).leaveRoom(room.id!);
        }
        Navigator.popUntil(context, ModalRoute.withName(HomeScreen.pageId));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentUser = context.watch<UserProvider>().currentUser!;
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
                expandedHeight: 310.0,
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
                    child: buildRoomHeader(widget.arguments.room,
                        fixtureReference, roomReference, _currentUser),
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
                    widget.arguments.room.fixture!, fixtureReference),
                buildMatchXI(widget.arguments.room.fixture!, context),
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
                context
                    .read<RTCProvider>()
                    .leaveRoom(widget.arguments.room.id!);
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
            context.watch<RTCProvider>().isSpeaker
                ? TextButton(
                    onPressed: () => context
                        .read<RTCProvider>()
                        .toggleMute(widget.arguments.room.id!),
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
                : SizedBox()
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
            ...buildParticipantList(),
            //Needed for padding bottomNavBar
            SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildParticipantList() {
    return context.watch<RTCProvider>().joined
        ? [
            StreamBuilder<Event>(
              stream: roomReference.child(kDBSpeaker).onValue,
              builder: (context, snapShot) {
                if (snapShot.hasData) {
                  if (snapShot.data!.snapshot.value != null) {
                    Map<String, dynamic> userDetails =
                        new Map<String, dynamic>.from(
                            snapShot.data!.snapshot.value);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.zero,
                      itemBuilder: (BuildContext context, int index) {
                        AuthUser user = AuthUser.fromJson(
                            Map<String, dynamic>.from(
                                userDetails.values.toList()[index]));
                        if (_currentUser.isModerator!) {
                          return GestureDetector(
                            onTap: () => showParticipantOptions(context, user),
                            child: buildParticipant(
                                imageUrl: user.profilePictureUrl,
                                name: user.name,
                                peerId: user.peerId,
                                isMuted: user.muted,
                                isModerator: user.isModerator,
                                isSpeaker: user.isSpeaker)!,
                          );
                        } else {
                          return buildParticipant(
                              imageUrl: user.profilePictureUrl,
                              name: user.name,
                              peerId: user.peerId,
                              isMuted: user.muted,
                              isModerator: user.isModerator,
                              isSpeaker: user.isSpeaker)!;
                        }
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
                return Container();
              },
            ),
            StreamBuilder<Event>(
              stream: roomReference.child(kDBAudience).onValue,
              builder: (context, snapShot) {
                if (snapShot.hasData) {
                  if (snapShot.data!.snapshot.value != null) {
                    Map<String, dynamic> userDetails =
                        new Map<String, dynamic>.from(
                            snapShot.data!.snapshot.value);
                    return Column(
                      children: [
                        Text(kAudience),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          padding: EdgeInsets.zero,
                          itemBuilder: (BuildContext context, int index) {
                            AuthUser user = AuthUser.fromJson(
                                Map<String, dynamic>.from(
                                    userDetails.values.toList()[index]));
                            if (_currentUser.isModerator!) {
                              return GestureDetector(
                                onTap: () =>
                                    showParticipantOptions(context, user),
                                child: buildParticipant(
                                    imageUrl: user.profilePictureUrl,
                                    name: user.name,
                                    peerId: user.peerId,
                                    isMuted: user.muted,
                                    isModerator: user.isModerator,
                                    isSpeaker: user.isSpeaker)!,
                              );
                            } else {
                              return buildParticipant(
                                  imageUrl: user.profilePictureUrl,
                                  name: user.name,
                                  peerId: user.peerId,
                                  isMuted: user.muted,
                                  isModerator: user.isModerator,
                                  isSpeaker: user.isSpeaker)!;
                            }
                          },
                          itemCount: userDetails.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 10,
                            crossAxisCount: 4,
                            childAspectRatio: 0.5,
                          ),
                        ),
                      ],
                    );
                  }
                }
                return Container();
              },
            )
          ]
        : [Expanded(child: CenterProgressBar())];
  }

  Container? buildParticipant(
      {String? imageUrl,
      String? name,
      String? peerId,
      bool? isMuted = true,
      bool? isModerator = false,
      bool? isSpeaker = false}) {
    // ignore: unnecessary_null_comparison
    if (imageUrl == null && name == null && isMuted == null) {
      print(imageUrl.toString() + name.toString() + isMuted.toString());
      return null;
    }

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
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isModerator != null && isModerator)
                        ? kInRoomBottomBarBgColor
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 30.0,
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
                ),
                (isSpeaker != null && isSpeaker)
                    ? StreamBuilder<List<String>>(
                        stream: context.watch<RTCProvider>().roomsStream,
                        builder: (context, snapShot) {
                          if (snapShot.hasData &&
                              snapShot.data!.contains(peerId)) {
                            return Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: kProfileMutedBgColor,
                              ),
                              child: Icon(
                                isMuted! ? Icons.mic_off_rounded : Icons.mic,
                                color: isMuted
                                    ? kMutedButtonColor
                                    : kUnmutedButtonColor,
                                size: 17,
                              ),
                            );
                          }
                          return Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kProfileMutedBgColor,
                            ),
                            child: Icon(
                              isMuted! ? Icons.mic_off_rounded : Icons.mic_none,
                              color: isMuted
                                  ? kMutedButtonColor
                                  : kUnmutedButtonColor,
                              size: 17,
                            ),
                          );
                        })
                    : Container(),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isModerator != null && isModerator)
                Container(
                  decoration: BoxDecoration(
                    color: kColorGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.stream,
                    size: 15,
                    color: kColorBlack,
                  ),
                ),
              SizedBox(
                width: 5,
              ),
              CustomText(
                text: (name!.indexOf(" ") > 0)
                    ? '${name.substring(0, name.indexOf(" "))}'
                    : '$name',
                fontWeight: FontWeight.bold,
              ),
            ],
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

Column buildRoomHeader(Room room, DatabaseReference fixtureReference,
    DatabaseReference roomReference, AuthUser user) {
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
                          Row(
                            children: [
                              if (room.type == 'private')
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 2, 6, 4),
                                  child: Icon(
                                    Icons.lock,
                                    color: Colors.white54,
                                    size: 16,
                                  ),
                                ),
                              Text(
                                room.name!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          if (room.createdBy!.name != null)
                            Text(
                              'Hosted By: ${room.createdBy!.name}',
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
                        Share.share(
                            '${user.name} is inviting you to virtually watch together ${room.fixture!.teams!.home!.name} Vs ${room.fixture!.teams!.away!.name} match on Match Cafe app.\nJoin Here : ${room.dynamicLink}');
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
                                if (snapShot.data!.snapshot.value != null) {
                                  Map<String, dynamic> members =
                                      new Map<String, dynamic>.from(
                                          snapShot.data!.snapshot.value);

                                  return Text(
                                    '${members.length} $kListeners',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 17,
                                    ),
                                  );
                                }
                              }

                              return Text(
                                '${room.count} $kListeners',
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
                          if (snapShot.data!.snapshot.value != null) {
                            Map<String, dynamic> status =
                                new Map<String, dynamic>.from(
                                    snapShot.data!.snapshot.value);
                            return buildTimerWidget(status, fontSize: 15.0);
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
                    buildTeamIcon(room.fixture!.teams!.home!.logoUrl!),
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
                    buildTeamIcon(room.fixture!.teams!.away!.logoUrl!),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<Event>(
                      stream: fixtureReference.child("events").onValue,
                      builder: (context, snapShot) {
                        if (snapShot.hasData) {
                          if (snapShot.data!.snapshot.value != null) {
                            var events = snapShot.data!.snapshot.value;
                            List<dynamic> matchEvents = events
                                .map((event) => MatchEvent.fromDb(event))
                                .toList() as List<dynamic>;
                            MatchEvent event = matchEvents.last;
                            return buildTimelineEvent(event);
                          }
                        }
                        return Container(
                          child: Text(''),
                        );
                      },
                    ),
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

buildTimelineEvent(MatchEvent event) {
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
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 7,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: new BoxDecoration(
        color: kCardBgColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(40.0)),
      ),
      child: Row(
        children: [
          // Icon( == 'Goal'?),
          Container(
//            decoration: BoxDecoration(
//              shape: BoxShape.circle,
//              color: kCardBgColor,
//            ),
//            padding: EdgeInsets.all(10),
            child: CustomText(
              text: '${event.time.elapsed}\'',
              fontWeight: FontWeight.bold,
              color: kColorGreen,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Row(
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
              SizedBox(
                width: 5,
              ),
              if (event.type != 'Card' &&
                  event.assist.id != -1 &&
                  event.assist.name != '')
                Text(
                  event.type == 'subst'
                      ? '( Sub: ${event.assist.name} )'
                      : '( Assist: ${event.assist.name} )',
                )
              else if (event.type == 'Card')
                Text(
                  '( For: ${event.comments} )',
                ),
            ],
          ),
          SizedBox(
            width: 10,
          ),
          buildEventTypeIcon(icon, color, iconSize: 18),
        ],
      ));
}
