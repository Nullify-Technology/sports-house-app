

import 'package:json_annotation/json_annotation.dart';
import 'package:sports_house/models/user.dart';

part 'auth.g.dart';

@JsonSerializable()
class Auth{
  @JsonKey(name: "user")
  final User user;

  @JsonKey(name: "access_token")
  final String accessToken;

  Auth(this.user, this.accessToken);

  factory Auth.fromJson(Map<String, dynamic> json) => _$AuthFromJson(json);
  Map<String, dynamic> toJson() => _$AuthToJson(this);
}