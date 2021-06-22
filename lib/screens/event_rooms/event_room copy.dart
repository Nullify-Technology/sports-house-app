import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sports_house/blocs/rooms_bloc.dart';
import 'package:sports_house/models/agora_room.dart';
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
  EventRooms({Key key, this.arguments}) : super(key: key);
  static String pageId = 'EventRooms';

  @override
  _EventRoomsState createState() => _EventRoomsState();
}

class _EventRoomsState extends State<EventRooms> {
  RoomsBloc roomsBloc;
  AuthUser currentUser;
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
    currentUser = Provider.of<UserProvider>(context, listen: false).currentUser;
    roomsBloc = RoomsBloc(client: RestClient.create());
    roomsBloc.getRooms(widget.arguments.fixtureId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.arguments.eventName,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: kColorBlack,
      body: Card(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        color: kCardBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: kCreateRoomCardRadius,
            topRight: kCreateRoomCardRadius,
          ),
        ),
        child: StreamBuilder<Response<List<Room>>>(
          stream: roomsBloc.roomsStream,
          builder: (context, snapShot) {
            if (snapShot.hasData) {
              switch (snapShot.data.status) {
                case Status.LOADING:
                case Status.ERROR:
                  return Container();
                case Status.COMPLETED:
                  return buildRoomList(snapShot.data.data);
              }
            }
            return Container();
          },
        ),
      ),
      extendBody: true,
      bottomNavigationBar: context.watch<RTCProvider>().joined
          ? InRoomBottomBar(
              room: context.watch<RTCProvider>().room,
            )
          : null,
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
