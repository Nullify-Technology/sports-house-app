// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixtures.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fixtures _$FixturesFromJson(Map<String, dynamic> json) {
  return Fixtures(
    (json['results'] as List<dynamic>)
        .map((e) => Fixture.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$FixturesToJson(Fixtures instance) => <String, dynamic>{
      'results': instance.results,
    };
