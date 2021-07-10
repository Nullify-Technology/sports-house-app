import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:match_cafe/models/user.dart';
import 'package:match_cafe/network/rest_client.dart';
import 'package:match_cafe/provider/user_provider.dart';
import 'package:match_cafe/screens/home/home_screen.dart';
import 'package:match_cafe/utils/client_events.dart';
import 'package:match_cafe/utils/constants.dart';
import 'package:match_cafe/utils/reusable_components/CenterProgressBar.dart';
import 'package:match_cafe/utils/reusable_components/RoundedRectangleButton.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:async';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final Stream<ClientEvents> parentEvents;

  ProfileScreen({required this.parentEvents});
  static String pageId = 'ProfileScreen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _profileNameForm = GlobalKey();
  String? profileUrl;
   AuthUser? currentUser;
  final ImagePicker picker = ImagePicker();
   AppState? state;
  File? imageFile;

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
                      foregroundImage: CachedNetworkImageProvider(
                        user.profilePictureUrl ?? kProfilePlaceHolderUrl,
                      ),
                      onForegroundImageError: (exception, stackTrace) {
                        print(exception);
                      }),
                  onTap: () async {
                    _pickImage(user);
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
                          .updateUserName(name: name!);
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
    state = AppState.free;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> updateProfilePicture(String userId) async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      File image = File(pickedFile!.path);
    } catch (e) {
      print(e);
    }
  }

  Future<Null> _pickImage(AuthUser user) async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
      });
      _cropImage(user);
    }
  }

  Future<Null> _cropImage(AuthUser user) async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile!.path,
        maxHeight: 400,
        maxWidth: 400,
        compressQuality: 70,
        cropStyle: CropStyle.circle,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
              ]
            : [
                CropAspectRatioPreset.square,
              ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: '',
          toolbarColor: kColorBlack,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          activeControlsWidgetColor: Colors.white,
          cropFrameColor: Colors.white,
          // dimmedLayerColor: kColorBlack,
          backgroundColor: kColorBlack,
          statusBarColor: kColorBlack,
        ),
        iosUiSettings: IOSUiSettings(
          title: '',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile;
      print(imageFile);
      setState(() {
        state = AppState.cropped;
      });
      await context
          .read<UserProvider>()
          .updateProfilePicture(user.id!, imageFile!);
      _clearImage();
    }
  }

  void _clearImage() {
    imageFile = null;
    setState(() {
      state = AppState.free;
    });
  }
}
