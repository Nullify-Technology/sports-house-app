import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/provider/rtc_provider.dart';
import 'package:sports_house/screens/room_screen/room_screen.dart';
import 'package:sports_house/utils/constants.dart';

class InRoomBottomBar extends StatelessWidget {
  const InRoomBottomBar({Key key,  this.room}) : super(key: key);
  final Room room;


  @override
  Widget build(BuildContext context) {
    DatabaseReference roomReference = FirebaseDatabase(databaseURL: kRTDBUrl)
        .reference()
        .child(kRTCRoom)
        .child(room.id);
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RoomScreen.pageId,
            arguments: RoomScreenArguments(room));
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        clipBehavior: Clip.hardEdge,
        color: kInRoomBottomBarBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          child: Row(
            children: [
              StreamBuilder<Event>(
                stream: roomReference.onValue,
                builder: (context, snapShot) {
                  if (snapShot.hasData) {
                    if (snapShot.data.snapshot.value != null) {
                      Map<String, dynamic> userDetails =
                      new Map<String, dynamic>.from(
                          snapShot.data.snapshot.value);
                      return Container(
                        width: 100,
                        height: 50,
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: buildProfileStack(members: userDetails.values.toList()),
                        ),
                      );
                    }
                  }
                  return Container(
                    width: 100,
                    height: 50,
                  );
                },
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      maxLines: 1,
                      style: TextStyle(
                        color: kColorBlack,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$kHostedBy ${room.createdBy.name}',
                      maxLines: 1,
                      style: TextStyle(
                        color: kColorBlack,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<RTCProvider>().leaveRoom(room.id);
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: new BoxDecoration(
                    color: kCloseButtonBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.red.shade300,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

List<Widget> buildProfileStack({List<dynamic> members}) {

  List<Widget> profileStack = [];
  for (var member in members) {
    if (profileStack.length == 3) break;
    AuthUser user = AuthUser.fromJson(
        Map<String, dynamic>.from(member));
    if (user.profilePictureUrl != null && user.profilePictureUrl.isNotEmpty) {
      Widget avatar = buildCircleAvatar(
          imageUrl: user.profilePictureUrl ?? '',
          left: profileStack.length * 25.0);
      profileStack.add(avatar);
    }
  }
  return profileStack;
}

Widget buildCircleAvatar({ String imageUrl, double left = 0}) {
  return Positioned(
    left: left,
    child: Container(
      padding: EdgeInsets.all(3),
      decoration: new BoxDecoration(
        color: kProfileBgColor,
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        backgroundColor: kDropdownBgColor,
        radius: 18,
        backgroundImage: AssetImage(
          kProfilePlaceHolder,
        ),
        foregroundImage: CachedNetworkImageProvider(
          imageUrl,
        ),
        onForegroundImageError: (exception, stackTrace) {
          print(exception);
        },
      ),
    ),
  );
}
