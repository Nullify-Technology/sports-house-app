// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fixture _$FixtureFromJson(Map<String, dynamic> json) {
  return Fixture(
    json['id'] as String,
    Venue.fromJson(json['venue'] as Map<String, dynamic>),
    json['date'] as String,
    Teams.fromJson(json['teams'] as Map<String, dynamic>),
    json['externalId'] as int,
    json['round'] == null ? "Group" : json['round'] as String,
    json['score'] == null
        ? null
        : MatchDetails.fromJson(json['score'] as Map<String, dynamic>),
    json['status'] as String,
    (json['players'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, PlayerData.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$FixtureToJson(Fixture instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'venue': instance.venue,
    'date': instance.date,
    'teams': instance.teams,
    'externalId': instance.externalId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('score', instance.score);
  writeNotNull('status', instance.status);
  writeNotNull('players', instance.players);
  return val;
}
