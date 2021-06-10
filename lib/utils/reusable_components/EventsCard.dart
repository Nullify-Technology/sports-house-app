import 'package:flutter/material.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/screens/event_rooms/event_room.dart';
import 'package:sports_house/utils/SportsEvent.dart';
import 'package:sports_house/utils/constants.dart';

class EventsCard extends StatelessWidget {

  final Fixture fixture;

  const EventsCard({Key? key,required this.fixture,}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventRooms(
              eventName: fixture.teams.home.name + " Vs " + fixture.teams.away.name,
            ),
          ),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      fixture.teams.home.name + " Vs " + fixture.teams.away.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: new BoxDecoration(
                      color: Colors.redAccent,
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
                          "20",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
                      child: Text(
                        "2 - 1",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    buildTeamIcon(fixture.teams.away.logoUrl),
                  ],
                ),
              ),
              if (false)
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
                          '2k $kPeopleTalkingText',
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
}
