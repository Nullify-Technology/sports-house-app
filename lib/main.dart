import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sports_house/screens/create_room/create_room.dart';
import 'package:sports_house/screens/login/login_screen.dart';
import 'package:sports_house/screens/profile/profile_screen.dart';
import 'package:sports_house/utils/constants.dart';

import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports House',
      theme: ThemeData(
        fontFamily: 'Product Sans',
        colorScheme: ColorScheme.dark().copyWith(
          primary: kColorGreen,
        ),
      ),
      // home: MyHomePage(title: 'Sports House'),
      routes: {
        LoginScreen.pageId: (context) => LoginScreen(),
        HomeScreen.pageId: (context) => HomeScreen(),
        ProfileScreen.pageId: (context) => ProfileScreen(),
        CreateRoom.pageId: (context) => CreateRoom(),
      },
      initialRoute:
          _auth.currentUser == null ? LoginScreen.pageId : HomeScreen.pageId,
    );
  }
}
