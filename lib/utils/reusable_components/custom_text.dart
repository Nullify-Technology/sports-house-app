import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText(
      {Key? key,
      this.text = '',
      this.fontWeight = FontWeight.normal,
      this.fontSize = 14,
      this.color})
      : super(key: key);
  final String text;
  final FontWeight fontWeight;
  final double fontSize;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
