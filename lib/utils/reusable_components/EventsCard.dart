import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/screens/event_rooms/event_room.dart';
import 'package:sports_house/utils/constants.dart';

class EventsCard extends StatelessWidget {
  final Fixture fixture;

  const EventsCard({
    Key? key,
    required this.fixture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    late DatabaseReference databaseReference = FirebaseDatabase(databaseURL: kRTDBUrl).reference()
        .child("fixture").child("fixture_${fixture.id}");

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, EventRooms.pageId,
            arguments: EventRoomsArguments(fixture.id,
                fixture.teams.home.name + " Vs " + fixture.teams.away.name));
      },
      child: Card(
        elevation: 5,
        color: kEventsCardBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      fixture.teams.home.name +
                          " Vs " +
                          fixture.teams.away.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  StreamBuilder<Event>(
                    stream: databaseReference.child("status").onValue,
                    builder: (context, snapShot){
                      if(snapShot.hasData){
                        if(snapShot.data!.snapshot.value != null){
                          Map<String, dynamic> status = new Map<String, dynamic>.from(snapShot.data!.snapshot.value);
                          return buildTimerWidget(status["short"], status["elapsed"]);
                        }
                      }
                      return Container();
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${fixture.venue.name}, ${fixture.venue.city}',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildTeamIcon(fixture.teams.home.logoUrl),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: new BoxDecoration(
                        color: kCardBgColor,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      ),
                      child: StreamBuilder<Event>(
                        stream: databaseReference.child("score").child("current").onValue,
                        builder: (context, snapShot){
                          if(snapShot.hasData){
                            if(snapShot.data!.snapshot.value != null){
                              Map<String, dynamic> score = new Map<String, dynamic>.from(snapShot.data!.snapshot.value);
                              return Text(
                                '${score["home"]} - ${score["away"]}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              );
                            }
                          }
                          return Text(
                            'Vs',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                    ),
                    buildTeamIcon(fixture.teams.away.logoUrl),
                  ],
                ),
              ),
              Column(
                children: [
                  Divider(
                    thickness: 1,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.yMMMMd('en_US').add_jm().format(
                              DateTime.parse(fixture.date).toLocal(),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildTeamIcon(String url) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: new BoxDecoration(
        color: kCardBgColor,
        shape: BoxShape.circle,
      ),
      child: Image.network(
        url,
        width: 50,
        height: 50,
      ),
    );
  }

  Widget buildTimerWidget(String? short, int elapsed){
      return Container(
        padding:
        EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: new BoxDecoration(
          color: (short != null && short == "FT") ? kCardBgColor : Colors.redAccent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.timer,
              size: 16,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              (short != null && short == "FT") ? "Full Time" : (short == "HT" ? "Half Time" : elapsed.toString()),
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
  }
}
