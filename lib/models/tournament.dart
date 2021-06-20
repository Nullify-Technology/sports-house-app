import 'package:json_annotation/json_annotation.dart';
import 'package:sports_house/models/season.dart';

part 'tournament.g.dart';

@JsonSerializable()
class Tournament {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "season")
  final int? season;
  @JsonKey(name: "externalId")
  final int? externalId;
  @JsonKey(name: "banner")
  final String? banner;
  @JsonKey(name: "logo")
  final String? logo;
  @JsonKey(name: "current_season")
  final Season? currentSeason;

  Tournament(
    this.id,
    this.name,
    this.season,
    this.externalId,
    this.banner,
    this.logo,
    this.currentSeason,
  );

  factory Tournament.fromJson(Map<String, dynamic> json) =>
      _$TournamentFromJson(json);
  Map<String, dynamic> toJson() => _$TournamentToJson(this);
}
