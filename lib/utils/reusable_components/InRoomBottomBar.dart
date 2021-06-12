import 'package:flutter/material.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/provider/agora_provider.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:provider/provider.dart';

class InRoomBottomBar extends StatelessWidget {
  const InRoomBottomBar({Key? key, required this.room}) : super(key: key);
  final Room room;

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Container(
              // color: Colors.white,
              // alignment: Alignment.center,
              width: 100,
              height: 50,
              child: Stack(
                alignment: Alignment.centerRight,
                children: buildProfileStack(members: room.members),
              ),
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
                context.read<AgoraProvider>().leaveRoom(room.id);
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
    );
  }
}

List<Widget> buildProfileStack({required List<AuthUser> members}) {
  List<Widget> profileStack = [];
  for (AuthUser user in members) {
    if (profileStack.length == 3) break;
    if (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty) {
      Widget avatar = buildCircleAvatar(
          imageUrl: user.profilePictureUrl ?? '',
          left: profileStack.length * 25);
      profileStack.add(avatar);
    }
  }
  return profileStack;
}

Widget buildCircleAvatar({required String imageUrl, double left = 0}) {
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
        foregroundImage: NetworkImage(
          imageUrl,
        ),
      ),
    ),
  );
}
