import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sports_house/screens/create_room/create_room.dart';
import 'package:sports_house/utils/SportsEvent.dart';

import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/RoundedRectangleButton.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();
  static String pageId = 'HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SportsEvent> eventList = [];
  SportsEvent event = new SportsEvent(
    title: 'MUN Vs BAR',
    minutes: '120',
    score: '2 - 1',
    talkingCount: '2k',
    team1Url:
        'https://assets.webiconspng.com/uploads/2017/09/Manchester-United-PNG-Image-55861.png',
    team2Url:
        'https://icons.iconarchive.com/icons/giannis-zographos/spanish-football-club/256/FC-Barcelona-icon.png',
  );

  String imageUrl =
      'https://images.unsplash.com/flagged/photo-1570612861542-284f4c12e75f?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8cGVyc29ufGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80';

  @override
  Widget build(BuildContext context) {
    eventList.add(event);
    eventList.add(event);
    eventList.add(event);
    eventList.add(event);
    eventList.add(event);

    return Scaffold(
      // extendBodyBehindAppBar: true,
      backgroundColor: kColorBlack,
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 350.0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, CreateRoom.pageId);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            kCreate,
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    TextButton(
                      child: CircleAvatar(
                        foregroundImage: NetworkImage(imageUrl),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Padding(
                padding: const EdgeInsets.only(
                  top: 100,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Icon(
                          Icons.whatshot,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          kTrending,
                          style: TextStyle(
                            fontSize: kHeadingFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 200.0,
                          enableInfiniteScroll: false,
                          enlargeCenterPage: true,
                        ),
                        items: eventList.map((e) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                // margin: EdgeInsets.symmetric(horizontal: 1.0),
                                child: RoomsCard(
                                  event: e,
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 0, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.radar,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    kTodaysEvents,
                    style: TextStyle(
                      fontSize: kHeadingFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 10,
                      ),
                      height: 250,
                      child: RoomsCard(
                        event: eventList[index],
                      ),
                    );
                  },
                );
              },
              childCount: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class RoomsCard extends StatelessWidget {
  const RoomsCard({
    Key? key,
    required this.event,
  }) : super(key: key);
  final SportsEvent event;
  @override
  Widget build(BuildContext context) {
    return Card(
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
                    event.title,
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
                        event.minutes,
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
                  buildTeamIcon(event.team1Url),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: new BoxDecoration(
                      color: kCardBgColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                    ),
                    child: Text(
                      event.score,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  buildTeamIcon(event.team2Url),
                ],
              ),
            ),
            if (event.talkingCount != '')
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
                        '${event.talkingCount} $kPeopleTalkingText',
                      ),
                    ],
                  ),
                ],
              ),
          ],
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
