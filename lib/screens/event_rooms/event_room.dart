import 'package:flutter/material.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/InRoomBottomBar.dart';
import 'package:sports_house/utils/reusable_components/RoomsTile.dart';
import 'package:sports_house/utils/reusable_components/RoundedRectangleButton.dart';

class EventRooms extends StatefulWidget {
  EventRooms({Key? key, required this.eventName}) : super(key: key);
  static String pageId = 'EventRooms';
  final String eventName;

  @override
  _EventRoomsState createState() => _EventRoomsState();
}

class _EventRoomsState extends State<EventRooms> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.eventName,
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
        child: Padding(
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
              Column(
                children: [
                  RoomsTile(
                    title: 'The Sharky sport talk',
                    listners: 500,
                    isVerified: true,
                    hostedBy: 'Aswin Divakar',
                    participants: [
                      kDummyProfileImageUrl,
                      kDummyProfileImageUrl,
                      kDummyProfileImageUrl
                    ],
                  ),
                  RoomsTile(
                    title: 'The Sharky sport talk',
                    listners: 500,
                    participants: [kDummyProfileImageUrl],
                  ),
                  RoomsTile(
                    title: 'One Football',
                    listners: 500,
                    participants: [],
                  ),
                ],
              ),
              // Needed for keeping list above bottomNavBar
              SizedBox(
                height: 80,
              ),
            ],
          ),
        ),
      ),
      extendBody: true,
      //TODO : Add logic to show and hide bottomNavigationBar based on In Room / Not in Room conditions
      bottomNavigationBar: InRoomBottomBar(
        room: kDummyRoom,
      ),
    );
  }
}
