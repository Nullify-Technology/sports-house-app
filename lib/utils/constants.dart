import 'package:flutter/cupertino.dart';
import 'package:sports_house/utils/SportsEvent.dart';
import 'package:sports_house/utils/Room.dart';

//Colors
const Color kColorGreen = Color(0xffD2FF79);
const Color kColorBlack = Color(0xff181818);
const Color kCardBgColor = Color(0xff2A2A2A);
const Color kTextFieldBgColor = Color(0xff414141);
const Color kDropdownBgColor = Color(0xff414141);
const Color kBottomBarBgColor = Color(0xff3C3C3C);
const Color kInRoomBottomBarBgColor = Color(0xffE3FFB9);
const Color kProfileBgColor = Color(0xff474747);
const Color kCloseButtonBgColor = Color(0x4BFF8383);
const Color kEventsCardBgColor = Color(0xff3F3F3F);
const Color kTrendingCardBgColor = Color(0xff3B3B3B);
const Color kHomeAppBarBgColor = Color(0xff181818);

// Login Screen
const String kAppName = 'Sports House';
const String kPhone = 'Phone';
const String kOtp = 'OTP';
const String kSendOtp = 'Send OTP';
const String kLoginButtonText = 'Enter in to $kAppName';
const String kInvalidPhone = 'Invalid Phone Number!';
const String kWelcomeToSportsHouse = 'Welcome to $kAppName';
const String kEnterPhoneNumber = 'Enter your phone number';

const Radius kLoginCardRadius = Radius.circular(10);
const Radius kCreateRoomCardRadius = Radius.circular(15);

//Profile Screen
const String kProfileText =
    'Upload your profile picture, and \nlet your friends identify you easily';
const String kName = 'Full Name';
const String kEnterYourName = 'Enter your Name';
const String kNameCannotBeEmpty = 'Name Cannot Be Empty!';
const String kProfileScreenButtonText = 'Confirm & Update';

const String kInvalidPhoneNumber = "Invalid Phone Number";
const String kOtpFailed = "Failed to send OTP! Try again later";
const String kInvalidOtp = "Invalid OTP";

const String kTrending = 'Trending';
const String kPeopleTalkingText = 'people are talking about this';

const String kCreate = 'Create';
const String kTodaysEvents = "Today's Events";
const double kHeadingFontSize = 23;

const String kRoomName = "Room Name";
const String kEnterRoomName = "Enter Room Name";
const String kCreateRoom = "Create Room";

const List<String> kRoomTypes = [
  'Private Room',
  'Public Room',
  'Channel',
];
const String kDevelopment = "dev";
const String kProduction = "prod";
const String kAccessToken = "AccessToken";
const String kUser = "UserProfile";

const String kListners = 'Listners';
const String kHostedBy = 'Hosted By:';
const String kRooms = 'Rooms';

const String kVersus = 'Vs';

const String kParticipants = 'Participants';
const String kLeaveRoom = 'Leave Room';

//TODO : Dummy Constants - To be deleted in the end
const String kDummyProfileImageUrl =
    'https://images.unsplash.com/flagged/photo-1570612861542-284f4c12e75f?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8cGVyc29ufGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80';
const String kDummyUserName = 'Aswin Divakar';
SportsEvent kDummyEvent = new SportsEvent(
  title: 'MUN Vs BAR',
  minutes: '120',
  score: '2 - 1',
  talkingCount: '2k',
  team1Url:
      'https://assets.webiconspng.com/uploads/2017/09/Manchester-United-PNG-Image-55861.png',
  team2Url:
      'https://icons.iconarchive.com/icons/giannis-zographos/spanish-football-club/256/FC-Barcelona-icon.png',
);
Room kDummyRoom = new Room(
  eventName: 'MUN Vs BAR',
  score: '2 - 1',
  talkingCount: '2k',
  team1Url:
      'https://assets.webiconspng.com/uploads/2017/09/Manchester-United-PNG-Image-55861.png',
  team2Url:
      'https://icons.iconarchive.com/icons/giannis-zographos/spanish-football-club/256/FC-Barcelona-icon.png',
  roomName: 'MUN Fans Club - Kozhikode',
  hostedBy: 'Aswin Divakar',
  listners: '2k',
  participants: [
    kDummyProfileImageUrl,
    kDummyProfileImageUrl,
    kDummyProfileImageUrl,
  ],
);

const List<String> kDummyParticipants = [
  kDummyProfileImageUrl,
  kDummyProfileImageUrl,
  kDummyProfileImageUrl,
];

String kDummyImageUrl =
    'https://images.unsplash.com/flagged/photo-1570612861542-284f4c12e75f?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8cGVyc29ufGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80';

List<SportsEvent> eventList = [
  kDummyEvent,
  kDummyEvent,
  kDummyEvent,
  kDummyEvent,
  kDummyEvent
];
List<Room> roomList = [
  kDummyRoom,
  kDummyRoom,
  kDummyRoom,
  kDummyRoom,
  kDummyRoom
];
