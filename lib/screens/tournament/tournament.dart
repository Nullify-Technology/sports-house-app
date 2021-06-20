import 'package:flutter/material.dart';

class TournamentScreenArguments {
  final String tournamentId;
  final String tournamentName;

  TournamentScreenArguments(this.tournamentId, this.tournamentName);
}

class TournamentScreen extends StatefulWidget {
  TournamentScreen({Key? key, required this.arguments}) : super(key: key);
  static String pageId = 'TournamentScreen';
  final TournamentScreenArguments arguments;

  @override
  _TournamentScreenState createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.arguments.tournamentName,
        ),
      ),
    );
  }
}
