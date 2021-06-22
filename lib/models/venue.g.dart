// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Venue _$VenueFromJson(Map<String, dynamic> json) {
  return Venue(
    json['id'] as int,
    json['name'] as String,
    json['city'] as String,
  );
}

Map<String, dynamic> _$VenueToJson(Venue instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['name'] = instance.name;
  val['city'] = instance.city;
  return val;
}
