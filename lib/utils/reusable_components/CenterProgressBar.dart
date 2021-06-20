import 'package:flutter/material.dart';

class CenterProgressBar extends StatelessWidget {
  const CenterProgressBar();

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}

Widget buildCenterProgressBar(BuildContext context) {
  return CircularProgressIndicator();
}
