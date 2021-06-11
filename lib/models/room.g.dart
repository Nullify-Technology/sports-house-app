// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) {
  return Room(
    json['id'] as String,
    json['fixture_id'] as String,
    Fixture.fromJson(json['fixture'] as Map<String, dynamic>),
    json['created_by'] as String,
    json['count'] as int,
    json['name'] as String,
  );
}

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'id': instance.id,
      'fixture_id': instance.fixturesId,
      'fixture': instance.fixture,
      'created_by': instance.createdBy,
      'count': instance.count,
      'name': instance.name,
    };
