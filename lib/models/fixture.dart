import 'package:json_annotation/json_annotation.dart';
import 'package:sports_house/models/match_details.dart';
import 'package:sports_house/models/teams.dart';
import 'package:sports_house/models/venue.dart';

import 'player_data.dart';

part 'fixture.g.dart';

@JsonSerializable()
class Fixture {
  @JsonKey(name: "id")
  final String id;
  @JsonKey(name: "venue")
  final Venue venue;
  @JsonKey(name: "date")
  final String date;
  @JsonKey(name: "teams")
  final Teams teams;
  @JsonKey(name: "externalId")
  final int externalId;
  @JsonKey(name: "score", includeIfNull: false)
  final MatchDetails score;
  @JsonKey(name: "status", includeIfNull: false)
  final String status;
  @JsonKey(name: "players", includeIfNull: false)
  final Map<String, PlayerData> players;

  Fixture(
    this.id,
    this.venue,
    this.date,
    this.teams,
    this.externalId,
    this.score,
    this.status,
    this.players,
  );

  factory Fixture.fromJson(Map<String, dynamic> json) =>
      _$FixtureFromJson(json);
  Map<String, dynamic> toJson() => _$FixtureToJson(this);
}
