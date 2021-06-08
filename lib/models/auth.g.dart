// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Auth _$AuthFromJson(Map<String, dynamic> json) {
  return Auth(
    user: json['user'] == null
        ? null
        : AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    accessToken: json['token'] as String?,
  );
}

Map<String, dynamic> _$AuthToJson(Auth instance) => <String, dynamic>{
      'user': instance.user,
      'token': instance.accessToken,
    };
