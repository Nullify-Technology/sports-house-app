import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sports_house/screens/create_room/create_room.dart';
import 'package:sports_house/screens/event_rooms/event_room.dart';
import 'package:sports_house/screens/login/login_screen.dart';
import 'package:sports_house/screens/profile/profile_screen.dart';
import 'package:sports_house/utils/constants.dart';

import 'config/app_config.dart';
import 'screens/home/home_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;

    return MaterialApp(
      title: AppConfig.of(context)!.appTitle,
      theme: ThemeData(
        fontFamily: 'Product Sans',
        colorScheme: ColorScheme.dark().copyWith(
          primary: kColorGreen,
        ),
      ),
      debugShowCheckedModeBanner:
          AppConfig.of(context)!.buildFlavour == kDevelopment,
      routes: {
        LoginScreen.pageId: (context) => LoginScreen(),
        HomeScreen.pageId: (context) => HomeScreen(),
        ProfileScreen.pageId: (context) => ProfileScreen(),
        CreateRoom.pageId: (context) => CreateRoom(),
        // EventRooms.pageId: (context) => EventRooms(),
      },
      initialRoute:
          _auth.currentUser == null ? LoginScreen.pageId : HomeScreen.pageId,
    );
  }
}
