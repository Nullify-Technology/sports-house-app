

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User{
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

 User(this.id, this.phone, this.name, this.profilePictureUrl, this.hasAccess);

 factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
 Map<String, dynamic> toJson() => _$UserToJson(this);

}