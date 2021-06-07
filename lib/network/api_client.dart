
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:sports_house/models/auth.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://asia-south1-sports-house-1b0a9.cloudfunctions.net/app/")
abstract class RestClient {

  @POST("/user")
  @FormUrlEncoded()

  Future<Auth> getUser(@Field("phone") String phone, @Field("id_token") String idToken);

  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;
}