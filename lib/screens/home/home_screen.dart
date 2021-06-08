import 'package:flutter/material.dart';
import 'package:sports_house/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  static String pageId = 'HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  void initState() {
    super.initState();
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
        body: Column(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text('Home'),
                    ),
                  ),
                ],
              ));
  }
}
