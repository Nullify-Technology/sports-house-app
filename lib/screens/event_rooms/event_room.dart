import 'package:flutter/material.dart';
import 'package:sports_house/blocs/rooms_bloc.dart';
import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/response.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/screens/room_screen/room_screen.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/InRoomBottomBar.dart';
import 'package:sports_house/utils/reusable_components/RoomsTile.dart';

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

  Future joinRoom(Room room) async {
    try {
      AgoraRoom agoraRoom = await roomsBloc.joinRoom(room.id) as AgoraRoom;
      Navigator.pushNamed(
          context, RoomScreen.pageId, arguments: RoomScreenArguments(agoraRoom)
      );
    }catch(e){
      print("failed to join room");
    }
  }

  @override
  void initState() {
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
              switch (snapShot.data!.status) {
                case Status.LOADING:
                case Status.ERROR:
                  return Container();
                case Status.COMPLETED:
                  return buildRoomList(snapShot.data!.data);
              }
            }
            return Container();
          },
        ),
      ),
      extendBody: true,
      //TODO : Add logic to show and hide bottomNavigationBar based on In Room / Not in Room conditions
      bottomNavigationBar: InRoomBottomBar(
        room: kDummyRoom,
      ),
    );
  }

  Widget buildRoomList(List<Room> rooms) {
    return Padding(
      padding: const EdgeInsets.all(30),
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
          ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: rooms.length,
            itemBuilder: (context, index){
              return GestureDetector(
                child: RoomsTile(
                  title: rooms[index].name,
                  listners: rooms[index].count,
                  participants: [],
                ),

                onTap: () => joinRoom(rooms[index])
              );
            },
          ),
          // Needed for keeping list above bottomNavBar
          SizedBox(
            height: 80,
          ),
        ],
      ),
    );
  }
}
