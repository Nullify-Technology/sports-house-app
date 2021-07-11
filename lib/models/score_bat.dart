import 'package:json_annotation/json_annotation.dart';
import 'package:match_cafe/models/score_bat_side.dart';
import 'package:match_cafe/models/score_bat_video.dart';
part 'score_bat.g.dart';
@JsonSerializable()
class ScoreBat {
  @JsonKey(name: "url")
  final String? url;
  @JsonKey(name: "thumbnail")
  final String? thumbnail;
  @JsonKey(name: "date")
  final String? date;
  @JsonKey(name: "side1")
  final ScoreBatSide? side1;
  @JsonKey(name: "side2")
  final ScoreBatSide? side2;
  @JsonKey(name: "videos")
  final List<ScoreBatVideo> videos;

  ScoreBat(this.url, this.thumbnail, this.date, this.side1, this.side2, this.videos);

  factory ScoreBat.fromJson(Map<String, dynamic> json) => _$ScoreBatFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreBatToJson(this);
}


