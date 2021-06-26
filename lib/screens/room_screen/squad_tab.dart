import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:match_cafe/models/fixture.dart';
import 'package:match_cafe/models/lineup.dart';
import 'package:sports_house/models/player.dart';
import 'package:match_cafe/models/room.dart';
import 'package:match_cafe/models/team.dart';
import 'package:match_cafe/utils/constants.dart';
import 'package:match_cafe/utils/reusable_components/error_components.dart';

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
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTeamTitle(fixture.teams.home),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                height: 720,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(kFootballPitchBackground),
                        fit: BoxFit.cover)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildStartingXI(context, fixture, 'home'),
                    buildStartingXI(context, fixture, 'away')
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              buildTeamTitle(fixture.teams.away),
              SizedBox(
                height: 90,
              ),
              buildSubstitutesHomeAndAway(fixture, context)
            ],
          ),
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

Widget buildStartingXI(BuildContext context, Fixture fixture, String team) {
  var lineUp = team == "home"
      ? fixture.teams.home.lineups.startXI
      : fixture.teams.away.lineups.startXI;
  var numbering = [1, 2, 3, 4, 5, 6];

  var lines = new Map<int, List<Player>>();
  numbering.forEach((element) {
    var elements = lineUp
        .where((player) => int.parse(player.grid.split(":")[0]) == element)
        .toList(growable: false);
    if (elements.length > 0) {
      lines[element] = elements;
    }
  });

  List<Widget> rows = [
    SizedBox(
      height: 30,
    )
  ];

  rows.addAll(lines.values.map((listOfPlayers) => Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: listOfPlayers
              .map((player) => Column(
                    children: [
                      CircleAvatar(
                        foregroundImage: CachedNetworkImageProvider(
                            fixture.players[player.id.toString()].photo ??
                                kDummyProfileImageUrl),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
                        width: MediaQuery.of(context).size.width / 5,
                        decoration: BoxDecoration(
                            color: kCardBgColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Text(
                          player.name,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          style: TextStyle(fontSize: 10, color: kColorGreen),
                        ),
                      ),
                    ],
                  ))
              .toList(growable: false),
        ),
      )));

  return Container(
    height: 320,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: team == "home" ? rows : rows.reversed.toList(growable: false),
    ),
  );
}

Row buildTeamTitle(Team team) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
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
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        child: Text(
          team.lineups.formation,
          style: TextStyle(
            fontSize: kHeadingFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
    ],
  );
}

//Substitutes

Widget buildSubstitutesHomeAndAway(Fixture fixture, BuildContext context) {
  if (fixture.teams.home.lineups.substitutes != null &&
      fixture.teams.home.lineups.substitutes != null) {
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
              buildSubstitutes(fixture, 'home'),
              buildSubstitutes(fixture, 'away'),
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

ListView buildSubstitutes(Fixture fixture, String teamStr) {
  Team team = teamStr == "home" ? fixture.teams.home : fixture.teams.away;

  List<Widget> rows = [];
  rows.add(Divider());
  rows.add(ListTile(
    leading: CircleAvatar(
      backgroundImage: CachedNetworkImageProvider(team.logoUrl),
    ),
    title: Text(
      team.name,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: kHeadingFontSize),
    ),
  ));
  rows.add(Divider());
  // Add Coach
  rows.add(ListTile(
    leading: CircleAvatar(
      backgroundImage: CachedNetworkImageProvider(
          team.lineups.coach.photo ?? kDummyProfileImageUrl),
    ),
    title: Text(team.lineups.coach.name),
    subtitle: Text(kCoach),
  ));
  // Add players
  rows.addAll(team.lineups.substitutes.map((p) => ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
              fixture.players[p.id.toString()].photo ?? kDummyProfileImageUrl),
        ),
        title: Text(p.name),
      )));

  return ListView(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    children: rows,
    // itemCount: team == 'home'
    //     ? fixture.teams.home.lineups.substitutes.length
    //     : fixture.teams.away.lineups.substitutes.length,
    // itemBuilder: (context, i) {
    //   Lineup lineup = team == 'home'
    //       ? fixture.teams.home.lineups
    //       : fixture.teams.away.lineups;
    //   return ListTile(
    //     title: Text(
    //       '${lineup.substitutes[i].name}',
    //       style: TextStyle(
    //         fontWeight: FontWeight.bold,
    //         fontSize: 16,
    //       ),
    //     ),
    //     leading: Container(
    //       height: 40,
    //       width: 40,
    //       // padding: EdgeInsets.all(15),
    //       alignment: Alignment.center,
    //       decoration: BoxDecoration(
    //         shape: BoxShape.circle,
    //         color: kDropdownBgColor,
    //       ),
    //       child: Text(
    //         '${lineup.substitutes[i].pos}',
    //         style: TextStyle(
    //           color: kColorGreen,
    //           fontWeight: FontWeight.bold,
    //           fontSize: 20,
    //         ),
    //       ),
    //     ),
    //   );
    // },
  );
}
