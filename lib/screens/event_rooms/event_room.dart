import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sports_house/blocs/rooms_bloc.dart';
import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/models/response.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/provider/agora_provider.dart';
import 'package:sports_house/provider/rtc_provider.dart';
import 'package:sports_house/provider/user_provider.dart';
import 'package:sports_house/screens/create_room/create_room.dart';
import 'package:sports_house/screens/room_screen/room_screen.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/InRoomBottomBar.dart';
import 'package:sports_house/utils/reusable_components/RoomsTile.dart';
import 'package:provider/provider.dart';

class EventRoomsArguments {
  final String fixtureId;
  final String eventName;

  EventRoomsArguments(this.fixtureId, this.eventName);
}

class EventRooms extends StatefulWidget {
  final EventRoomsArguments arguments;
  EventRooms({Key? key, required this.arguments}) : super(key: key);
  static String pageId = 'EventRooms';

  @override
  _EventRoomsState createState() => _EventRoomsState();
}

class _EventRoomsState extends State<EventRooms> {
  late RoomsBloc roomsBloc;
  late AuthUser currentUser;
    late DatabaseReference fixtureReference =
      FirebaseDatabase(databaseURL: kRTDBUrl)
          .reference()
          .child("fixture")
          .child("fixture_${widget.arguments.fixtureId}");
  Future joinRoom(Room room) async {
    try {
      // AgoraRoom agoraRoom = await roomsBloc.joinRoom(room.id) as AgoraRoom;

      Navigator.pushNamed(context, RoomScreen.pageId,
          arguments: RoomScreenArguments(room));
    } catch (e) {
      print("failed to join room");
    }
  }

  @override
  void initState() {
    currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser!;
    roomsBloc = RoomsBloc(client: RestClient.create());
    roomsBloc.getRooms(widget.arguments.fixtureId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBlack,
      extendBody: true,
      // bottomNavigationBar: buildBottomNavigationBar(context),
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
                    child: buildRoomHeader(widget.arguments.room),
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
                Container(),
                buildMatchTimeline(
                  widget.arguments.,
                ),
                buildMatchXI(widget.arguments.room),
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
              children: [
                SizedBox(
                  height: 6,
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildTeamIcon(fixture.teams.home.logoUrl),
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
                    buildTeamIcon(fixture.teams.away.logoUrl),
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


  Widget buildRoomList(List<Room> rooms) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.podcasts,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                kRooms,
                style: TextStyle(
                  fontSize: kHeadingFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          if (rooms.length > 0)
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  child: RoomsTile(
                    title: rooms[index].name,
                    listners: rooms[index].count,
                    participants: rooms[index].members,
                    hostedBy: rooms[index].createdBy.name ?? '',
                  ),
                  onTap: () => joinRoom(rooms[index]),
                );
              },
            )
          else
            buildNoRoomsAvailableError(),
          // Needed for keeping list above bottomNavBar
          SizedBox(
            height: 80,
          ),
        ],
      ),
    );
  }

  Expanded buildNoRoomsAvailableError() {
    return Expanded(
      child: Column(
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
      ),
    );
  }
}
