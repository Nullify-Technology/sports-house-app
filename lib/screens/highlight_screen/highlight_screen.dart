import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart';
import 'package:match_cafe/models/score_bat_video.dart';
import 'package:match_cafe/utils/constants.dart';
import 'package:match_cafe/utils/reusable_components/CenterProgressBar.dart';
import 'package:url_launcher/url_launcher.dart';

class HighLightScreen extends StatefulWidget {
  final List<ScoreBatVideo> video;

  const HighLightScreen({Key? key, required this.video}) : super(key: key);

  @override
  _HighLightScreenState createState() => _HighLightScreenState();
}

class _HighLightScreenState extends State<HighLightScreen> {
  InAppWebViewController? webViewController;

  final InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));
  bool loading = true;
  late String highLightUrl;
  String url = "";

  String? _getHighLight() {
    for (ScoreBatVideo v in widget.video) {
      if (v.title == "Highlights") {
        return v.embed;
      }
    }
  }

  String parseHtml() {
    String element = "";
    String? highLight = _getHighLight();
    if (highLight != null) {
      var doc = parse(highLight);
      element = doc.querySelector("iframe")!.attributes['src']!;
    }
    return element;
  }

  @override
  void initState() {
    highLightUrl = parseHtml();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kColorBlack,
        extendBody: true,
        body: SafeArea(
            child: Stack(
          children: [
            InAppWebView(
              initialOptions: options,
              initialUrlRequest: URLRequest(url: Uri.parse(highLightUrl)),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  loading = true;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  loading = false;
                });
              },
              onLoadError: (controller, url, code, message) {
                print(message);
              },
            ),
            loading
                ? Container(
                    color: kColorBlack,
                    height: MediaQuery.of(context).size.height,
                    child: CenterProgressBar())
                : SizedBox(),
          ],
        )));
  }
}
