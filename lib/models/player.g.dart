// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return Player(
    json['id'] as int,
    json['name'] as String,
    json['pos'] as String,
    json['number'] as int,
    json['grid'] as String,
  );
}

Map<String, dynamic> _$PlayerToJson(Player instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'pos': instance.pos,
    'number': instance.number,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('grid', instance.grid);
  return val;
}
