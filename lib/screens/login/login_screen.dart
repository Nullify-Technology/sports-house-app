import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sports_house/screens/home/home_screen.dart';
import 'package:sports_house/screens/profile/profile_screen.dart';
import 'package:sports_house/services/auth_service.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/CenterProgressBar.dart';
import 'package:sports_house/utils/reusable_components/RoundedRectangleButton.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen();
  static String pageId = 'LoginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late TabController _controller;
  int _selectedIndex = 0;
  final GlobalKey<FormState> _phoneNumberFormKey = GlobalKey();
  final GlobalKey<FormState> _otpFormKey = GlobalKey();
  final GlobalKey<FormState> _progressFormKey = GlobalKey();
  final AuthService service = new AuthService();

  void signInWithPhoneNumber(String phoneNumber) async {
    try {
      await service.signInWithPhoneNumber(phoneNumber);
      _controller.animateTo(_selectedIndex = 2);
    } catch (e) {
      print(e);
    }
  }

  void verifyOtp(String otp) async {
    try {
      User user = await service.verifyOtp(otp);
      print("Successfully signed in UID: ${user.uid}");
      if (user.uid.isNotEmpty) {
        Navigator.popAndPushNamed(context, ProfileScreen.pageId);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 3,
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
                  buildProgressBarTab(),
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
      child: Form(
        key: _phoneNumberFormKey,
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
                prefix: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Text("+91"),
                ),
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
              onSaved: (phone) {
                _controller.animateTo(_selectedIndex = 1);
                signInWithPhoneNumber(phone as String);
              },
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
                FocusScope.of(context).unfocus();
                if (!_phoneNumberFormKey.currentState!.validate()) {
                  return;
                }
                _phoneNumberFormKey.currentState!.save();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOtpTab() {
    return Form(
      key: _otpFormKey,
      child: Padding(
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
              onSaved: (otp) {
                _controller.animateTo(_selectedIndex = 1);
                verifyOtp(otp as String);
              },
              onFieldSubmitted: (v) {},
            ),
            SizedBox(
              height: 20,
            ),
            RoundedRectangleButton(
              background: kColorGreen,
              text: kLoginButtonText,
              textColor: kColorBlack,
              onClick: () {
                FocusScope.of(context).unfocus();
                if (!_otpFormKey.currentState!.validate()) {
                  return;
                }
                _otpFormKey.currentState!.save();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProgressBarTab() {
    return Form(
      key: _progressFormKey,
      child: CenterProgressBar(),
    );
  }
}
