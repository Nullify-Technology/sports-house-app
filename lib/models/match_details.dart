import 'package:json_annotation/json_annotation.dart';
import 'package:match_cafe/models/score.dart';

part 'match_details.g.dart';

@JsonSerializable()
class MatchDetails{
  @JsonKey(name: "current")
  final Score current;

  MatchDetails(this.current);

  factory MatchDetails.fromJson(Map<String, dynamic> json) => _$MatchDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$MatchDetailsToJson(this);

}