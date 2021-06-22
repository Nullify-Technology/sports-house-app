import 'package:flutter/material.dart';

class RoundedRectangleButton extends StatelessWidget {
  const RoundedRectangleButton({
    Key key,
     this.background,
    this.fontSize = 18,
     this.textColor,
    this.borderRadius = 4.0,
     this.text,
    this.fontWeight = FontWeight.bold,
     this.onClick,
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
