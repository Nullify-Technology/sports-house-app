

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:match_cafe/models/fixture.dart';
import 'package:match_cafe/utils/classes/event_classes.dart';
import 'package:match_cafe/utils/constants.dart';
import 'package:match_cafe/utils/reusable_components/error_components.dart';
import 'package:timeline_tile/timeline_tile.dart';

StreamBuilder<Event> buildMatchTimeline(
    Fixture fixture, DatabaseReference fixtureReference) {
  return StreamBuilder<Event>(
    stream: fixtureReference.child("events").onValue,
    builder: (context, snapShot) {
      if (snapShot.hasData) {
        if (snapShot.data!.snapshot.value != null) {
          var events = snapShot.data!.snapshot.value;
          List<dynamic> matchEvents = events
              .map((event) => MatchEvent.fromDb(event))
              .toList() as List<dynamic>;
          // for (var event in events) {

          matchEvents = List.from(matchEvents.reversed);
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: matchEvents.length,
            itemBuilder: (context, int i) {
              MatchEvent event = matchEvents[i];
              return TimelineTile(
                alignment: TimelineAlign.center,
                isFirst: i == 0,
                isLast: i == matchEvents.length - 1,
                indicatorStyle: IndicatorStyle(
                  color: kColorGreen,
                  indicatorXY: 0.5,
                  indicator: Container(
                    // padding: EdgeInsets.all(),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kColorGreen,
                    ),
                    child: Center(
                      child: Text(
                        event.time.elapsed.toString(),
                        style: TextStyle(
                          color: kCardBgColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                startChild: (event.team.name == fixture.teams!.home!.name)
                    ? buildEventCard(event, Position.left)
                    : Center(),
                endChild: (matchEvents[i].team.name == fixture.teams!.away!.name)
                    ? buildEventCard(event, Position.right)
                    : Center(),
              );
            },
          );
        }
      }
      return buildSquadDetailsUnavilable(
        context: context,
        error: kTimeLineUnavailable,
        icon: Icons.timeline,
      );
    },
  );
}

Container buildEventCard(MatchEvent event, Position position) {
  IconData icon = Icons.sports;
  Color color = kColorGreen;

  switch (event.type) {
    case 'Goal':
      // color = Colors.white;
      icon = Icons.sports_soccer;
      break;
    case 'subst':
      icon = Icons.change_circle_outlined;
      color = Colors.white54;
      break;
    case 'Card':
      icon = Icons.crop_portrait;
      if (event.detail == 'Yellow Card')
        color = Colors.yellowAccent;
      else if (event.detail == 'Red Card') color = Colors.redAccent;
      break;
  }
  return Container(
      child: Card(
    color: kCardBgColor,
    margin: EdgeInsets.all(7),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Icon( == 'Goal'?),
          if (position == Position.right) buildEventTypeIcon(icon, color),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(event.detail),
                Text(
                  '${event.player.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (event.type != 'Card' &&
                    event.assist.id != -1 &&
                    event.assist.name != '')
                  Text(
                    event.type == 'subst'
                        ? 'Sub: ' + event.assist.name
                        : 'Assist: ' + event.assist.name,
                  )
                else if (event.type == 'Card')
                  Text(
                    'For: ' + event.comments,
                  ),
              ],
            ),
          ),
          if (position == Position.left) buildEventTypeIcon(icon, color),
        ],
      ),
    ),
  ));
}

Padding buildEventTypeIcon(IconData icon, Color color,{double iconSize = 24.0}) {
  return Padding(
    padding: const EdgeInsets.only(
      right: 3,
    ),
    child: icon != Icons.crop_portrait
        ? Icon(
            icon,
            color: color,
            size: iconSize,
          )
        : Container(
            width: 12,
            height: 18,
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(
              horizontal: 6,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
  );
}
