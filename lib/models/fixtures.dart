

import 'package:json_annotation/json_annotation.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/models/teams.dart';
import 'package:sports_house/models/venue.dart';

part 'fixtures.g.dart';

@JsonSerializable()
class Fixtures{
  @JsonKey(name: "results")
  final List<Fixture> results;

  Fixtures(this.results);

  factory Fixtures.fromJson(Map<String, dynamic> json) => _$FixturesFromJson(json);
  Map<String, dynamic> toJson() => _$FixturesToJson(this);

}