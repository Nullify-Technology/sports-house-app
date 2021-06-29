import 'package:flutter/material.dart';
import 'package:match_cafe/utils/constants.dart';

Widget buildTimerWidget(Map<String, dynamic> status, {double fontSize = 10.0}) {
  bool isStatus = status['short'] != null &&
      (status['short'] != "1H" &&
          status['short'] != "2H" &&
          status['short'] != "ET" &&
          status['short'] != "P");
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: new BoxDecoration(
      color: isStatus ? kCardBgColor : Colors.redAccent,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.all(Radius.circular(40.0)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.timer,
          size: 16,
        ),
        SizedBox(
          width: 4,
        ),
        Text(
          isStatus && status['long'] != null
              ? status['long']
              : status['elapsed'].toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isStatus && status['long'] != null ? 10.0 : fontSize,
          ),
        ),
      ],
    ),
  );
}
