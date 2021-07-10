import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:match_cafe/models/user.dart';
import 'package:match_cafe/utils/constants.dart';
import 'package:match_cafe/utils/reusable_components/custom_text.dart';

class RoomsTile extends StatelessWidget {
  const RoomsTile({
    Key? key,
    required this.title,
    this.isVerified = false,
    this.hostedBy = '',
    required this.listners,
    required this.participants,
    required this.type,
  }) : super(key: key);
  final String title;
  final bool isVerified;
  final String hostedBy;
  final int listners;
  final List<dynamic> participants;
  final String type;

  @override
  Widget build(BuildContext context) {
    print('type : $type');
    return Container(
      child: Card(
        color: kCardBgColor,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                // crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  if (type == 'private')
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
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
                    text: '$listners $kListeners',
                    fontSize: 12,
                  )
                ],
              ),
            ],
          ),
          trailing: participants.isNotEmpty
              ? Container(
                  width: 90,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: buildProfileStack(members: participants),
                  ),
                )
              : Container(
                  width: 90,
                  height: 40,
                ),
        ),
      ),
    );
  }

  List<Widget> buildProfileStack({required List<dynamic> members}) {
    List<Widget> profileStack = [];
    for (var member in members) {
      AuthUser user = AuthUser.fromJson(Map<String, dynamic>.from(member));
      if (profileStack.length == 3) break;
      if (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty) {
        Widget avatar = buildCircleAvatar(
            imageUrl: user.profilePictureUrl ?? '',
            left: profileStack.length * 25.0);
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
