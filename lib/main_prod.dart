import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:sports_house/utils/constants.dart';
import 'config/app_config.dart';
import 'main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  var configuration = AppConfig(
    appTitle: appName,
    buildFlavour: kProduction,
    child: MyApp(),
  );
  return runApp(configuration);
}
