import 'package:flutter/material.dart';
import 'package:sports_house/utils/TrendingEvents.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/RoundedRectangleButton.dart';

class RoomScreen extends StatefulWidget {
  RoomScreen({Key? key, required this.room}) : super(key: key);
  static String pageId = 'CreateRoom';
  final TrendingRoom room;

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  List<String> eventList = [
    'General Chat',
    'MUN Vs BAR',
    'PSG Vs MUN',
    'ATL Vs CAR'
  ];

  String eventName = '';
  String roomType = '';
  @override
  Widget build(BuildContext context) {
    eventName = eventList[0];
    roomType = kRoomTypes[0];
    return Scaffold(
      appBar: AppBar(
        // title: Text(kCreateRoom),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: kColorBlack,
      body: Column(
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
                          children: [
                            Text(
                              widget.room.roomName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                              ),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            if (widget.room.isVerified)
                              Icon(
                                Icons.verified,
                                color: kColorGreen,
                                size: 18,
                              ),
                          ],
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        if (widget.room.hostedBy != '')
                          Text(
                            '$kHostedBy ${widget.room.hostedBy}',
                            style: TextStyle(
                              // color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        SizedBox(
                          height: 10,
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
                              '${widget.room.listners} $kListners',
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
                            buildTeamIcon(widget.room.team1Url),
                            Container(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                widget.room.score,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                            buildTeamIcon(widget.room.team2Url),
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
                      //TODO : @Abhishek Change this row with StreamBuilder
                      Row(
                        children: [
                          Expanded(
                            child: buildParticipant(
                              imageUrl: kDummyImageUrl,
                              name: kDummyUserName,
                            ),
                          ),
                          Expanded(
                            child: buildParticipant(
                              imageUrl: kDummyImageUrl,
                              name: kDummyUserName,
                            ),
                          ),
                          Expanded(
                            child: buildParticipant(
                              imageUrl: kDummyImageUrl,
                              name: kDummyUserName,
                            ),
                          ),
                          Expanded(
                            child: buildParticipant(
                              imageUrl: kDummyImageUrl,
                              name: kDummyUserName,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: kCardBgColor,
        child: Card(
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
          child: TextButton(
            onPressed: () {
              //TODO : Leave Button Action - Should close the Agora Chat
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(primary: Colors.redAccent),
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
        ),
      ),
    );
  }

  Container buildTeamIcon(String url) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: new BoxDecoration(
        color: kCardBgColor,
        shape: BoxShape.circle,
      ),
      child: Image.network(
        url,
        width: 23,
        height: 23,
      ),
    );
  }

  Container buildParticipant({
    required String imageUrl,
    required String name,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            foregroundImage: NetworkImage(
              imageUrl,
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
