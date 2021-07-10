// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) {
  return AuthUser(
    json['id'] as String?,
    json['phone'] as String?,
    json['name'] as String?,
    json['profile_picture_url'] as String?,
    json['has_access'] as bool?,
    json['peerId'] as String?,
  )
    ..muted = json['muted'] as bool?
    ..joined = json['joined'] as bool?
    ..isModerator = json['isModerator'] as bool?
    ..isSpeaker = json['isSpeaker'] as bool?;
}

Map<String, dynamic> _$AuthUserToJson(AuthUser instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'phone': instance.phone,
    'name': instance.name,
    'profile_picture_url': instance.profilePictureUrl,
    'has_access': instance.hasAccess,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('muted', instance.muted);
  writeNotNull('joined', instance.joined);
  writeNotNull('isModerator', instance.isModerator);
  writeNotNull('isSpeaker', instance.isSpeaker);
  writeNotNull('peerId', instance.peerId);
  return val;
}
