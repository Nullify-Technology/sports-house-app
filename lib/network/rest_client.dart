import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:match_cafe/models/agora_room.dart';
import 'package:match_cafe/models/api_response.dart';
import 'package:match_cafe/models/auth.dart';
import 'package:match_cafe/models/fixture.dart';
import 'package:match_cafe/models/room.dart';
import 'package:match_cafe/models/tournament.dart';
import 'package:match_cafe/models/tournament_standings.dart';
import 'package:match_cafe/utils/constants.dart';

import 'interceptors/logging_interceptor.dart';

part 'rest_client.g.dart';

@RestApi(baseUrl: kBaseUrl)
abstract class RestClient {
  @POST("/user")
  @FormUrlEncoded()
  Future<Auth> getUser(
      @Field("phone") String phone, @Field("id_token") String idToken);

  @PATCH("/user")
  @FormUrlEncoded()
  Future<Auth> updateUser(
      {@Field("name") String name,
        @Field("profile_picture_url") String profileUrl});

  @GET("/fixture")
  Future<ApiResponse<Fixture>> getFixtures();

  @GET("/tournament")
  Future<ApiResponse<Tournament>> getTournaments();

  @GET("/tournament/{tournamentId}/fixtures?live=true")
  Future<ApiResponse<Fixture>> getLiveTournamentFixtures(
      @Path() String tournamentId);

  @GET("/tournament/{tournamentId}/standings")
  Future<TournamentStandings> getStandings(@Path() String tournamentId);

  @GET("/room/trending/")
  Future<ApiResponse<Room>> getTrendingRooms();

  @GET("/fixture/{fixtureId}/rooms")
  Future<ApiResponse<Room>> getRooms(
      @Path() String fixtureId,
      );

  @POST("/room")
  @FormUrlEncoded()
  Future<AgoraRoom> createRoom(@Field("fixture_id") String fixtureId,
      @Field("user_id") String userId, @Field("name") String name,@Field("type") String type);

  @POST("/room/{roomId}/join")
  Future<AgoraRoom> joinRoom(@Path() String roomId);

  @POST("/room/{roomId}/leave")
  Future<void> leaveRoom(@Path() String roomId);

  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  static RestClient create() {
    final dio = Dio();
    dio.interceptors.add(HttpLoggingInterceptor());
    dio.options.headers["Content-Type"] = "application/json";
    return RestClient(dio);
  }
}
