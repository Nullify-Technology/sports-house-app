// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Goals _$GoalsFromJson(Map<String, dynamic> json) {
  return Goals(
    forTeam: json['for'] as int?,
    against: json['against'] as int?,
  );
}

Map<String, dynamic> _$GoalsToJson(Goals instance) => <String, dynamic>{
      'for': instance.forTeam,
      'against': instance.against,
    };
