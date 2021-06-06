import 'package:flutter/material.dart';
import 'package:sports_house/screens/home/home_screen.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/CenterProgressBar.dart';
import 'package:sports_house/utils/reusable_components/RoundedRectangleButton.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen();
  static String pageId = 'ProfileScreen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: kColorBlack,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(appName),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading ? CenterProgressBar() : buildProfileScreen(context),
    );
  }

  Widget buildProfileScreen(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                child: GestureDetector(
                  child: CircleAvatar(
                    backgroundColor: kCardBgColor,
                    maxRadius: MediaQuery.of(context).size.width * .25,
                    minRadius: MediaQuery.of(context).size.width * .25,
                    foregroundImage: AssetImage(
                      'assets/images/profile_soccer.png',
                    ),
                  ),
                  onTap: () {
                    //Code to handle image selection
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(25),
                child: Text(
                  kProfileText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // color: kColorGreen,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        Card(
          color: kCardBgColor,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: kLoginCardRadius,
              topRight: kLoginCardRadius,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 25),
            child: Form(
              // key: _phoneNumberFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      labelText: kName,
                      hintText: kEnterYourName,
                      fillColor: kTextFieldBgColor,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return kNameCannotBeEmpty;
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    onSaved: (name) {},
                    onFieldSubmitted: (v) {},
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RoundedRectangleButton(
                    background: kColorGreen,
                    text: kProfileScreenButtonText,
                    textColor: kColorBlack,
                    onClick: () {
                      setState(() {
                        _isLoading = true;
                      });
                      Navigator.popAndPushNamed(context, HomeScreen.pageId);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
