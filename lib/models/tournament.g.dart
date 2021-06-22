// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tournament _$TournamentFromJson(Map<String, dynamic> json) {
  return Tournament(
    json['id'] as String,
    json['name'] as String,
    json['season'] as int,
    json['externalId'] as int,
    json['banner'] as String,
    json['logo'] as String,
    json['current_season'] == null
        ? null
        : Season.fromJson(json['current_season'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TournamentToJson(Tournament instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'season': instance.season,
      'externalId': instance.externalId,
      'banner': instance.banner,
      'logo': instance.logo,
      'current_season': instance.currentSeason,
    };
