import 'package:json_annotation/json_annotation.dart';

import 'coach.dart';
import 'player.dart';

part 'lineup.g.dart';

@JsonSerializable()
class Lineup {
  @JsonKey(name: "formation", includeIfNull: false)
  final String formation;
  @JsonKey(name: "startXI", includeIfNull: false)
  final List<Player> startXI;
  @JsonKey(name: "substitutes", includeIfNull: false)
  final List<Player> substitutes;
  @JsonKey(name: "coach", includeIfNull: false)
  final Coach coach;

  Lineup(this.formation, this.startXI, this.substitutes, this.coach);

  factory Lineup.fromJson(Map<String, dynamic> json) => _$LineupFromJson(json);
  Map<String, dynamic> toJson() => _$LineupToJson(this);
}
