// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _RestClient implements RestClient {
  _RestClient(this._dio, {this.baseUrl}) {
    baseUrl ??= 'https://asia-south1-sports-house-1b0a9.cloudfunctions.net/app';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<Auth> getUser(phone, idToken) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {'phone': phone, 'id_token': idToken};
    final _result = await _dio.fetch<Map<String, dynamic>>(_setStreamType<Auth>(
        Options(
                method: 'POST',
                headers: <String, dynamic>{},
                extra: _extra,
                contentType: 'application/x-www-form-urlencoded')
            .compose(_dio.options, '/user',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = Auth.fromJson(_result.data!);
    return value;
  }

  @override
  Future<Auth> updateUser({name, profileUrl}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _data = {'name': name, 'profile_picture_url': profileUrl};
    _data.removeWhere((k, v) => v == null);
    final _result = await _dio.fetch<Map<String, dynamic>>(_setStreamType<Auth>(
        Options(
                method: 'PATCH',
                headers: <String, dynamic>{},
                extra: _extra,
                contentType: 'application/x-www-form-urlencoded')
            .compose(_dio.options, '/user',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = Auth.fromJson(_result.data!);
    return value;
  }

  @override
  Future<ApiResponse<Fixture>> getFixtures() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ApiResponse<Fixture>>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, '/fixture',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ApiResponse<Fixture>.fromJson(
      _result.data!,
      (json) => Fixture.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<ApiResponse<Tournament>> getTournaments() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ApiResponse<Tournament>>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, '/tournament',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ApiResponse<Tournament>.fromJson(
      _result.data!,
      (json) => Tournament.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<ApiResponse<Room>> getTrendingRooms() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ApiResponse<Room>>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, '/room/trending/',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ApiResponse<Room>.fromJson(
      _result.data!,
      (json) => Room.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<ApiResponse<Room>> getRooms(fixtureId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<ApiResponse<Room>>(
            Options(method: 'GET', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, '/fixture/$fixtureId/rooms',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = ApiResponse<Room>.fromJson(
      _result.data!,
      (json) => Room.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<AgoraRoom> createRoom(fixtureId, userId, name) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {'fixture_id': fixtureId, 'user_id': userId, 'name': name};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<AgoraRoom>(Options(
                method: 'POST',
                headers: <String, dynamic>{},
                extra: _extra,
                contentType: 'application/x-www-form-urlencoded')
            .compose(_dio.options, '/room',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = AgoraRoom.fromJson(_result.data!);
    return value;
  }

  @override
  Future<AgoraRoom> joinRoom(roomId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<AgoraRoom>(
            Options(method: 'POST', headers: <String, dynamic>{}, extra: _extra)
                .compose(_dio.options, '/room/$roomId/join',
                    queryParameters: queryParameters, data: _data)
                .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = AgoraRoom.fromJson(_result.data!);
    return value;
  }

  @override
  Future<void> leaveRoom(roomId) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    await _dio.fetch<void>(_setStreamType<void>(
        Options(method: 'POST', headers: <String, dynamic>{}, extra: _extra)
            .compose(_dio.options, '/room/$roomId/leave',
                queryParameters: queryParameters, data: _data)
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    return null;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
