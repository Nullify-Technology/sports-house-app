// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agora_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgoraRoom _$AgoraRoomFromJson(Map<String, dynamic> json) {
  return AgoraRoom(
    json['room'] == null
        ? null
        : Room.fromJson(json['room'] as Map<String, dynamic>),
    json['token'] as String?,
  );
}

Map<String, dynamic> _$AgoraRoomToJson(AgoraRoom instance) => <String, dynamic>{
      'room': instance.room,
      'token': instance.token,
    };
