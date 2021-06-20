// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameHistory _$GameHistoryFromJson(Map<String, dynamic> json) {
  return GameHistory(
    json['win'] as int?,
    json['played'] as int?,
    json['draw'] as int?,
    json['lose'] as int?,
    json['goals'] == null
        ? null
        : Goals.fromJson(json['goals'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$GameHistoryToJson(GameHistory instance) =>
    <String, dynamic>{
      'win': instance.win,
      'played': instance.played,
      'draw': instance.draw,
      'lose': instance.lose,
      'goals': instance.goals,
    };
