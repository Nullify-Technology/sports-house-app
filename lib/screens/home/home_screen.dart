import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sports_house/blocs/fixtures_bloc.dart';
import 'package:sports_house/blocs/rooms_bloc.dart';
import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/models/response.dart';
import 'package:sports_house/models/room.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/provider/agora_provider.dart';
import 'package:sports_house/provider/rtc_provider.dart';
import 'package:sports_house/provider/user_provider.dart';
import 'package:sports_house/screens/create_room/create_room.dart';
import 'package:sports_house/screens/profile/profile_screen.dart';
import 'package:sports_house/screens/room_screen/room_screen.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/EventsCard.dart';
import 'package:sports_house/utils/reusable_components/InRoomBottomBar.dart';
import 'package:sports_house/utils/reusable_components/TrendingRoomCard.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  static String pageId = 'HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FixtureBloc fixtureBloc;
  late AuthUser? currentUser;
  late RoomsBloc roomsBloc;
  final RestClient client = RestClient.create();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future joinRoom(Room room) async {
    try {
      AgoraRoom agoraRoom = await roomsBloc.joinRoom(room.id) as AgoraRoom;
      Navigator.pushNamed(context, RoomScreen.pageId,
          arguments: RoomScreenArguments(agoraRoom.room));
    } catch (e) {
      print("failed to join room");
    }
  }

  @override
  void initState() {
    super.initState();
    fixtureBloc = FixtureBloc(client: client);
    roomsBloc = RoomsBloc(client: RestClient.create());
    roomsBloc.getTrendingRooms();
  }

  @override
  void dispose() {
    fixtureBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    currentUser = context.watch<UserProvider>().currentUser;
    if (currentUser != null) {
      if (currentUser!.name == null || currentUser!.name!.isEmpty) {
        Navigator.popAndPushNamed(context, ProfileScreen.pageId);
      } else {
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
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: kHomeAppBarBgColor,
                        backgroundImage: AssetImage(kProfilePlaceHolder),
                        foregroundImage: CachedNetworkImageProvider(
                          currentUser?.profilePictureUrl ??
                              kProfilePlaceHolderUrl,
                        ),
                        onForegroundImageError: (exception, stackTrace) {
                          print(exception);
                        },
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
                      child: StreamBuilder<Response<List<Room>>>(
                        stream: roomsBloc.roomsStream,
                        builder: (context, snapShot) {
                          if (snapShot.hasData) {
                            switch (snapShot.data!.status) {
                              case Status.LOADING:
                              case Status.ERROR:
                                return Container();
                              case Status.COMPLETED:
                                return buildTrendingCarousel(
                                  snapShot.data!.data,
                                );
                            }
                          }
                          return Container();
                        },
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
                    kUpcomingEvents,
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
      bottomNavigationBar: context.watch<RTCProvider>().joined
          ? InRoomBottomBar(
              room: context.watch<RTCProvider>().room,
            )
          : null,
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

  Widget buildTrendingCarousel(List<Room> rooms) {
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 0.83,
        height: 240.0,
        enlargeStrategy: CenterPageEnlargeStrategy.scale,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
      ),
      items: rooms.map((room) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              child: GestureDetector(
                child: TrendingRoomCard(
                  room: room,
                ),
                onTap: () => joinRoom(room),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
