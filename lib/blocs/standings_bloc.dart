import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sports_house/models/api_response.dart';
import 'package:sports_house/models/response.dart';
import 'package:sports_house/models/standings.dart';
import 'package:sports_house/models/team_standing.dart';
import 'package:sports_house/models/tournament_standings.dart';
import 'package:sports_house/models/user.dart';
import 'package:sports_house/network/rest_client.dart';
import 'package:sports_house/utils/constants.dart';

class StandingsBloc {
  final RestClient client;
  late StreamController<Response<TournamentStandings>> _standingsController;
  final flutterStorage = FlutterSecureStorage();
  final ImagePicker picker = ImagePicker();
  FirebaseStorage _storage = FirebaseStorage.instance;

  StreamSink<Response<TournamentStandings>> get standingsSink =>
      _standingsController.sink;

  Stream<Response<TournamentStandings>> get standingsStream =>
      _standingsController.stream;

  StandingsBloc({required this.client}) {
    this._standingsController =
        StreamController<Response<TournamentStandings>>.broadcast();
    standingsSink.add(Response.loading('Initialising tournaments Details'));
  }

  // Future getStandings(tournamentId) async {
  //   standingsSink.add(Response.loading('Getting tournaments Details'));
  //   try {
  //     ApiResponse<TournamentStandings> response =
  //         await client.getStandings(tournamentId);
  //     standingsSink.add(Response.completed(response.results));
  //   } catch (e) {
  //     standingsSink.add(Response.error(e.toString()));
  //     print(e);
  //   }
  // }

  Future getStandings(String tournamentId) async {
    try {
      Future<TournamentStandings> response =
          client.getStandings(tournamentId);
      return response;
    } catch (e) {
      print(e);
    }
  }

  dispose() {
    _standingsController.close();
  }
}
