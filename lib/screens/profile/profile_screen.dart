import 'package:flutter/material.dart';
import 'package:sports_house/blocs/user_bloc.dart';
import 'package:sports_house/models/response.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/screens/home/home_screen.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/CenterProgressBar.dart';
import 'package:sports_house/utils/reusable_components/RoundedRectangleButton.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen();
  static String pageId = 'ProfileScreen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _profileNameForm = GlobalKey();
  late UserBloc userBloc;
  String profileUrl = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: kColorBlack,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(appName),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<Response<AuthUser>>(
          stream: userBloc.userStream,
          builder: (context, snapShot) {
            if (snapShot.hasData) {
              switch (snapShot.data!.status) {
                case Status.LOADING:
                  return CenterProgressBar();
                case Status.COMPLETED:
                  return buildProfileScreen(snapShot.data!.data);
                case Status.ERROR:
                  return Container();
              }
            }
            return Container();
          }),
    );
  }

  Widget buildProfileScreen(AuthUser user) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                child: GestureDetector(
                  child: CircleAvatar(
                    backgroundColor: kCardBgColor,
                    maxRadius: MediaQuery.of(context).size.width * .25,
                    minRadius: MediaQuery.of(context).size.width * .25,
                    backgroundImage: AssetImage(
                      'assets/images/profile_soccer.png',
                    ),
                    foregroundImage: NetworkImage(
                      user.profilePictureUrl ?? '',
                    ),
                  ),
                  onTap: () async {
                    await userBloc.updateProfilePicture(user.id);
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(25),
                child: Text(
                  kProfileText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // color: kColorGreen,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        Card(
          color: kCardBgColor,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: kLoginCardRadius,
              topRight: kLoginCardRadius,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 25),
            child: Form(
              key: _profileNameForm,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    initialValue: user.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kColorGreen,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                      labelText: kName,
                      hintText: kEnterYourName,
                      fillColor: kTextFieldBgColor,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return kNameCannotBeEmpty;
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    onSaved: (name) async {
                      await userBloc.updateUserName(name: name);
                      Navigator.popAndPushNamed(context, HomeScreen.pageId);
                    },
                    onFieldSubmitted: (v) {},
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RoundedRectangleButton(
                    background: kColorGreen,
                    text: kProfileScreenButtonText,
                    textColor: kColorBlack,
                    onClick: () {
                      if (!_profileNameForm.currentState!.validate()) {
                        return;
                      }
                      _profileNameForm.currentState!.save();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    userBloc = UserBloc(client: RestClient.create());
    userBloc.getUser();
  }

  @override
  void dispose() {
    super.dispose();
    userBloc.dispose();
  }
}
