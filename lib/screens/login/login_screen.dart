import 'package:flutter/material.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/RoundedRectangleButton.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen();

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late TabController _controller;
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: kColorBlack,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/login_image.png',
                width: 500,
              ),
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
              height: 250,
              child: TabBarView(
                controller: _controller,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  buildPhoneNumberTab(),
                  buildOtpTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPhoneNumberTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
              letterSpacing: 2,
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
            text: kSendOtp,
            textColor: kColorBlack,
            onClick: () {
              _controller.animateTo(_selectedIndex = 1);
            },
          ),
        ],
      ),
    );
  }

  Widget buildOtpTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    _controller.animateTo(_selectedIndex = 0);
                  },
                  icon: Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      kWelcomeToSportsHouse,
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 24,
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
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              filled: true,
              border: OutlineInputBorder(),
              labelText: kOtp,
              fillColor: kTextFieldBgColor,
            ),
            textAlign: TextAlign.center,
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
            onClick: () {},
          ),
        ],
      ),
    );
  }
}
