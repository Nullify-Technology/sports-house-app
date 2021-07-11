import 'package:flutter/material.dart';

class KeepAliveTab extends StatefulWidget {
  KeepAliveTab({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  _KeepAliveTabState createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<KeepAliveTab>
    with AutomaticKeepAliveClientMixin<KeepAliveTab> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: widget.child,
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}