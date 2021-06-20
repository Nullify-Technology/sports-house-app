// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_standings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentStandings _$TournamentStandingsFromJson(Map<String, dynamic> json) {
  return TournamentStandings(
    json['id'] as String?,
    json['name'] as String?,
    json['banner'] as String?,
    json['logo'] as String?,
    (json['standings'] as List<dynamic>?)
        ?.map((e) => Standings.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$TournamentStandingsToJson(
        TournamentStandings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'banner': instance.banner,
      'logo': instance.logo,
      'standings': instance.standings,
    };
