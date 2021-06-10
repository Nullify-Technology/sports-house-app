

import 'package:json_annotation/json_annotation.dart';

part 'team.g.dart';

@JsonSerializable()
class Team{
  @JsonKey(name: "id")
  final String id;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "externalId")
  final int externalId;
  @JsonKey(name: "logo_url")
  final String logoUrl;

  Team(this.id, this.name, this.externalId, this.logoUrl);

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);

}