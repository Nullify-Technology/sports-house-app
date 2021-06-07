import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sports_house/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();
  static String pageId = 'HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> getAccessToken() async {
    if(_auth.currentUser != null) {
      User currentUser = _auth.currentUser as User;
      print("idtoken  " + await currentUser.getIdToken(true));
    }
  }

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
      body: FutureBuilder<void>(
        future: getAccessToken(),
        builder:(context, snapshot) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text('Home'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
