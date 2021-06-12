

import 'package:firebase_auth/firebase_auth.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/models/user.dart';

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
  final AuthUser createdBy;
  @JsonKey(name: "count")
  final int count;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "members")
  final List<AuthUser> members;
  @JsonKey(name: "created_by_id")
  final String createdById;


  Room(this.id, this.fixturesId, this.fixture, this.createdBy, this.count, this.name, this.members, this.createdById);

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);

}