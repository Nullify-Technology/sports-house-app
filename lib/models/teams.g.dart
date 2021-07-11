// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teams.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Teams _$TeamsFromJson(Map<String, dynamic> json) {
  return Teams(
    json['home'] == null
        ? null
        : Team.fromJson(json['home'] as Map<String, dynamic>),
    json['away'] == null
        ? null
        : Team.fromJson(json['away'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TeamsToJson(Teams instance) => <String, dynamic>{
      'home': instance.home,
      'away': instance.away,
    };
