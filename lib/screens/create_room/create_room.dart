import 'package:flutter/material.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/RoundedRectangleButton.dart';

class CreateRoom extends StatefulWidget {
  CreateRoom({Key? key}) : super(key: key);
  static String pageId = 'CreateRoom';

  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  List<String> eventList = [
    'General Chat',
    'MUN Vs BAR',
    'PSG Vs MUN',
    'ATL Vs CAR'
  ];

  String eventName = '';
  String roomType = '';
  @override
  Widget build(BuildContext context) {
    eventName = eventList[0];
    roomType = kRoomTypes[0];
    return Scaffold(
      appBar: AppBar(
        title: Text(kCreateRoom),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: kColorBlack,
      body: Card(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        color: kCardBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: kCreateRoomCardRadius,
            topRight: kCreateRoomCardRadius,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kColorGreen,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                      labelText: kRoomName,
                      hintText: kEnterRoomName,
                      fillColor: kDropdownBgColor,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return kNameCannotBeEmpty;
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    onSaved: (roomName) {},
                    onFieldSubmitted: (v) {},
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  buildDropDown(
                    values: eventList,
                    initialValue: eventName,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  buildDropDown(
                    values: kRoomTypes,
                    initialValue: roomType,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
              RoundedRectangleButton(
                background: kColorGreen,
                textColor: kTextFieldBgColor,
                text: kCreateRoom,
                onClick: () {},
              )
            ],
          ),
        ),
      ),
    );
  }

  Row buildDropDown({
    required values,
    required initialValue,
  }) {
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
            child: DropdownButton<String>(
              value: initialValue,
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
              onChanged: (String? newValue) {
                setState(() {
                  eventName = newValue!;
                });
              },
              items: values.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
