import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_house/models/tournament.dart';
import 'package:sports_house/provider/agora_provider.dart';
import 'package:sports_house/provider/rtc_provider.dart';
import 'package:sports_house/provider/user_provider.dart';
import 'package:sports_house/screens/create_room/create_room.dart';
import 'package:sports_house/screens/event_rooms/event_room.dart';
import 'package:sports_house/screens/login/login_screen.dart';
import 'package:sports_house/screens/profile/profile_screen.dart';
import 'package:sports_house/screens/room_screen/room_screen.dart';
import 'package:sports_house/screens/tournament/tournament.dart';
import 'package:sports_house/utils/constants.dart';

import 'blocs/rooms_bloc.dart';
import 'config/app_config.dart';
import 'models/agora_room.dart';
import 'models/room.dart';
import 'network/rest_client.dart';
import 'screens/home/home_screen.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;
    // FirebaseDatabase(databaseURL: kRTDBUrl).reference().child("rtc_rooms").onChildRemoved.listen((event) {
    //   print("removed child ${event.snapshot.key}");
    // });

    FirebaseDatabase(databaseURL: kRTDBUrl)
        .reference()
        .child("rtc_rooms")
        .onChildAdded
        .listen((event) {
      print("added child ${event.snapshot.value}");
    });
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(_auth)),
        ChangeNotifierProxyProvider<UserProvider, AgoraProvider>(
          create: (context) => AgoraProvider(),
          update: (context, authProvider, _) =>
              AgoraProvider(currentUser: authProvider.currentUser),
        ),
        ChangeNotifierProxyProvider<UserProvider, RTCProvider>(
          create: (context) => RTCProvider(),
          update: (context, authProvider, _) =>
              RTCProvider(currentUser: authProvider.currentUser),
        )
      ],
      child: MaterialApp(
        title: AppConfig.of(context).appTitle,
        theme: ThemeData(
          fontFamily: 'Product Sans',
          colorScheme: ColorScheme.dark().copyWith(
            primary: kColorGreen,
          ),
        ),
        debugShowCheckedModeBanner:
            AppConfig.of(context).buildFlavour == kDevelopment,
        routes: {
          LoginScreen.pageId: (context) => LoginScreen(),
          HomeScreen.pageId: (context) => HomeScreen(),
          ProfileScreen.pageId: (context) => ProfileScreen(),
          CreateRoom.pageId: (context) => CreateRoom(),
          RoomScreen.pageId: (context) => RoomScreen(
                arguments: ModalRoute.of(context).settings.arguments
                    as RoomScreenArguments,
              ),
          EventRooms.pageId: (context) => EventRooms(
                arguments: ModalRoute.of(context).settings.arguments
                    as EventRoomsArguments,
              ),
          TournamentScreen.pageId: (context) => TournamentScreen(
                arguments: ModalRoute.of(context).settings.arguments
                    as TournamentScreenArguments,
              ),
        },
        initialRoute:
            _auth.currentUser == null ? LoginScreen.pageId : HomeScreen.pageId,
      ),
    );
  }
}
