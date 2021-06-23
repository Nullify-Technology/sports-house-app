import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/models/lineup.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/models/team.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/error_components.dart';

Widget buildMatchXI(Fixture fixture, BuildContext context) {
  if (fixture.teams.home.lineups != null &&
      fixture.teams.away.lineups != null &&
      fixture.teams.home.lineups.startXI != null &&
      fixture.teams.away.lineups.startXI != null) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTeamTitle(fixture.teams.home),
            SizedBox(
              height: 20,
            ),
            buildStartingXI(fixture, 'home'),
            SizedBox(
              height: 40,
            ),
            buildTeamTitle(fixture.teams.away),
            SizedBox(
              height: 20,
            ),
            buildStartingXI(fixture, 'away'),
            SizedBox(
              height: 90,
            ),
          ],
        ),
      ),
    );
  } else
    return buildSquadDetailsUnavilable(
      context: context,
      error: kSquadDetailsUnavailable,
      icon: Icons.sports_soccer,
    );
}

Widget buildStartingXI(Fixture fixture, String team) {
  return Padding(
    padding: const EdgeInsets.only(
      left: 15,
    ),
    child: ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemCount: team == 'home'
          ? fixture.teams.home.lineups.startXI.length
          : fixture.teams.away.lineups.startXI.length,
      itemBuilder: (context, i) {
        Lineup lineup = team == 'home'
            ? fixture.teams.home.lineups
            : fixture.teams.away.lineups;
        return ListTile(
          title: Text(
            '${lineup.startXI[i].name} ( ${lineup.startXI[i].number} )',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          leading: Container(
            height: 40,
            width: 40,
            // padding: EdgeInsets.all(15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kDropdownBgColor,
            ),
            child: fixture.players != null &&
                    fixture.players[lineup.startXI[i].id.toString()] != null
                ? CircleAvatar(
                    foregroundImage: CachedNetworkImageProvider(fixture
                            .players[lineup.startXI[i].id.toString()].photo ??
                        kDummyProfileImageUrl),
                  )
                : null,
          ),
        );
      },
    ),
  );
}

Row buildTeamTitle(Team team) {
  return Row(
    children: [
      SizedBox(
        width: 20,
      ),
      CachedNetworkImage(
        width: 40,
        imageUrl: team.logoUrl,
      ),
      SizedBox(
        width: 15,
      ),
      Text(
        team.name,
        style: TextStyle(
          // color: kColorGreen,
          fontSize: kHeadingFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

//Substitutes

Widget buildSubstitutesHomeAndAway(Room room, BuildContext context) {
  if (room.fixture.teams.home.lineups.substitutes != null &&
      room.fixture.teams.home.lineups.substitutes != null) {
    return SingleChildScrollView(
      child: Card(
        color: kCardBgColor,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 30,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 15,
                ),
                child: Text(
                  kSubtitutes,
                  style: TextStyle(
                    color: kColorGreen,
                    fontSize: kHeadingFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: buildSubstitutes(room, 'home'),
                  ),
                  Expanded(
                    child: buildSubstitutes(room, 'away'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  } else
    return buildSquadDetailsUnavilable(
      context: context,
      error: kSquadDetailsUnavailable,
      icon: Icons.change_circle,
    );
}

ListView buildSubstitutes(Room room, String team) {
  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: team == 'home'
        ? room.fixture.teams.home.lineups.substitutes.length
        : room.fixture.teams.away.lineups.substitutes.length,
    itemBuilder: (context, i) {
      Lineup lineup = team == 'home'
          ? room.fixture.teams.home.lineups
          : room.fixture.teams.away.lineups;
      return ListTile(
        title: Text(
          '${lineup.substitutes[i].name}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: Container(
          height: 40,
          width: 40,
          // padding: EdgeInsets.all(15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kDropdownBgColor,
          ),
          child: Text(
            '${lineup.substitutes[i].pos}',
            style: TextStyle(
              color: kColorGreen,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      );
    },
  );
}
