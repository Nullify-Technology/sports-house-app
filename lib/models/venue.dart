

import 'package:json_annotation/json_annotation.dart';

part 'venue.g.dart';

@JsonSerializable()
class Venue{
  @JsonKey(name: "id" ,includeIfNull: false)
  final int? id;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "city")
  final String city;

  Venue(this.id, this.name, this.city);

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);
  Map<String, dynamic> toJson() => _$VenueToJson(this);

}