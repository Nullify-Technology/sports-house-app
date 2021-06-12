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
    AuthUser.fromJson(json['created_by'] as Map<String, dynamic>),
    json['count'] as int,
    json['name'] as String,
    (json['members'] as List<dynamic>)
        .map((e) => AuthUser.fromJson(e as Map<String, dynamic>))
        .toList(),
    json['created_by_id'] as String,
  );
}

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'id': instance.id,
      'fixture_id': instance.fixturesId,
      'fixture': instance.fixture,
      'created_by': instance.createdBy,
      'count': instance.count,
      'name': instance.name,
      'members': instance.members,
      'created_by_id': instance.createdById,
    };
