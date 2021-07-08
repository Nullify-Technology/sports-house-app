

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class AuthUser{
 @JsonKey(name: "id")
 final String id;
 @JsonKey(name: "phone")
 final String phone;
 @JsonKey(name: "name")
 final String name;
 @JsonKey(name: "profile_picture_url")
 final String profilePictureUrl;
 @JsonKey(name: "has_access")
 final bool hasAccess;
 @JsonKey(name: "muted" ,includeIfNull: false)
 bool muted = true;
 @JsonKey(name: "joined" ,includeIfNull: false)
 bool joined = false;
 @JsonKey(name: "peerId" ,includeIfNull: false)
 String peerId;

 AuthUser({ this.id,  this.phone, this.name, this.profilePictureUrl,  this.hasAccess, this.peerId});

 factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);
 Map<String, dynamic> toJson() => _$AuthUserToJson(this);

}