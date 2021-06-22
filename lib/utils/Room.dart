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
     this.eventName,
    //  this.minutes,
     this.score,
     this.talkingCount,
     this.team1Url,
     this.team2Url,
     this.roomName,
    this.isVerified = false,
    this.hostedBy = '',
     this.listners,
     this.participants,
  });
}
