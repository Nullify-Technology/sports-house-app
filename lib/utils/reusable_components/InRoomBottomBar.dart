import 'package:flutter/material.dart';
import 'package:sports_house/utils/Room.dart';
import 'package:sports_house/utils/constants.dart';

class InRoomBottomBar extends StatelessWidget {
  const InRoomBottomBar({Key? key, required this.room}) : super(key: key);
  final Room room;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        // height: 75,
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
                Container(
                  // color: Colors.white,
                  // alignment: Alignment.center,
                  width: 100,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      if (room.participants.length > 0)
                        buildCircleAvatar(
                            imageUrl: kDummyParticipants[0], left: 50),
                      if (room.participants.length > 1)
                        buildCircleAvatar(
                            imageUrl: kDummyParticipants[1], left: 25),
                      if (room.participants.length > 2)
                        buildCircleAvatar(imageUrl: kDummyParticipants[2]),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.roomName,
                        maxLines: 1,
                        style: TextStyle(
                          color: kColorBlack,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        room.hostedBy,
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
                    //TODO : Logic to leave Agora chat
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
      ),
    );
  }
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