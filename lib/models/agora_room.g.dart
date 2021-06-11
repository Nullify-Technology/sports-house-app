// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agora_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgoraRoom _$AgoraRoomFromJson(Map<String, dynamic> json) {
  return AgoraRoom(
    Room.fromJson(json['room'] as Map<String, dynamic>),
    json['channel'] as String,
    json['token'] as String,
  );
}

Map<String, dynamic> _$AgoraRoomToJson(AgoraRoom instance) => <String, dynamic>{
      'room': instance.room,
      'channel': instance.channel,
      'token': instance.token,
    };
