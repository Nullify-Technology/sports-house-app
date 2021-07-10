import 'package:json_annotation/json_annotation.dart';

part 'score.g.dart';

@JsonSerializable()
class Score {
  @JsonKey(name: "home")
  final int? home;
  @JsonKey(name: "away")
  final int? away;

  Score(this.home, this.away);

  factory Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreToJson(this);
}
