import 'package:json_annotation/json_annotation.dart';
import 'package:sports_house/models/game_history.dart';

part 'team_standing.g.dart';

@JsonSerializable()
class TeamStanding {
  @JsonKey(name: "away")
  final GameHistory away;
  @JsonKey(name: "all")
  final GameHistory all;
  @JsonKey(name: "home")
  final GameHistory home;
  @JsonKey(name: "rank")
  final int rank;
  @JsonKey(name: "status")
  final String status;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "logo")
  final String logo;
  @JsonKey(name: "form")
  final String form;
  @JsonKey(name: "points")
  final int points;
  @JsonKey(name: "goalsDiff")
  final int goalsDiff;
  @JsonKey(name: "update")
  final String update;

  factory TeamStanding.fromJson(Map<String, dynamic> json) =>
      _$TeamStandingFromJson(json);

  TeamStanding(
      this.away,
      this.all,
      this.home,
      this.rank,
      this.status,
      this.name,
      this.logo,
      this.form,
      this.points,
      this.goalsDiff,
      this.update);
  Map<String, dynamic> toJson() => _$TeamStandingToJson(this);
}
