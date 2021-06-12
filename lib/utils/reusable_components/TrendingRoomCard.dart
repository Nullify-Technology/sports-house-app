import 'package:flutter/material.dart';
import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/screens/event_rooms/event_room.dart';
import 'package:sports_house/screens/room_screen/room_screen.dart';
import 'package:sports_house/utils/Room.dart';
import 'package:sports_house/utils/constants.dart';

class TrendingRoomCard extends StatelessWidget {
  const TrendingRoomCard({
    Key? key,
    required this.room,required this.onTap,
  }) : super(key: key);
  final Room room;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap(),
      child: Card(
        color: kTrendingCardBgColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(15),
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
                        room.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      if (false)
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
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (room.members.length > 0)
                    Expanded(
                      child: Container(
                        // alignment: Alignment.center,
                        height: 55,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (room.members.length > 0 &&
                                room.members[0].profilePictureUrl != null)
                              buildCircleAvatar(
                                imageUrl:
                                    room.members[0].profilePictureUrl ?? '',
                                left: MediaQuery.of(context).size.width * 0.22,
                              ),
                            if (room.members.length > 1 &&
                                room.members[1].profilePictureUrl != null)
                              buildCircleAvatar(
                                imageUrl:
                                    room.members[1].profilePictureUrl ?? '',
                                left: MediaQuery.of(context).size.width * 0.30,
                              ),
                            if (room.members.length > 2 &&
                                room.members[2].profilePictureUrl != null)
                              buildCircleAvatar(
                                imageUrl:
                                    room.members[2].profilePictureUrl ?? '',
                                left: MediaQuery.of(context).size.width * 0.38,
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (room.createdBy.name != '')
                        Text(
                          '$kHostedBy ${room.createdBy.name}',
                          style: TextStyle(
                            // color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildTeamIcon(room.fixture.teams.home.logoUrl),
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          kVersus,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      buildTeamIcon(room.fixture.teams.away.logoUrl),
                    ],
                  ),
                  // Text(
                  //   room.eventName,
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
      ),
    );
  }

  Widget buildCircleAvatar({required String imageUrl, double left = 0}) {
    return Positioned(
      left: left,
      child: CircleAvatar(
        backgroundColor: kDropdownBgColor,
        radius: 25,
        foregroundImage: NetworkImage(
          imageUrl,
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
}
