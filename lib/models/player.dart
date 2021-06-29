import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable()
class Player {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "pos")
  final String pos;
  @JsonKey(name: "number")
  final int number;
  @JsonKey(name: "grid", includeIfNull: false)
  final String grid;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  Player(this.id, this.name, this.pos, this.number, this.grid);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
