// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Standings _$StandingsFromJson(Map<String, dynamic> json) {
  return Standings(
    json['description'] as String,
    json['name'] as String,
    (json['teams'] as List<dynamic>)
        ?.map((e) => TeamStanding.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$StandingsToJson(Standings instance) => <String, dynamic>{
      'description': instance.description,
      'name': instance.name,
      'teams': instance.teams,
    };
