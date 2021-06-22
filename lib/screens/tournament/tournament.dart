import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:sports_house/blocs/fixtures_bloc.dart';
import 'package:sports_house/blocs/standings_bloc.dart';
import 'package:sports_house/blocs/tournament_bloc.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/models/response.dart';
import 'package:sports_house/models/standings.dart';
import 'package:sports_house/models/team_standing.dart';
import 'package:sports_house/models/tournament_standings.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/CenterProgressBar.dart';
import 'package:sports_house/utils/reusable_components/FixtureCard.dart';
import 'package:sports_house/utils/reusable_components/FixtureTile.dart';
import 'package:sports_house/utils/reusable_components/KeepAliveTab.dart';
import 'package:sports_house/utils/reusable_components/custom_text.dart';
import 'package:intl/intl.dart';

class TournamentScreenArguments {
  final String tournamentId;
  final String tournamentName;
  final String startDate;
  final String endDate;
  final String banner;

  TournamentScreenArguments(
      {required this.banner,
      required this.tournamentId,
      required this.tournamentName,
      required this.startDate,
      required this.endDate});
}

class TournamentScreen extends StatefulWidget {
  TournamentScreen({Key? key, required this.arguments}) : super(key: key);
  static String pageId = 'TournamentScreen';
  final TournamentScreenArguments arguments;

  @override
  _TournamentScreenState createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  late FixtureBloc fixtureBloc;
  late StandingsBloc standingsBloc;
  final RestClient client = RestClient.create();
  // late TournamentStandings _tournamentStandings;

  Future<TournamentStandings> fetchStandings() async {
    return await standingsBloc.getStandings(widget.arguments.tournamentId);
  }

  @override
  void initState() {
    super.initState();
    fixtureBloc = FixtureBloc(client: client);
    standingsBloc = StandingsBloc(client: client);
    fixtureBloc.getLiveTournamentFixtures(widget.arguments.tournamentId);
    // fetchStandings();
    //standingsBloc.getStandings(widget.arguments.tournamentId);
  }

  @override
  void dispose() {
    fixtureBloc.dispose();
    standingsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBlack,
      body: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                backgroundColor: kHomeAppBarBgColor,
                pinned: true,
                title: Text(
                  widget.arguments.tournamentName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  // centerTitle: true,

                  background: Container(
                    // color: kCardBgColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: Colors.white,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.arguments.banner,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        CustomText(
                          text: widget.arguments.tournamentName,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        CustomText(
                          text:
                              '${DateFormat.yMMMMd().format(DateTime.parse(widget.arguments.startDate))} - ${DateFormat.yMMMMd().format(DateTime.parse(widget.arguments.endDate))}',
                          fontSize: 13,
                        )
                      ],
                    ),
                  ),
                ),
                bottom: TabBar(
                  indicatorColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: BoxDecoration(),
                  tabs: <Widget>[
                    Tab(
                      child: CustomText(
                        text: kFixtures,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Tab(
                      child: CustomText(
                        text: kStandings,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    // Tab(icon: Icon(Icons.change_circle)),
                  ],
                ),
              ),
            ];
          },
          body: Padding(
            padding: const EdgeInsets.only(
              top: 10,
            ),
            child: TabBarView(
              children: [
                KeepAliveTab(child: buildFixturesTab()),
                KeepAliveTab(child: buildStandingsTab()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFixturesTab() {
    return SingleChildScrollView(
      child: StreamBuilder<Response<List<Fixture>>>(
          stream: fixtureBloc.fixturesStream,
          builder: (context, snapShot) {
            if (snapShot.hasData) {
              switch (snapShot.data!.status) {
                case Status.LOADING:
                  return Container(
                    height: MediaQuery.of(context).size.width,
                    child: CenterProgressBar(),
                  );
                case Status.ERROR:
                  return SliverToBoxAdapter(child: Container());
                case Status.COMPLETED:
                  return buildFixtureList(snapShot.data!.data);
              }
            }
            return Container(
              height: MediaQuery.of(context).size.width,
              child: CenterProgressBar(),
            );
          }),
    );
  }

  Widget buildStandingsTab() {
    return SingleChildScrollView(
      child: FutureBuilder<TournamentStandings>(
          future: fetchStandings(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return buildStandingsList(snapshot.data!.standings);
            } else if (snapshot.hasError) {
              return Container(
                child: Center(child: Text(kUnavailable)),
              );
            } else {
              return Container(
                height: MediaQuery.of(context).size.width,
                child: CenterProgressBar(),
              );
            }
          }),
    );
  }

  Widget buildFixtureList(List<Fixture> fixtures) {
    List<Fixture> fixturesToShow = [];
    DateFormat formatter = DateFormat.yMMMMd();
    String today = formatter.format(DateTime.now());
    String yesterday =
        formatter.format(DateTime.now().subtract(Duration(days: 1)));
    String tomorrow = formatter.format(DateTime.now().add(Duration(days: 1)));
    for (var fixture in fixtures) {
      String fixtureDate = formatter.format(DateTime.parse(fixture.date));
      if (fixtureDate == today ||
          fixtureDate == yesterday ||
          fixtureDate == tomorrow) {
        fixturesToShow.add(fixture);
      }
    }
    return GroupedListView<Fixture, String>(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      elements: fixtures,
      padding: EdgeInsets.only(
        bottom: 50,
      ),
      groupBy: (fixture) {
        return formatter.format(DateTime.parse(fixture.date).toLocal());
      },
      groupSeparatorBuilder: (String value) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 18, 10, 10),
        child: Text(
          value,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      itemBuilder: (context, fixture) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5,
              ),
              child: FixtureTile(
                fixture: fixture,
              ),
            );
          },
        );
      },
      order: GroupedListOrder.ASC,
    );
  }

  Widget buildStandingsList(List<Standings>? standings) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
      ),
      child: GroupedListView<Standings, String>(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        elements: standings!,
        padding: EdgeInsets.only(bottom: 50),
        groupBy: (standing) {
          return standing.name ?? '';
        },
        groupSeparatorBuilder: (String value) => Padding(
          padding: const EdgeInsets.fromLTRB(5, 18, 10, 10),
          child: Center(
            child: Text(
              value,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        itemBuilder: (context, standing) {
          return Builder(
            builder: (BuildContext context) {
              return Card(
                color: kCardBgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: buildTable(standing.teams!),
                ),
              );
            },
          );
        },
        order: GroupedListOrder.ASC,
      ),
    );
  }

  Widget buildTable(List<TeamStanding> teamStanding) {
    List<TableRow> tableRowList = [];
    tableRowList.add(buildTableHeader());
    for (var team in teamStanding) {
      tableRowList.add(buildTableRow(
        team.name!,
        team.all!.played!,
        team.all!.win!,
        team.all!.draw!,
        team.all!.lose!,
        '${team.all!.goals!.forTeam} : ${team.all!.goals!.against}',
        team.points.toString(),
      ));
    }

    return Table(
      // border: TableBorder.all(),
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth(),
        4: IntrinsicColumnWidth(),
        5: IntrinsicColumnWidth(),
        6: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: tableRowList,
    );
  }

  TableRow buildTableHeader() {
    return TableRow(
      children: <Widget>[
        buildHeader('Team'),
        buildHeader('P'),
        buildHeader('W'),
        buildHeader('D'),
        buildHeader('L'),
        buildHeader('Goals'),
        buildHeader('PTS'),
      ],
    );
  }

  Widget buildHeader(header) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: CustomText(
        text: header,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildRowItem(item, {bool centerItem = true}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: centerItem == true
          ? Center(
              child: CustomText(
                text: item,
                fontSize: 15,
                // fontWeight: FontWeight.bold,
              ),
            )
          : CustomText(
              text: item,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
    );
  }

  TableRow buildTableRow(
    String team,
    int p,
    int w,
    int d,
    int l,
    String g,
    String pts,
  ) {
    return TableRow(
      children: <Widget>[
        buildRowItem(team, centerItem: false),
        buildRowItem(p.toString()),
        buildRowItem(w.toString()),
        buildRowItem(d.toString()),
        buildRowItem(l.toString()),
        buildRowItem(g),
        buildRowItem(pts),
      ],
    );
  }
}
