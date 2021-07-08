// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) {
  return AuthUser(
    id: json['id'] as String,
    phone: json['phone'] as String,
    name: json['name'] as String,
    profilePictureUrl: json['profile_picture_url'] as String,
    hasAccess: json['has_access'] as bool,
  )
    ..muted = json['muted'] as bool
    ..joined = json['joined'] as bool
    ..peerId = json["peedId"] as String;
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
  writeNotNull('peerId', instance.peerId);
  return val;
}
