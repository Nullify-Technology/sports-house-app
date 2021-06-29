import 'package:json_annotation/json_annotation.dart';

import 'goals.dart';

part 'game_history.g.dart';

@JsonSerializable()
class GameHistory {
  @JsonKey(name: "win", includeIfNull: true)
  final int win;
  @JsonKey(name: "played", includeIfNull: true)
  final int played;
  @JsonKey(name: "draw", includeIfNull: true)
  final int draw;
  @JsonKey(name: "lose", includeIfNull: true)
  final int lose;
  @JsonKey(name: "goals")
  final Goals goals;

  factory GameHistory.fromJson(Map<String, dynamic> json) =>
      _$GameHistoryFromJson(json);

  GameHistory(this.win, this.played, this.draw, this.lose, this.goals);
  Map<String, dynamic> toJson() => _$GameHistoryToJson(this);
}
