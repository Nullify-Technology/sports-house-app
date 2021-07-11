// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_bat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScoreBat _$ScoreBatFromJson(Map<String, dynamic> json) {
  return ScoreBat(
    json['url'] as String?,
    json['thumbnail'] as String?,
    json['date'] as String?,
    json['side1'] == null
        ? null
        : ScoreBatSide.fromJson(json['side1'] as Map<String, dynamic>),
    json['side2'] == null
        ? null
        : ScoreBatSide.fromJson(json['side2'] as Map<String, dynamic>),
    (json['videos'] as List<dynamic>)
        .map((e) => ScoreBatVideo.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$ScoreBatToJson(ScoreBat instance) => <String, dynamic>{
      'url': instance.url,
      'thumbnail': instance.thumbnail,
      'date': instance.date,
      'side1': instance.side1,
      'side2': instance.side2,
      'videos': instance.videos,
    };
