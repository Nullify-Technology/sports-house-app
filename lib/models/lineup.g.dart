// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lineup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lineup _$LineupFromJson(Map<String, dynamic> json) {
  return Lineup(
    json['formation'] as String?,
    (json['startXI'] as List<dynamic>?)
        ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
        .toList(),
    (json['substitutes'] as List<dynamic>?)
        ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
        .toList(),
    json['coach'] == null
        ? null
        : Coach.fromJson(json['coach'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LineupToJson(Lineup instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('formation', instance.formation);
  writeNotNull('startXI', instance.startXI);
  writeNotNull('substitutes', instance.substitutes);
  writeNotNull('coach', instance.coach);
  return val;
}
