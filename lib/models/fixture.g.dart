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
    MatchDetails.fromJson(json['score'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$FixtureToJson(Fixture instance) => <String, dynamic>{
      'id': instance.id,
      'venue': instance.venue,
      'date': instance.date,
      'teams': instance.teams,
      'externalId': instance.externalId,
      'score': instance.score,
    };
