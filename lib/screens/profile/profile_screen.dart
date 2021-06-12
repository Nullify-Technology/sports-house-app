import 'package:flutter/material.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/provider/user_provider.dart';
import 'package:sports_house/screens/home/home_screen.dart';
import 'package:sports_house/utils/constants.dart';
import 'package:sports_house/utils/reusable_components/CenterProgressBar.dart';
import 'package:sports_house/utils/reusable_components/RoundedRectangleButton.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen();
  static String pageId = 'ProfileScreen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _profileNameForm = GlobalKey();
  String profileUrl = "";
  late AuthUser? currentUser;

  @override
  Widget build(BuildContext context) {
    currentUser = context.watch<UserProvider>().currentUser;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: kColorBlack,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(kAppName),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: currentUser == null
          ? CenterProgressBar()
          : buildProfileScreen(currentUser!),
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
                      kProfilePlaceHolder,
                    ),
                    foregroundImage: NetworkImage(
                      user.profilePictureUrl ?? '',
                    ),
                  ),
                  onTap: () async {
                    await context
                        .read<UserProvider>()
                        .updateProfilePicture(user.id);
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
                      await context
                          .read<UserProvider>()
                          .updateUserName(name: name);
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
  }

  @override
  void dispose() {
    super.dispose();
  }
}
