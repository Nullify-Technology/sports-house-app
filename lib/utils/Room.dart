class DesignRoom {
  String roomName;
  // String minutes;
  String score;
  String talkingCount;
  String team1Url;
  String team2Url;
  final String eventName;
  final bool isVerified;
  final String hostedBy;
  final String listners;
  final List<String> participants;
  DesignRoom({
    required this.eventName,
    // required this.minutes,
    required this.score,
    required this.talkingCount,
    required this.team1Url,
    required this.team2Url,
    required this.roomName,
    this.isVerified = false,
    this.hostedBy = '',
    required this.listners,
    required this.participants,
  });
}
