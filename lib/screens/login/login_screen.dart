import 'package:flutter/material.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/RoundedRectangleButton.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: kColorBlack,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          Card(
            color: kCardBgColor,
            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: kLoginCardRadius,
                topRight: kLoginCardRadius,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 25,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          kWelcomeToSportsHouse,
                          style: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      labelText: kPhone,
                      hintText: kEnterPhoneNumber,
                      fillColor: kTextFieldBgColor,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return kInvalidPhone;
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                    onSaved: (phone) {},
                    onFieldSubmitted: (v) {},
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RoundedRectangleButton(
                    background: kColorGreen,
                    text: kLoginButtonText,
                    textColor: kColorBlack,
                  ),
                ],
              ),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
