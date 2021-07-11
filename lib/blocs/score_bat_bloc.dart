import 'package:match_cafe/models/fixture.dart';
import 'package:match_cafe/models/score_bat.dart';
import 'package:match_cafe/models/score_bat_video.dart';
import 'package:match_cafe/network/rest_client.dart';
import 'package:match_cafe/utils/constants.dart';

class ScoreBatBloc {
  late RestClient client;

  ScoreBatBloc() {
    client = RestClient.createWithUrl(kScoreBatApi);
  }

  Future<List<ScoreBat>> getHighLights(List<Fixture> fixtures) async{
    List<ScoreBat> highLights = [];
    try{
      List<ScoreBat> response = await client.fetchHighlights();
      fixtures.forEach((fixture) {
        response.forEach((r) {
          if(_checkFixture(fixture, r)){
            highLights.add(r);
          }
        });
      });
    }catch(e){
      print(e);
      throw e;
    }
    return highLights;
  }

  bool _checkFixture(Fixture fixture, ScoreBat r) {
    if(((fixture.teams!.home!.name!.toLowerCase().contains(r.side1!.name!.toLowerCase()) 
        && fixture.teams!.away!.name!.toLowerCase().contains(r.side2!.name!.toLowerCase()))
        ||
        (fixture.teams!.home!.name!.toLowerCase().contains(r.side2!.name!.toLowerCase())
            && fixture.teams!.away!.name!.toLowerCase().contains(r.side1!.name!.toLowerCase())))
        && DateTime.parse(fixture.date!).isAtSameMomentAs(DateTime.parse(r.date!)) && _hasHighlights(r.videos)){
      return true;
    }
    return false;
  }

  bool _hasHighlights(List<ScoreBatVideo> videos) {
    bool hasHighlights = false;
    if(videos.isNotEmpty){
      videos.forEach((video) {
        if(video.title == "Highlights"){
          hasHighlights = true;
          return;
        }
      });
    }
    return hasHighlights;
  }
}