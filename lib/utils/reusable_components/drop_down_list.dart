import 'package:flutter/material.dart';

import '../constants.dart';

class DropDownList extends StatefulWidget {
  final Function(DropDown) onChange;
  final List<DropDown> dropDownList;

  const DropDownList(
      {Key? key, required this.onChange, required this.dropDownList})
      : super(key: key);

  @override
  _DropDownListState createState() => _DropDownListState();
}

class _DropDownListState extends State<DropDownList> {
  late DropDown _selected;

  @override
  void initState() {
    _selected = widget.dropDownList[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: kDropdownBgColor,
            ),
            child: DropdownButton<DropDown>(
              value: _selected,
              isExpanded: true,
              // elevation: 16,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              underline: Container(
                height: 0,
                color: Colors.white,
              ),
              onChanged: (DropDown? newValue) {
                setState(() {
                  _selected = newValue!;
                });
                widget.onChange(newValue!);
              },
              items: widget.dropDownList
                  .map((DropDown dropDown) => DropdownMenuItem<DropDown>(
                        value: dropDown,
                        child: Text(dropDown.value),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class DropDown {
  final String key;
  final String value;

  DropDown(this.key, this.value);
}
