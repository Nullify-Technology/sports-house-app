import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sports_house/blocs/user_bloc.dart';
import 'package:sports_house/models/response.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/screens/create_room/create_room.dart';
import 'package:sports_house/screens/event_rooms/event_room.dart';
import 'package:sports_house/screens/profile/profile_screen.dart';
import 'package:sports_house/utils/SportsEvent.dart';
import 'package:sports_house/utils/TrendingEvents.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/TrendingRoomCard.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();
  static String pageId = 'HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserBloc userBloc;
  final RestClient client = RestClient.create();

  @override
  void initState() {
    super.initState();
    userBloc = UserBloc(client: client);
    userBloc.getUserProfileImage();
  }

  @override
  void dispose() {
    super.dispose();
    userBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBlack,
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 360.0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // TextButton(
                //   child: Icon(
                //     Icons.search,
                //     color: Colors.white,
                //   ),
                //   onPressed: () {},
                // ),
                Icon(
                  Icons.sports,
                  size: 30,
                  color: Colors.white,
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
                      child: StreamBuilder<Response<AuthUser>>(
                          stream: userBloc.userStream,
                          builder: (context, snapShot) {
                            if (snapShot.hasData &&
                                snapShot.data?.status == Status.COMPLETED) {
                              return CircleAvatar(
                                foregroundImage: NetworkImage(
                                    snapShot.data?.data.profilePictureUrl ??
                                        ''),
                              );
                            }
                            return CircleAvatar(
                              foregroundImage: NetworkImage(kDummyImageUrl),
                            );
                          }),
                      onPressed: () {
                        Navigator.pushNamed(context, ProfileScreen.pageId);
                      },
                    ),
                  ],
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Padding(
                padding: const EdgeInsets.only(
                  top: 90,
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
                          viewportFraction: 0.83,
                          height: 240.0,
                          enlargeStrategy: CenterPageEnlargeStrategy.scale,
                          enableInfiniteScroll: false,
                          enlargeCenterPage: true,
                        ),
                        items: roomList.map((room) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                // margin: EdgeInsets.symmetric(horizontal: 1.0),
                                child: TrendingRoomCard(
                                  room: room,
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
                    Icons.podcasts,
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
                      child: EventsCard(
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

class EventsCard extends StatelessWidget {
  const EventsCard({
    Key? key,
    required this.event,
  }) : super(key: key);
  final SportsEvent event;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventRooms(
              eventName: event.title,
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
