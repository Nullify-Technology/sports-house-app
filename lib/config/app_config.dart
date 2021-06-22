import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  final String appTitle;
  final String buildFlavour;
  final Widget child;

  AppConfig({
    this.appTitle,
    this.buildFlavour,
    this.child,
  }) : super(child: child);

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
