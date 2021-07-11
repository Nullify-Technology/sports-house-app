import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:match_cafe/screens/profile/profile_screen.dart';
import 'package:match_cafe/utils/constants.dart';
import 'package:match_cafe/utils/reusable_components/CenterProgressBar.dart';
import 'package:match_cafe/utils/reusable_components/RoundedRectangleButton.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen();
  static String pageId = 'LoginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
   TabController? _controller;
   String? _verificationId;
  final GlobalKey<FormState> _phoneNumberFormKey = GlobalKey();
  final GlobalKey<FormState> _otpFormKey = GlobalKey();

  void signInWithPhoneNumber(String phoneNumber) async {
    _controller!.animateTo(1);

    PhoneVerificationFailed phoneVerificationFailed =
        (FirebaseAuthException authException) {
      _controller!.animateTo(0);
      final snackBar = SnackBar(content: Text(kInvalidPhoneNumber));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print(
          'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
    };

    PhoneVerificationCompleted phoneVerificationCompleted =
        (PhoneAuthCredential credentials) async {
      final User user =
          (await _auth.signInWithCredential(credentials)).user as User;
      print("Successfully signed in UID: ${user.uid}");
      if (user.uid.isNotEmpty) {
        Navigator.popAndPushNamed(context, ProfileScreen.pageId);
      }
    };

    PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      this._verificationId = verificationId;
      _controller!.animateTo(2);
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this._verificationId = verificationId;
      // _controller.animateTo(0);
      print("timeout");
    };

    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: "+91" + phoneNumber,
          verificationCompleted: phoneVerificationCompleted,
          verificationFailed: phoneVerificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      final snackBar = SnackBar(content: Text(kOtpFailed));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print(e);
    }
  }

  void verifyOtp(String otp) async {
    _controller!.animateTo(1);
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: this._verificationId!, smsCode: otp);
      final User user =
          (await _auth.signInWithCredential(credential)).user as User;
      print("Successfully signed in UID: ${user.uid}");
      if (user.uid.isNotEmpty) {
        Navigator.popAndPushNamed(context, ProfileScreen.pageId);
      }
    } catch (e) {
      final snackBar = SnackBar(content: Text(kInvalidOtp));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _controller!.animateTo(2);
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
    _controller!.dispose();
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
                      _controller!.animateTo(0);
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
    return CenterProgressBar();
  }
}
