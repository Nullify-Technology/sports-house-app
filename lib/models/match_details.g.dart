// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchDetails _$MatchDetailsFromJson(Map<String, dynamic> json) {
  return MatchDetails(
    json['current'] == null
        ? null
        : Score.fromJson(json['current'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$MatchDetailsToJson(MatchDetails instance) =>
    <String, dynamic>{
      'current': instance.current,
    };
