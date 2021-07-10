import 'dart:convert';

class MatchEvent {
  final String comments;
  final String detail;
  final Player player;
  Player assist = Player(id: -1, name: '');
  final RtTeam team;
  final Time time;
  final String type;
  MatchEvent(
      { required this.comments,
       required this.detail,
       required this.player,
       required this.team,
       required this.time,
       required this.type,
       required this.assist});

  MatchEvent copyWith({
    String? comments,
    String? detail,
    Player? player,
    RtTeam? team,
    Time? time,
    String? type,
  }) {
    return MatchEvent(
      comments: comments ?? this.comments,
      detail: detail ?? this.detail,
      player: player ?? this.player,
      assist: assist,
      team: team ?? this.team,
      time: time ?? this.time,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'comments': comments,
      'detail': detail,
      'player': player.toMap(),
      'team': team.toMap(),
      'time': time.toMap(),
      'type': type,
    };
  }

  factory MatchEvent.fromMap(Map<String, dynamic> map) {
    return MatchEvent(
      comments: map['comments'],
      detail: map['detail'],
      player: Player.fromMap(map['player']),
      assist: Player.fromMap(map['assist']),
      team: RtTeam.fromMap(map['team']),
      time: Time.fromMap(map['time']),
      type: map['type'],
    );
  }
  factory MatchEvent.fromDb(dynamic map) {
    return MatchEvent(
      comments: map['comments'] == null ? '' : map['comments'],
      detail: map['detail'],
      player: Player.fromDb(map['player']),
      assist: map['assist'] == null
          ? Player(id: -1, name: '')
          : Player.fromDb(map['assist']),
      team: RtTeam.fromDb(map['team']),
      time: Time.fromDb(map['time']),
      type: map['type'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MatchEvent.fromJson(String source) =>
      MatchEvent.fromMap(json.decode(source));

  @override
  String toString() {
    return 'MatchEvent(comments: $comments, detail: $detail, player: $player, team: $team, time: $time, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MatchEvent &&
        other.comments == comments &&
        other.detail == detail &&
        other.player == player &&
        other.team == team &&
        other.time == time &&
        other.type == type;
  }

  @override
  int get hashCode {
    return comments.hashCode ^
        detail.hashCode ^
        player.hashCode ^
        team.hashCode ^
        time.hashCode ^
        type.hashCode;
  }
}

class Player {
  final int id;
  final String name;
  Player({
     required this.id,
     required this.name,
  });

  Player copyWith({
    int? id,
    String? name,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id']?.toInt(),
      name: map['name'],
    );
  }
  factory Player.fromDb(dynamic data) {
    return Player(
      id: data['id']?.toInt(),
      name: data['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Player.fromJson(String source) => Player.fromMap(json.decode(source));

  @override
  String toString() => 'Player(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Player && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class RtTeam {
  final int id;
  final String logo;
  final String name;
  RtTeam({
     required this.id,
     required this.logo,
     required this.name,
  });

  RtTeam copyWith({
    int? id,
    String? logo,
    String? name,
  }) {
    return RtTeam(
      id: id ?? this.id,
      logo: logo ?? this.logo,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'logo': logo,
      'name': name,
    };
  }

  factory RtTeam.fromMap(Map<String, dynamic> map) {
    return RtTeam(
      id: map['id']?.toInt(),
      logo: map['logo'],
      name: map['name'],
    );
  }
  factory RtTeam.fromDb(dynamic map) {
    return RtTeam(
      id: map['id']?.toInt(),
      logo: map['logo'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory RtTeam.fromJson(String source) => RtTeam.fromMap(json.decode(source));

  @override
  String toString() => 'Team(id: $id, logo: $logo, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RtTeam &&
        other.id == id &&
        other.logo == logo &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ logo.hashCode ^ name.hashCode;
}

class Time {
  final int elapsed;
  Time({
     required this.elapsed,
  });

  Time copyWith({
    int? elapsed,
  }) {
    return Time(
      elapsed: elapsed ?? this.elapsed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'elapsed': elapsed,
    };
  }

  factory Time.fromMap(Map<String, dynamic> map) {
    return Time(
      elapsed: map['elapsed']?.toInt(),
    );
  }
  factory Time.fromDb(dynamic map) {
    return Time(
      elapsed: map['elapsed']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Time.fromJson(String source) => Time.fromMap(json.decode(source));

  @override
  String toString() => 'Time(elapsed: $elapsed)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Time && other.elapsed == elapsed;
  }

  @override
  int get hashCode => elapsed.hashCode;
}
