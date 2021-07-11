import 'package:json_annotation/json_annotation.dart';

part 'goals.g.dart';

@JsonSerializable()
class Goals {
  @JsonKey(name: "for", includeIfNull: true)
  final int? forTeam;
  @JsonKey(name: "against", includeIfNull: true)
  final int? against;
  Goals(
    this.forTeam,
    this.against,
  );

  factory Goals.fromJson(Map<String, dynamic> json) => _$GoalsFromJson(json);
  Map<String, dynamic> toJson() => _$GoalsToJson(this);
}
