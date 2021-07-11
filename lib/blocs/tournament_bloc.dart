import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:match_cafe/models/tournament.dart';
import 'package:match_cafe/models/api_response.dart';
import 'package:match_cafe/models/response.dart';
import 'package:match_cafe/network/rest_client.dart';

class TournamentBloc {
  final RestClient client;
  late StreamController<Response<List<Tournament>>> _tournamentsController;
  final flutterStorage = FlutterSecureStorage();
  final ImagePicker picker = ImagePicker();
  FirebaseStorage _storage = FirebaseStorage.instance;

  StreamSink<Response<List<Tournament>>> get tournamentsSink =>
      _tournamentsController.sink;

  Stream<Response<List<Tournament>>> get tournamentsStream =>
      _tournamentsController.stream;

  TournamentBloc({required this.client}) {
    this._tournamentsController =
        StreamController<Response<List<Tournament>>>.broadcast();
    tournamentsSink.add(Response.loading('Initialising tournaments Details'));
  }

  Future getTournaments() async {
    tournamentsSink.add(Response.loading('Getting tournaments Details'));
    try {
      ApiResponse<Tournament> response = await client.getTournaments();
      tournamentsSink.add(Response.completed(response.results));
    } catch (e) {
      tournamentsSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _tournamentsController.close();
  }
}
