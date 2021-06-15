import 'package:flutter/material.dart';
import 'package:sports_house/utils/constants.dart';

Column buildSquadDetailsUnavilable({
  required BuildContext context,
  required IconData icon,
  double bottomPadding = 70,
  required String error,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    children: [
      Icon(
        icon,
        size: MediaQuery.of(context).size.width * 0.25,
        color: Colors.white54,
      ),
      SizedBox(height: 10),
      Text(
        error,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white54,
        ),
      ),
      SizedBox(height: bottomPadding),
    ],
  );
}
