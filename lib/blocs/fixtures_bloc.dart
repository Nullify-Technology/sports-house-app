import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:match_cafe/models/fixture.dart';
import 'package:match_cafe/models/api_response.dart';
import 'package:match_cafe/models/response.dart';
import 'package:match_cafe/network/rest_client.dart';

class FixtureBloc{

  final RestClient client;
  late StreamController<Response<List<Fixture>>> _fixturesController;
  final flutterStorage = FlutterSecureStorage();
  final ImagePicker picker = ImagePicker();
  FirebaseStorage _storage = FirebaseStorage.instance;

  StreamSink<Response<List<Fixture>>> get fixturesSink =>
      _fixturesController.sink;

  Stream<Response<List<Fixture>>> get fixturesStream =>
      _fixturesController.stream;


  FixtureBloc({ required this.client}){
    this._fixturesController = StreamController<Response<List<Fixture>>>.broadcast();
    fixturesSink.add(Response.loading('Initialising fixtures Details'));
  }

  Future getFixtures() async {
    fixturesSink.add(Response.loading('Getting fixtures Details'));
    try{
      ApiResponse<Fixture> response = await client.getFixtures();
      fixturesSink.add(Response.completed(response.results));
    }catch(e){
      fixturesSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future getLiveTournamentFixtures(tournamentId) async {
    fixturesSink.add(Response.loading('Getting tournament fixtures'));
    try {
      ApiResponse<Fixture> response =
          await client.getLiveTournamentFixtures(tournamentId);
      fixturesSink.add(Response.completed(response.results));
    } catch (e) {
      fixturesSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _fixturesController.close();
  }
}