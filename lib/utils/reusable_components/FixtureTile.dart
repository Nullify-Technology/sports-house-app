import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:match_cafe/models/fixture.dart';
import 'package:match_cafe/screens/event_rooms/event_room.dart';
import 'package:match_cafe/utils/constants.dart';
import 'package:match_cafe/utils/reusable_components/custom_text.dart';

class FixtureTile extends StatelessWidget {
  final Fixture fixture;

  const FixtureTile({
    Key key,
    this.fixture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DatabaseReference databaseReference =
        FirebaseDatabase(databaseURL: kRTDBUrl)
            .reference()
            .child("fixture")
            .child("fixture_${fixture.id}");

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, EventRooms.pageId,
            arguments: EventRoomsArguments(fixture));
      },
      child: Card(
        elevation: 5,
        color: kCardBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: DateFormat.jm('en_US').format(
                      DateTime.parse(fixture.date).toLocal(),
                    ),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  StreamBuilder<Event>(
                    stream: databaseReference.child("status").onValue,
                    builder: (context, snapShot) {
                      if (snapShot.hasData) {
                        if (snapShot.data.snapshot.value != null) {
                          Map<String, dynamic> status =
                              new Map<String, dynamic>.from(
                                  snapShot.data.snapshot.value);

                          return buildTimerWidget(status);
                          // return Center();
                        }
                      }
                      return Container();
                    },
                  ),
                ],
              ),
              VerticalDivider(
                color: Colors.white,
                thickness: 6,
              ),
              Expanded(
                child: StreamBuilder<Event>(
                  stream:
                      databaseReference.child("score").child("current").onValue,
                  builder: (context, snapShot) {
                    if (snapShot.hasData) {
                      if (snapShot.data.snapshot.value != null) {
                        Map<String, dynamic> score =
                            new Map<String, dynamic>.from(
                                snapShot.data.snapshot.value);

                        return buildTeamAndScore(score: score);
                      }
                    }
                    return buildTeamAndScore();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTeamAndScore({Map<String, dynamic> score}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomText(
                text: fixture.teams.home.name,
                fontSize: 16,
              ),
            ),
            if (score != null)
              CustomText(
                text: score["home"].toString(),
                fontSize: 16,
              ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          children: [
            Expanded(
              child: CustomText(
                text: fixture.teams.away.name,
                fontSize: 16,
              ),
            ),
            if (score != null)
              CustomText(
                text: score["away"].toString(),
                fontSize: 16,
              ),
          ],
        ),
        SizedBox(
          height: 2,
        ),
      ],
    );
  }

  Container buildTeamIcon(String url) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: new BoxDecoration(
        color: kCardBgColor,
        shape: BoxShape.circle,
      ),
      child: CachedNetworkImage(
        imageUrl: url,
        //placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.flag),
        width: 50,
        height: 50,
      ),
    );
  }

  static Widget buildTimerWidget(Map<String, dynamic> status) {
    bool isStatus = status['short'] != null &&
        (status['short'] != "1H" &&
            status['short'] != "2H" &&
            status['short'] != "ET" &&
            status['short'] != "P");
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: new BoxDecoration(
        color: isStatus ? kDropdownBgColor : Colors.redAccent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(40.0)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer,
            size: 12,
          ),
          SizedBox(
            width: 4,
          ),
          Text(
            isStatus && status['short'] != null
                ? status['short']
                : status['elapsed'].toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  showCompletedEventWarning(context) async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(kCompletedEventText),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
