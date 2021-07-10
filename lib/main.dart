
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:match_cafe/utils/client_events.dart';
import 'package:provider/provider.dart';
import 'package:match_cafe/provider/rtc_provider.dart';
import 'package:match_cafe/provider/user_provider.dart';
import 'package:match_cafe/screens/create_room/create_room.dart';
import 'package:match_cafe/screens/event_rooms/event_room.dart';
import 'package:match_cafe/screens/login/login_screen.dart';
import 'package:match_cafe/screens/profile/profile_screen.dart';
import 'package:match_cafe/screens/room_screen/room_screen.dart';
import 'package:match_cafe/screens/tournament/tournament.dart';
import 'package:match_cafe/utils/constants.dart';

import 'config/app_config.dart';
import 'screens/home/home_screen.dart';



class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  StreamController<ClientEvents> events = StreamController<ClientEvents>.broadcast();

  @override
  void dispose() {
    events.close();
    super.dispose();
  }

  @override
  void initState() {
    initialiseMethodeChannel();
    super.initState();
  }

  void initialiseMethodeChannel() {
    MethodChannel channel = MethodChannel(kMethodChannel);
    channel.setMethodCallHandler(_methodCallHandler);
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'leaveRoom':
        events.sink.add(ClientEvents.LeveRoom);
        break;
      default:
        print('TestFairy: Ignoring invoke from native. This normally shouldn\'t happen.');
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;

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
        ChangeNotifierProxyProvider<UserProvider, RTCProvider>(
          create: (context) => RTCProvider(),
          update: (context, authProvider, _) =>
              RTCProvider(currentUser: authProvider.currentUser),
        )
      ],
      child: MaterialApp(
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
          HomeScreen.pageId: (context) => HomeScreen(parentEvents: events.stream),
          ProfileScreen.pageId: (context) => ProfileScreen(parentEvents: events.stream),
          CreateRoom.pageId: (context) => CreateRoom(parentEvents: events.stream),
          RoomScreen.pageId: (context) => RoomScreen(
                parentEvents: events.stream,
                arguments: ModalRoute.of(context)!.settings.arguments
                    as RoomScreenArguments,
              ),
          EventRooms.pageId: (context) => EventRooms(
                parentEvents: events.stream,
                arguments: ModalRoute.of(context)!.settings.arguments
                    as EventRoomsArguments,
              ),
          TournamentScreen.pageId: (context) => TournamentScreen(
                parentEvents: events.stream,
                arguments: ModalRoute.of(context)!.settings.arguments
                    as TournamentScreenArguments,
              ),
        },
        initialRoute:
            _auth.currentUser == null ? LoginScreen.pageId : HomeScreen.pageId,
      ),
    );
  }
}
