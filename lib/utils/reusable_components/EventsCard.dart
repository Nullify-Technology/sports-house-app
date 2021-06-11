import 'package:flutter/material.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/screens/event_rooms/event_room.dart';
import 'package:sports_house/utils/SportsEvent.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:intl/intl.dart';

class EventsCard extends StatelessWidget {
  final Fixture fixture;

  const EventsCard({
    Key? key,
    required this.fixture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(15),
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
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (false)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    fixture.venue.name,
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
                      child: Text(
                        "Vs",
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
                              DateTime.parse(fixture.date),
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
}
