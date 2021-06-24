import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:match_cafe/utils/constants.dart';
import 'config/app_config.dart';
import 'main.dart';

Future<void> main() async {
  // _setupLogging();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  var configuration = AppConfig(
    appTitle: kAppName + "-dev",
    buildFlavour: kDevelopment,
    child: MyApp(),
  );
  return runApp(configuration);
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    debugPrint('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}
