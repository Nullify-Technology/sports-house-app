import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:sports_house/utils/constants.dart';

class HttpLoggingInterceptor extends InterceptorsWrapper{
  final log = Logger('HttpLoggingInterceptor');
  final storage = FlutterSecureStorage();
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
      String token = await storage.read(key: kAccessToken) as String;
      options.headers["Authorization"] = "Bearer " + token;

      log.warning("---------------------------------Request-----------------------");
      log.info(options.uri);
      log.info(options.method);
      log.info(options.headers);
      log.info(options.data);
      log.info(options.path);
      log.warning("----------------------------------------------------------------");

      handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log.warning("---------------------------------Response-----------------------");
    log.info(response.statusCode);
    log.info(response.data);
    log.warning("----------------------------------------------------------------");
    handler.resolve(response);
  }
}