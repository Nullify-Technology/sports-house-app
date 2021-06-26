import 'package:flutter/material.dart';
import 'package:match_cafe/utils/constants.dart';

Column buildSquadDetailsUnavilable({
   BuildContext context,
   IconData icon,
  double bottomPadding = 70,
   String error,
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
