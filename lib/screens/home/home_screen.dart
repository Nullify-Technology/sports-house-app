import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:match_cafe/blocs/fixtures_bloc.dart';
import 'package:match_cafe/blocs/rooms_bloc.dart';
import 'package:match_cafe/blocs/tournament_bloc.dart';
import 'package:match_cafe/models/agora_room.dart';
import 'package:match_cafe/models/fixture.dart';
import 'package:match_cafe/models/response.dart';
import 'package:match_cafe/models/room.dart';
import 'package:match_cafe/models/tournament.dart';
import 'package:match_cafe/models/user.dart';
import 'package:match_cafe/network/rest_client.dart';
import 'package:match_cafe/provider/rtc_provider.dart';
import 'package:match_cafe/provider/user_provider.dart';
import 'package:match_cafe/screens/create_room/create_room.dart';
import 'package:match_cafe/screens/profile/profile_screen.dart';
import 'package:match_cafe/screens/room_screen/room_screen.dart';
import 'package:match_cafe/screens/tournament/tournament.dart';
import 'package:match_cafe/utils/constants.dart';
import 'package:match_cafe/utils/reusable_components/CenterProgressBar.dart';
import 'package:match_cafe/utils/reusable_components/FixtureCard.dart';
import 'package:match_cafe/utils/reusable_components/InRoomBottomBar.dart';
import 'package:match_cafe/utils/reusable_components/TrendingRoomCard.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:match_cafe/utils/reusable_components/custom_text.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  static String pageId = 'HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FixtureBloc fixtureBloc;
  TournamentBloc tournamentBloc;
  AuthUser currentUser;
  RoomsBloc roomsBloc;
  final RestClient client = RestClient.create();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  RemoteConfig remoteConfig = RemoteConfig.instance;
  double _appLatestVersion;

  Future joinRoomWithId(BuildContext context, String roomId) async {
    print('retrieveDynamicLink $roomId');
    try {
      AgoraRoom agoraRoom = await roomsBloc.joinRoom(roomId);
      Room room = agoraRoom.room;
      print(room);
      Navigator.of(context)
          .pushNamed(RoomScreen.pageId, arguments: RoomScreenArguments(room));
    } catch (e) {
      print("failed to join room : " + e.toString());
    }
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      print('Deeplink : ' + deepLink.toString());
      if (deepLink != null) {
        List<String> segments = deepLink.pathSegments;
        print('Deeplink : ' + deepLink.toString());
        if (segments.length > 2 && segments[segments.length - 2] == 'room')
          joinRoomWithId(context, segments.last);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print('Deeplink : ' + e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      List<String> segments = deepLink.pathSegments;
      print('Deeplink : ' + deepLink.toString());
      if (segments.length > 2 && segments[segments.length - 2] == 'room')
        joinRoomWithId(context, segments.last);
    }
  }

  Future joinRoom(Room room) async {
    try {
      AgoraRoom agoraRoom = await roomsBloc.joinRoom(room.id);
      Navigator.pushNamed(context, RoomScreen.pageId,
          arguments: RoomScreenArguments(agoraRoom.room));
    } catch (e) {
      print("failed to join room");
    }
  }

  void fetchConfig() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 10),
      minimumFetchInterval: Duration(hours: 1),
    ));
    bool updated = await remoteConfig.fetchAndActivate();
    if (updated) {
      // the config has been updated, new parameter values are available.
      _appLatestVersion = remoteConfig.getDouble('app_version');
      print('Version Data : $kAppVersion | $_appLatestVersion');
    } else {
      // the config values were previously updated.
      print('Not updated');
      print('Version Data : $kAppVersion | $_appLatestVersion');
    }
  }

  @override
  void initState() {
    super.initState();
    roomsBloc = RoomsBloc(client: RestClient.create());
    this.initDynamicLinks();

    remoteConfig.setDefaults(<String, dynamic>{
      'app_version': kAppVersion,
    });
    _appLatestVersion = kAppVersion;
    fixtureBloc = FixtureBloc(client: client);
    tournamentBloc = TournamentBloc(client: client);
    roomsBloc = RoomsBloc(client: RestClient.create());
    roomsBloc.getTrendingRooms();
    tournamentBloc.getTournaments();
    fetchConfig();
  }

  @override
  void dispose() {
    fixtureBloc.dispose();
    tournamentBloc.dispose();
    super.dispose();
  }

  void _launchURL() async => await canLaunch(kWebSiteUrl)
      ? await launch(kWebSiteUrl)
      : throw 'Could not launch $kWebSiteUrl';

  @override
  Widget build(BuildContext context) {
    currentUser = context.watch<UserProvider>().currentUser;
    if (currentUser != null) {
      if (currentUser.name == null || currentUser.name.isEmpty) {
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
            expandedHeight: 390.0,
            backgroundColor: kHomeAppBarBgColor,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Image.asset(
                //   'assets/images/logo.png',
                //   width: 30,
                //   height: 30,
                // ),
                CustomText(
                  text: kAppName,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
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
                  top: 105,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 30,
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
                            switch (snapShot.data.status) {
                              case Status.LOADING:
                              case Status.ERROR:
                                return Container();
                              case Status.COMPLETED:
                                return buildTrendingCarousel(
                                  snapShot.data.data,
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
          if (kAppVersion < _appLatestVersion)
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => _launchURL(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  // margin: EdgeInsets.fromLTRB(50, 10, 50, 0),
                  decoration: BoxDecoration(
                    color: kColorGreen,
                    // borderRadius: BorderRadius.all(
                    //   Radius.circular(50),
                    // ),
                  ),
                  child: Column(
                    children: [
                      // Icon(
                      //   Icons.new_releases,
                      //   size: 18,
                      //   color: kColorBlack,
                      // ),
                      CustomText(
                        text: kNewUpdateAvailable,
                        fontSize: 16,
                        color: kColorBlack,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 2),
                      CustomText(
                        text: kClickHereToInstall,
                        fontSize: 12,
                        color: kColorBlack,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          StreamBuilder<Response<List<Tournament>>>(
              stream: tournamentBloc.tournamentsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  switch (snapshot.data.status) {
                    case Status.LOADING:
                    case Status.ERROR:
                      return SliverToBoxAdapter(child: Container());
                    case Status.COMPLETED:
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(30, 30, 30, 10),
                          child: Center(
                            child: buildTournamentList(snapshot.data.data),
                          ),
                        ),
                      );
                  }
                }
                return SliverToBoxAdapter(child: Container());
              }),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(30, 15, 0, 10),
              child: buildIconTitle(icon: Icons.podcasts, title: kFixtures),
            ),
          ),
          StreamBuilder<Response<List<Fixture>>>(
              stream: fixtureBloc.fixturesStream,
              builder: (context, snapShot) {
                if (snapShot.hasData) {
                  switch (snapShot.data.status) {
                    case Status.LOADING:
                    case Status.ERROR:
                      return SliverToBoxAdapter(child: Container());
                    case Status.COMPLETED:
                      return buildFixtureList(snapShot.data.data);
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
                  horizontal: 30,
                  vertical: 10,
                ),
                height: 250,
                child: FixtureCard(
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

  Widget buildTournamentList(List<Tournament> tournaments) {
    return Column(
      children: [
        buildIconTitle(
          icon: Icons.sports_soccer,
          title: kTournaments,
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          height: 125,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          // color: Colors.black,
          child: ListView.builder(
              itemCount: tournaments.length,
              scrollDirection: Axis.horizontal,
              // shrinkWrap: true,
              itemBuilder: (context, i) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.42,
                              height: 100,
                              child: Card(
                                color: Colors.white,
                                clipBehavior: Clip.hardEdge,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: tournaments[i].banner ??
                                        kDummyProfileImageUrl,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            CustomText(
                              text: tournaments[i].name ?? '',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            TournamentScreen.pageId,
                            arguments: TournamentScreenArguments(
                              tournamentId: tournaments[i].id ?? '',
                              tournamentName: tournaments[i].name ?? '',
                              banner: tournaments[i].banner ?? '',
                              startDate:
                                  tournaments[i].currentSeason.start ?? '',
                              endDate: tournaments[i].currentSeason.end ?? '',
                            ),
                          );
                        });
                  },
                );
              }),
        ),
      ],
    );
  }

  Row buildIconTitle({
    IconData icon,
    String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: kHeadingFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildTrendingCarousel(List<Room> rooms) {
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 0.85,
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
