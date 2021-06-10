

import 'package:json_annotation/json_annotation.dart';
import 'package:sports_house/models/team.dart';

part 'teams.g.dart';

@JsonSerializable()
class Teams{
  @JsonKey(name: "home")
  final Team home;
  @JsonKey(name: "away")
  final Team away;

  Teams(this.home, this.away);

  factory Teams.fromJson(Map<String, dynamic> json) => _$TeamsFromJson(json);
  Map<String, dynamic> toJson() => _$TeamsToJson(this);

}