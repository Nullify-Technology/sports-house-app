import 'package:flutter/material.dart';

class RoundedRectangleButton extends StatelessWidget {
  const RoundedRectangleButton({
    Key? key,
    required this.background,
    this.fontSize = 18,
    required this.textColor,
    this.borderRadius = 4.0,
    required this.text,
    this.fontWeight = FontWeight.bold,
    required this.onClick,
  }) : super(key: key);
  final Color background;
  final Color textColor;
  final double fontSize;
  final double borderRadius;
  final String text;
  final FontWeight fontWeight;
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => onClick(),
            style: ElevatedButton.styleFrom(
              primary: background,
              padding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: fontWeight,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
