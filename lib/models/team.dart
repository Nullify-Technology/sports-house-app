import 'package:json_annotation/json_annotation.dart';

import 'coach.dart';
import 'lineup.dart';
import 'player.dart';

part 'team.g.dart';

@JsonSerializable()
class Team {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "externalId")
  final int? externalId;
  @JsonKey(name: "logo_url")
  final String? logoUrl;
  @JsonKey(name: "lineups")
  final Lineup? lineups;

  Team(
    this.id,
    this.name,
    this.externalId,
    this.logoUrl,
    this.lineups,
  );

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);
}
