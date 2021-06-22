import 'package:json_annotation/json_annotation.dart';
import 'package:sports_house/models/team_standing.dart';

part 'standings.g.dart';

@JsonSerializable()
class Standings {
  @JsonKey(name: "description", includeIfNull: true)
  final String description;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "teams")
  final List<TeamStanding> teams;

  factory Standings.fromJson(Map<String, dynamic> json) =>
      _$StandingsFromJson(json);

  Standings(this.description, this.name, this.teams);
  Map<String, dynamic> toJson() => _$StandingsToJson(this);
}
