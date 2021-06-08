// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) {
  return AuthUser(
    id: json['id'] as String,
    phone: json['phone'] as String,
    name: json['name'] as String?,
    profilePictureUrl: json['profile_picture_url'] as String?,
    hasAccess: json['has_access'] as bool,
  );
}

Map<String, dynamic> _$AuthUserToJson(AuthUser instance) => <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'name': instance.name,
      'profile_picture_url': instance.profilePictureUrl,
      'has_access': instance.hasAccess,
    };
