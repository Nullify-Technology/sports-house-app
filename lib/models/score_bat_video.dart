import 'package:json_annotation/json_annotation.dart';

part 'score_bat_video.g.dart';
@JsonSerializable()
class ScoreBatVideo {
  @JsonKey(name: "title")
  final String? title;
  @JsonKey(name: "embed")
  final String? embed;

  ScoreBatVideo(this.title, this.embed);

  factory ScoreBatVideo.fromJson(Map<String, dynamic> json) => _$ScoreBatVideoFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreBatVideoToJson(this);
}