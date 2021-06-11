

import 'package:json_annotation/json_annotation.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/models/room.dart';

part 'agora_room.g.dart';

@JsonSerializable()
class AgoraRoom{
  @JsonKey(name: "room")
  final Room room;
  @JsonKey(name: "token")
  final String token;


  AgoraRoom(this.room, this.token);

  factory AgoraRoom.fromJson(Map<String, dynamic> json) => _$AgoraRoomFromJson(json);
  Map<String, dynamic> toJson() => _$AgoraRoomToJson(this);

}