// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Venue _$VenueFromJson(Map<String, dynamic> json) {
  return Venue(
    json['id'] as int?,
    json['name'] as String,
    json['city'] as String,
  );
}

Map<String, dynamic> _$VenueToJson(Venue instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'city': instance.city,
    };
