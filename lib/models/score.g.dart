// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Score _$ScoreFromJson(Map<String, dynamic> json) {
  return Score(
    json['home'] as int,
    json['away'] as int,
  );
}

Map<String, dynamic> _$ScoreToJson(Score instance) => <String, dynamic>{
      'home': instance.home,
      'away': instance.away,
    };
