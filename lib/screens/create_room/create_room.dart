import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports_house/blocs/fixtures_bloc.dart';
import 'package:sports_house/blocs/rooms_bloc.dart';
import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/models/response.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/provider/user_provider.dart';
import 'package:sports_house/screens/room_screen/room_screen.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/CenterProgressBar.dart';
import 'package:sports_house/utils/reusable_components/RoundedRectangleButton.dart';
import 'package:sports_house/utils/reusable_components/drop_down_list.dart';
import 'package:intl/intl.dart';

class CreateRoom extends StatefulWidget {
  CreateRoom({Key key}) : super(key: key);
  static String pageId = 'CreateRoom';

  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final RestClient client = RestClient.create();
  FixtureBloc fixtureBloc;
  List<DropDown> fixtureDropDown = [];
  List<DropDown> roomTypes = [];
  DropDown selectedFixture;
  DropDown selectedType;
  final roomNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RoomsBloc roomsBloc;
  AuthUser currentUser;
  bool _isLoading = false;

  createFixtureRoom() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState.validate()) {
      if (selectedFixture.key != 'no_matches') {
        AgoraRoom room = await roomsBloc.createRoom(selectedFixture.key, "0",
            roomNameController.text, selectedType.key);
        Navigator.popAndPushNamed(context, RoomScreen.pageId,
            arguments: RoomScreenArguments(room.room));
      } else {
        print('No matches are available!');
        final snackBar = SnackBar(
          content: Text(
            selectedFixture.key == 'no_matches'
                ? kNoMatchesAvailable
                : kPrivateRoomsUnavailable,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  populateFixturesDropDown(List<Fixture> fixtures) {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String today = formatter.format(now);
    print('today : $today');

    for (var fixture in fixtures) {
      try {
        print("timess");
        print(formatter.format(DateTime.parse(fixture.date)));
        print(today);
        print("${fixture.teams.home.name} Vs ${fixture.teams.away.name}");
        if (formatter.format(DateTime.parse(fixture.date).toLocal()) == today)
          fixtureDropDown.add(DropDown(
            fixture.id,
            "${fixture.teams.home.name} Vs ${fixture.teams.away.name}",
          ));
      } catch (e) {
        print(e);
      }
    }
    if (fixtureDropDown.length == 0)
      fixtureDropDown.add(DropDown('no_matches', 'No matches available'));
    roomTypes = [DropDown("public", "Public"), DropDown("private", "Private")];
    selectedFixture = fixtureDropDown.first;
    selectedType = roomTypes.first;
  }

  @override
  void initState() {
    roomsBloc = RoomsBloc(client: client);
    fixtureBloc = FixtureBloc(client: client);
    fixtureBloc.getFixtures();
    currentUser = Provider.of<UserProvider>(context, listen: false).currentUser;
    super.initState();
  }

  @override
  void dispose() {
    roomNameController.dispose();
    roomsBloc.dispose();
    fixtureBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // eventName = eventList[0];
    // roomType = kRoomTypes[0];
    return Scaffold(
      appBar: AppBar(
        title: Text(kCreateRoom),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: kColorBlack,
      body: Card(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        color: kCardBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: kCreateRoomCardRadius,
            topRight: kCreateRoomCardRadius,
          ),
        ),
        child: _isLoading
            ? Container(
                child: CenterProgressBar(),
              )
            : StreamBuilder<Response<List<Fixture>>>(
                stream: fixtureBloc.fixturesStream,
                builder: (context, snapShot) {
                  if (snapShot.hasData) {
                    switch (snapShot.data.status) {
                      case Status.LOADING:
                      case Status.ERROR:
                        return Container();
                      case Status.COMPLETED:
                        populateFixturesDropDown(snapShot.data.data);
                        return buildUI();
                    }
                  }
                  return Container(
                    child: CenterProgressBar(),
                  );
                }),
      ),
    );
  }

  Widget buildUI() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: roomNameController,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kColorGreen,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    border: OutlineInputBorder(),
                    labelText: kRoomName,
                    hintText: kEnterRoomName,
                    fillColor: kDropdownBgColor,
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) =>
                      value.isEmpty ? "Room name can not be empty" : null,
                ),
                SizedBox(
                  height: 15,
                ),
                DropDownList(
                  dropDownList: fixtureDropDown,
                  onChange: (DropDown dropDown) {
                    print(dropDown.value);

                    selectedFixture = dropDown;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                DropDownList(
                  dropDownList: roomTypes,
                  onChange: (DropDown dropDown) {
                    selectedType = dropDown;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          RoundedRectangleButton(
            background: kColorGreen,
            textColor: kTextFieldBgColor,
            text: kCreateRoom,
            onClick: createFixtureRoom,
          )
        ],
      ),
    );
  }
}
