import 'package:json_annotation/json_annotation.dart';
import 'package:sports_house/models/season.dart';
import 'package:sports_house/models/standings.dart';

part 'tournament_standings.g.dart';

@JsonSerializable()
class TournamentStandings {
  @JsonKey(name: "id")
  final String id;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "banner")
  final String banner;
  @JsonKey(name: "logo")
  final String logo;
  @JsonKey(name: "standings")
  final List<Standings> standings;

  TournamentStandings(
    this.id,
    this.name,
    this.banner,
    this.logo,
    this.standings,
  );

  factory TournamentStandings.fromJson(Map<String, dynamic> json) =>
      _$TournamentStandingsFromJson(json);
  Map<String, dynamic> toJson() => _$TournamentStandingsToJson(this);
}
