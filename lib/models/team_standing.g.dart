// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_standing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamStanding _$TeamStandingFromJson(Map<String, dynamic> json) {
  return TeamStanding(
    json['away'] == null
        ? null
        : GameHistory.fromJson(json['away'] as Map<String, dynamic>),
    json['all'] == null
        ? null
        : GameHistory.fromJson(json['all'] as Map<String, dynamic>),
    json['home'] == null
        ? null
        : GameHistory.fromJson(json['home'] as Map<String, dynamic>),
    json['rank'] as int,
    json['status'] as String,
    json['name'] as String,
    json['logo'] as String,
    json['form'] as String,
    json['points'] as int,
    json['goalsDiff'] as int,
    json['update'] as String,
  );
}

Map<String, dynamic> _$TeamStandingToJson(TeamStanding instance) =>
    <String, dynamic>{
      'away': instance.away,
      'all': instance.all,
      'home': instance.home,
      'rank': instance.rank,
      'status': instance.status,
      'name': instance.name,
      'logo': instance.logo,
      'form': instance.form,
      'points': instance.points,
      'goalsDiff': instance.goalsDiff,
      'update': instance.update,
    };
