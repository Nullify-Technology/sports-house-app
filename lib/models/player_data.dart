import 'package:json_annotation/json_annotation.dart';

part 'player_data.g.dart';

@JsonSerializable()
class PlayerData {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "photo")
  final String photo;

  factory PlayerData.fromJson(Map<String, dynamic> json) => _$PlayerDataFromJson(json);

  PlayerData(this.id, this.name, this.photo);
  Map<String, dynamic> toJson() => _$PlayerDataToJson(this);
}
