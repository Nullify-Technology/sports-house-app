import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/InRoomBottomBar.dart';
import 'package:sports_house/utils/reusable_components/custom_text.dart';

class RoomsTile extends StatelessWidget {
  const RoomsTile({
    Key key,
     this.title,
    this.isVerified = false,
    this.hostedBy = '',
     this.listners,
     this.participants,
  }) : super(key: key);
  final String title;
  final bool isVerified;
  final String hostedBy;
  final int listners;
  final List<AuthUser> participants;

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   border: Border(
      //     bottom: new BorderSide(
      //       color: kDropdownBgColor,
      //     ),
      //   ),
      // ),
      child: Card(
        color: kCardBgColor,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  if (isVerified)
                    Icon(
                      Icons.verified,
                      color: kColorGreen,
                      size: 16,
                    ),
                ],
              ),
              if (hostedBy != '')
                Text(
                  '$kHostedBy $hostedBy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          // isThreeLine: true,
          subtitle: Column(
            children: [
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Icon(
                    Icons.hearing,
                    size: 12,
                    color: Colors.white54,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  CustomText(
                    text: '$listners $kListners',
                    fontSize: 12,
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
      ),
    );
  }

  List<Widget> buildProfileStack({ List<AuthUser> members}) {
    List<Widget> profileStack = [];
    for (AuthUser user in members) {
      if (profileStack.length == 3) break;
      if (user.profilePictureUrl != null &&
          user.profilePictureUrl.isNotEmpty) {
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
      child: CircleAvatar(
        backgroundColor: kDropdownBgColor,
        radius: 20,
        backgroundImage: AssetImage(kProfilePlaceHolder),
        foregroundImage: CachedNetworkImageProvider(
          imageUrl,
        ),
        onForegroundImageError: (exception, stackTrace) {
          print('Cannot load image!');
        },
      ),
    );
  }
}
