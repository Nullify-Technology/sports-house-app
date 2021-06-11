import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sports_house/blocs/fixtures_bloc.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/models/response.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/provider/user_provider.dart';
import 'package:sports_house/screens/create_room/create_room.dart';
import 'package:sports_house/screens/profile/profile_screen.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/EventsCard.dart';
import 'package:sports_house/utils/reusable_components/InRoomBottomBar.dart';
import 'package:sports_house/utils/reusable_components/TrendingRoomCard.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  static String pageId = 'HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FixtureBloc fixtureBloc;
  late AuthUser? currentUser;
  final RestClient client = RestClient.create();
  final _controller = PageController();
  @override
  void initState() {
    super.initState();
    fixtureBloc = FixtureBloc(client: client);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    currentUser = context.watch<UserProvider>().currentUser;

    if(currentUser != null){
      if(currentUser!.name == null || currentUser!.name!.isEmpty){
        Navigator.popAndPushNamed(context, ProfileScreen.pageId);
      }else{
        fixtureBloc.getFixtures();
      }
    }

    return Scaffold(
      backgroundColor: kCardBgColor,
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 360.0,
            backgroundColor: kHomeAppBarBgColor,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                      child: (currentUser == null ||
                              currentUser?.profilePictureUrl == null)
                          ? CircleAvatar(
                              foregroundImage: NetworkImage(kDummyImageUrl))
                          : CircleAvatar(
                              radius: 20,
                              foregroundImage: NetworkImage(
                                  currentUser?.profilePictureUrl ?? ''),
                            ),
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
          StreamBuilder<Response<List<Fixture>>>(
              stream: fixtureBloc.fixturesStream,
              builder: (context, snapShot) {
                if (snapShot.hasData) {
                  switch (snapShot.data!.status) {
                    case Status.LOADING:
                    case Status.ERROR:
                      return SliverToBoxAdapter(child: Container());
                    case Status.COMPLETED:
                      return buildFixtureList(snapShot.data!.data);
                  }
                }
                return SliverToBoxAdapter(child: Container());
              }),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 80,
            ),
          ),
        ],
      ),
      extendBody: true,
      //TODO : Add logic to show and hide bottomNavigationBar based on In Room / Not in Room conditions
      bottomNavigationBar: InRoomBottomBar(
        room: kDummyRoom,
      ),
    );
  }

  Widget buildFixtureList(List<Fixture> fixtures) {
    return SliverList(
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
                  fixture: fixtures[index],
                ),
              );
            },
          );
        },
        childCount: fixtures.length,
      ),
    );
  }
}
