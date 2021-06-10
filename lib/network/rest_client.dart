
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:sports_house/models/auth.dart';
import 'package:sports_house/models/fixture.dart';
import 'package:sports_house/models/fixtures.dart';
import 'package:sports_house/models/user.dart';

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
  Future<Fixtures> getFixtures();

  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  static RestClient create() {
    final dio = Dio();
    dio.interceptors.add(HttpLoggingInterceptor());
    dio.options.headers["Content-Type"] = "application/json";
    return RestClient(dio);
  }
}