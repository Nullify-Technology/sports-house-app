// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coach _$CoachFromJson(Map<String, dynamic> json) {
  return Coach(
    json['id'] as int?,
    json['name'] as String?,
    json['photo'] as String?,
  );
}

Map<String, dynamic> _$CoachToJson(Coach instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'photo': instance.photo,
    };
