import 'package:flutter/material.dart';
import 'package:sports_house/utils/constants.dart';

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
  final List<String> participants;

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
          // color: Colors.white,
          // alignment: Alignment.center,
          width: 90,
          height: 40,
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              if (participants.length > 0)
                buildCircleAvatar(imageUrl: participants[0], left: 50),
              if (participants.length > 1)
                buildCircleAvatar(imageUrl: participants[1], left: 25),
              if (participants.length > 2)
                buildCircleAvatar(imageUrl: participants[2]),
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
        radius: 20,
        foregroundImage: NetworkImage(
          imageUrl,
        ),
      ),
    );
  }
}
