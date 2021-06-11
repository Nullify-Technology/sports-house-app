

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:sports_house/models/agora_room.dart';
import 'package:sports_house/models/api_response.dart';
import 'package:sports_house/models/auth.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/models/room.dart';

import 'interceptors/logging_interceptor.dart';

part 'rest_client.g.dart';

@RestApi(baseUrl: "https://asia-south1-sports-house-1b0a9.cloudfunctions.net/app")
abstract class RestClient {
  
  @POST("/user")
  @FormUrlEncoded()
  Future<Auth> getUser(@Field("phone") String phone, @Field("id_token") String idToken);

  @PATCH("/user")
  @FormUrlEncoded()
  Future<Auth> updateUser({@Field("name") String? name, @Field("profile_picture_url") String? profileUrl});

  @GET("/fixture")
  Future<ApiResponse<Fixture>> getFixtures();

  @GET("/fixture/{fixtureId}/rooms")
  Future<ApiResponse<Room>> getRooms(@Path() String fixtureId);

  @POST("/room")
  @FormUrlEncoded()
  Future<AgoraRoom> createRoom(@Field("fixture_id") String fixtureId, @Field("user_id") String userId, @Field("name") String name);

  @POST("/room/{roomId}/join")
  Future<AgoraRoom> joinRoom(@Path() String roomId);

  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  static RestClient create({String? baseUrl}) {
    final dio = Dio();
    dio.interceptors.add(HttpLoggingInterceptor());
    dio.options.headers["Content-Type"] = "application/json";
    if(baseUrl != null){
      return RestClient(dio, baseUrl: baseUrl);
    }
    return RestClient(dio);
  }
}