// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Team _$TeamFromJson(Map<String, dynamic> json) {
  return Team(
    json['id'] as String,
    json['name'] as String,
    json['externalId'] as int,
    json['logo_url'] as String,
    Lineup.fromJson(json['lineups'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'externalId': instance.externalId,
      'logo_url': instance.logoUrl,
      'lineups': instance.lineups,
    };
