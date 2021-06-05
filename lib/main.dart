import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sports_house/screens/login/login_screen.dart';

import 'package:sports_house/utils/constants.dart';

import 'utils/reusable_components/RoundedRectangleButton.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
      home: MyHomePage(title: 'Sports House'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return LoginScreen();
  }
}
