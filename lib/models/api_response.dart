

import 'package:json_annotation/json_annotation.dart';
import 'package:sports_house/models/fixture.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T>{
  @JsonKey(name: "results")
  final List<T> results;

  ApiResponse(this.results);

  factory ApiResponse.fromJson(Map<String, dynamic> json,  T Function(Object json) fromJsonT) => _$ApiResponseFromJson(json,fromJsonT);
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) => _$ApiResponseToJson(this,toJsonT);

}