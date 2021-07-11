import 'package:json_annotation/json_annotation.dart';

part 'score_bat_side.g.dart';
@JsonSerializable()
class ScoreBatSide {
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "url")
  final String? url;

  ScoreBatSide(this.name, this.url);

  factory ScoreBatSide.fromJson(Map<String, dynamic> json) => _$ScoreBatSideFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreBatSideToJson(this);
}