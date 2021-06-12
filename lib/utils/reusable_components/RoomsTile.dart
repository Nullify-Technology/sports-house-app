import 'package:flutter/material.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/InRoomBottomBar.dart';

class RoomsTile extends StatelessWidget {
  const RoomsTile({
    Key? key,
    required this.title,
    this.isVerified = false,
    this.hostedBy = '',
    required this.listners,
    required this.participants,
  }) : super(key: key);
  final String title;
  final bool isVerified;
  final String hostedBy;
  final int listners;
  final List<AuthUser> participants;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: new BorderSide(
            color: kDropdownBgColor,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
                SizedBox(
                  width: 6,
                ),
                if (isVerified)
                  Icon(
                    Icons.verified,
                    color: kColorGreen,
                    size: 18,
                  ),
              ],
            ),
            if (hostedBy != '')
              Text(
                '$kHostedBy $hostedBy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
          ],
        ),
        // isThreeLine: true,
        subtitle: Column(
          children: [
            SizedBox(
              height: 6,
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
                  '$listners $kListners',
                  style: TextStyle(
                    color: Colors.white54,
                  ),
                )
              ],
            ),
          ],
        ),
        trailing: Container(
          width: 90,
          height: 40,
          child: Stack(
            alignment: Alignment.centerRight,
            children: buildProfileStack(members: participants),
          ),
        ),
      ),
    );
  }

  List<Widget> buildProfileStack({required List<AuthUser> members}) {
    List<Widget> profileStack = [];
    for (AuthUser user in members) {
      if (profileStack.length == 3) break;
      if (user.profilePictureUrl != null &&
          user.profilePictureUrl!.isNotEmpty) {
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
      child: CircleAvatar(
        backgroundColor: kDropdownBgColor,
        radius: 20,
        foregroundImage: NetworkImage(
          imageUrl,
        ),
        onForegroundImageError: (exception, stackTrace) {
          print('Cannot load image!');
        },
      ),
    );
  }
}
