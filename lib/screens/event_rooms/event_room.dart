import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:match_cafe/blocs/rooms_bloc.dart';
import 'package:match_cafe/helper/life_cycle_event_handler.dart';
import 'package:match_cafe/models/fixture.dart';
import 'package:match_cafe/models/response.dart';
import 'package:match_cafe/models/room.dart';
import 'package:match_cafe/models/user.dart';
import 'package:match_cafe/network/rest_client.dart';
import 'package:match_cafe/provider/rtc_provider.dart';
import 'package:match_cafe/provider/user_provider.dart';
import 'package:match_cafe/screens/create_room/create_room.dart';
import 'package:match_cafe/screens/room_screen/room_screen.dart';
import 'package:match_cafe/screens/room_screen/squad_tab.dart';
import 'package:match_cafe/screens/room_screen/timeline_tab.dart';
import 'package:match_cafe/screens/room_screen/timer_widget.dart';
import 'package:match_cafe/utils/classes/event_classes.dart';
import 'package:match_cafe/utils/constants.dart';
import 'package:match_cafe/utils/reusable_components/CenterProgressBar.dart';
import 'package:match_cafe/utils/reusable_components/InRoomBottomBar.dart';
import 'package:match_cafe/utils/reusable_components/KeepAliveTab.dart';
import 'package:match_cafe/utils/reusable_components/RoomsTile.dart';
import 'package:provider/provider.dart';
import 'package:match_cafe/utils/reusable_components/custom_text.dart';

class EventRoomsArguments {
  final Fixture fixture;

  EventRoomsArguments(this.fixture);
}

class EventRooms extends StatefulWidget {
  final EventRoomsArguments arguments;
  EventRooms({Key key, this.arguments}) : super(key: key);
  static String pageId = 'EventRooms';

  @override
  _EventRoomsState createState() => _EventRoomsState();
}

class _EventRoomsState extends State<EventRooms> {
  RoomsBloc roomsBloc;
  AuthUser currentUser;
  DatabaseReference fixtureReference;

  @override
  void initState() {
    currentUser = Provider.of<UserProvider>(context, listen: false).currentUser;
    fixtureReference = FirebaseDatabase(databaseURL: kRTDBUrl)
        .reference()
        .child("fixture")
        .child("fixture_${widget.arguments.fixture.id}");
    roomsBloc = RoomsBloc(client: RestClient.create());
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
        resumeCallBack: () => roomsBloc.getRooms(widget.arguments.fixture.id)));
    roomsBloc.getRooms(widget.arguments.fixture.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBlack,
      extendBody: true,
      bottomNavigationBar: context.watch<RTCProvider>().joined
          ? InRoomBottomBar(
              room: context.watch<RTCProvider>().room,
            )
          : null,
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
                  '${widget.arguments.fixture.teams.home.name} Vs ${widget.arguments.fixture.teams.away.name}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  // centerTitle: true,
                  background: Padding(
                    padding:
                        const EdgeInsets.only(top: 70, left: 15, right: 15),
                    child: buildRoomHeader(
                        widget.arguments.fixture, fixtureReference),
                  ),
                ),
                bottom: TabBar(
                  indicatorColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: BoxDecoration(),
                  tabs: <Widget>[
                    Tab(
                      icon: Icon(Icons.groups),
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
                KeepAliveTab(
                  child: StreamBuilder<Response<List<Room>>>(
                    stream: roomsBloc.roomsStream,
                    builder: (context, snapShot) {
                      if (snapShot.hasData) {
                        switch (snapShot.data.status) {
                          case Status.LOADING:
                            return Container(
                              height: MediaQuery.of(context).size.width,
                              child: CenterProgressBar(),
                            );
                          case Status.ERROR:
                            return Container();
                          case Status.COMPLETED:
                            return buildRoomList(snapShot.data.data);
                        }
                      }
                      return Container(
                        height: MediaQuery.of(context).size.width,
                        child: CenterProgressBar(),
                      );
                    },
                  ),
                ),
                KeepAliveTab(
                    child: buildMatchTimeline(
                        widget.arguments.fixture, fixtureReference)),
                KeepAliveTab(
                    child: buildMatchXI(widget.arguments.fixture, context)),
                // buildSubstitutesHomeAndAway(widget.arguments.agoraRoom.room),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column buildRoomHeader(Fixture fixture, DatabaseReference fixtureReference) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: Center(),
            ),
            StreamBuilder<Event>(
              stream: fixtureReference.child("status").onValue,
              builder: (context, snapShot) {
                if (snapShot.hasData) {
                  if (snapShot.data.snapshot.value != null) {
                    Map<String, dynamic> status = new Map<String, dynamic>.from(
                        snapShot.data.snapshot.value);

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
                    // mainAxisSize: MainAxisSize.min,
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
            Expanded(
              child: Center(),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTeamIcon(fixture.teams.home.logoUrl, size: 60.0),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: 14,
                  ),
                  // decoration: new BoxDecoration(
                  //   color: kCardBgColor,
                  //   shape: BoxShape.rectangle,
                  //   borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  // ),
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
                              CustomText(
                                text: '${score["home"]} - ${score["away"]}',
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
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
              ],
            ),
            buildTeamIcon(fixture.teams.away.logoUrl, size: 60.0),
          ],
        ),
        SizedBox(height: 5),
        Divider(
          thickness: 2,
          indent: 150,
          endIndent: 150,
        ),
        CustomText(
          text:
              "${widget.arguments.fixture.venue.name ?? ''} - ${widget.arguments.fixture.venue.city ?? ''}",
          fontSize: 12,
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
                  if (snapShot.data.snapshot.value != null) {
                    var events = snapShot.data.snapshot.value;
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
        SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget buildRoomList(List<Room> rooms) {
    if (rooms.length > 0)
      return Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: rooms.length,
          padding: EdgeInsets.only(bottom: 80),
          itemBuilder: (context, index) {
            DatabaseReference roomReference =
                FirebaseDatabase(databaseURL: kRTDBUrl)
                    .reference()
                    .child(kRTCRoom)
                    .child(rooms[index].id);

            return StreamBuilder<Event>(
              stream: roomReference.onValue,
              builder: (context, snapShot) {
                if (snapShot.hasData) {
                  if (snapShot.data.snapshot.value != null) {
                    Map<String, dynamic> userDetails =
                        new Map<String, dynamic>.from(
                            snapShot.data.snapshot.value);
                    return GestureDetector(
                        child: RoomsTile(
                          title: rooms[index].name,
                          listners: userDetails.length,
                          participants: userDetails.values.toList(),
                          hostedBy: rooms[index].createdBy.name ?? '',
                          type: rooms[index].type,
                        ),
                        onTap: () => Navigator.pushNamed(
                            context, RoomScreen.pageId,
                            arguments: RoomScreenArguments(
                                rooms[index])) //joinRoom(rooms[index]),
                        );
                  }
                }
                return GestureDetector(
                    child: RoomsTile(
                      title: rooms[index].name,
                      listners: 0,
                      participants: [],
                      hostedBy: rooms[index].createdBy.name ?? '',
                      type: rooms[index].type,
                    ),
                    onTap: () => Navigator.pushNamed(context, RoomScreen.pageId,
                        arguments: RoomScreenArguments(
                            rooms[index])) //joinRoom(rooms[index]),
                    );
              },
            );
          },
        ),
      );
    else
      return buildNoRoomsAvailableError();
  }

  Column buildNoRoomsAvailableError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Image.asset(
          'assets/images/no_rooms_found.png',
          width: MediaQuery.of(context).size.width * 0.6,
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          kNoRoomsFound,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            // fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, CreateRoom.pageId);
          },
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            primary: kColorGreen,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              kCreateRoom,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: kCardBgColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
