import 'package:json_annotation/json_annotation.dart';

part 'season.g.dart';

@JsonSerializable()
class Season{

  @JsonKey(name: "year")
  final int year;
  @JsonKey(name: "start")
  final String start;
  @JsonKey(name: "end")
  final String end;

  Season(this.year, this.start, this.end,);

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
  Map<String, dynamic> toJson() => _$SeasonToJson(this);

}