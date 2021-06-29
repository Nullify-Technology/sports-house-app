import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:match_cafe/models/agora_room.dart';
import 'package:match_cafe/models/room.dart';
import 'package:match_cafe/models/user.dart';
import 'package:match_cafe/screens/event_rooms/event_room.dart';
import 'package:match_cafe/screens/room_screen/room_screen.dart';
import 'package:match_cafe/utils/constants.dart';

class TrendingRoomCard extends StatelessWidget {
  const TrendingRoomCard({
    Key key,
    this.room,
  }) : super(key: key);
  final Room room;

  @override
  Widget build(BuildContext context) {
    DatabaseReference roomReference = FirebaseDatabase(databaseURL: kRTDBUrl)
        .reference()
        .child(kRTCRoom)
        .child(room.id);

    return Card(
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
                    if (room.type == 'private')
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 2, 6, 5),
                        child: Icon(
                          Icons.lock,
                          color: Colors.white54,
                          size: 16,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        room.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                StreamBuilder<Event>(
                  stream: roomReference.onValue,
                  builder: (context, snapShot) {
                    if (snapShot.hasData) {
                      if (snapShot.data.snapshot.value != null) {
                        Map<String, dynamic> userDetails =
                            new Map<String, dynamic>.from(
                                snapShot.data.snapshot.value);
                        return Row(
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
                              '${userDetails.length} $kListeners',
                              style: TextStyle(
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        );
                      }
                    }
                    return Container();
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (room.members.length > 0)
                  Container(
                    alignment: Alignment.center,
                    width: 100,
                    // color: Colors.white,
                    height: 55,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: buildProfileStack(members: room.members),
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
    );
  }

  List<Widget> buildProfileStack({List<AuthUser> members}) {
    List<Widget> profileStack = [];
    for (AuthUser user in members) {
      if (profileStack.length == 3) break;
      if (user.profilePictureUrl != null && user.profilePictureUrl.isNotEmpty) {
        Widget avatar = buildCircleAvatar(
            imageUrl: user.profilePictureUrl ?? '',
            left: profileStack.length * 25.0);
        profileStack.add(avatar);
      }
    }
    return profileStack;
  }

  Widget buildCircleAvatar({String imageUrl, double left = 0}) {
    return Positioned(
      left: left,
      child: CircleAvatar(
        backgroundColor: kDropdownBgColor,
        radius: 25,
        backgroundImage: AssetImage(kProfilePlaceHolder),
        foregroundImage: CachedNetworkImageProvider(
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
      child: CachedNetworkImage(
        imageUrl: url,
        // placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.flag),
        width: 23,
        height: 23,
      ),
    );
  }
}
