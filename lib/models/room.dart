

import 'package:json_annotation/json_annotation.dart';
import 'package:sports_house/models/fixture.dart';

part 'room.g.dart';

@JsonSerializable()
class Room{
  @JsonKey(name: "id")
  final String id;
  @JsonKey(name: "fixture_id")
  final String fixturesId;
  @JsonKey(name: "fixture")
  final Fixture fixture;
  @JsonKey(name: "created_by")
  final String createdBy;
  @JsonKey(name: "count")
  final int count;
  @JsonKey(name: "name")
  final String name;


  Room(this.id, this.fixturesId, this.fixture, this.createdBy, this.count, this.name);

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);

}