import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _kMargin = 14.0;
const _kHeight = 62.0;
const _kCircleRadius = 30.0;
const _kCircleMargin = 8.0;
const _kTopRadius = 10.0;
const _kBottomRadius = 28.0;
const _kItemSize = 30.0;
const _kPi = 3.1415926535897932;

class FloatingBottomBarItem {
  const FloatingBottomBarItem(this.iconData, {required this.label});

  final IconData iconData;
  final String label;
}

class FloatingBottomBar extends StatefulWidget {
  const FloatingBottomBar({
    required this.controller,
    required this.items,
    required this.onTap,
    this.color = Colors.black,
    this.itemColor = Colors.white,
    this.activeItemColor = Colors.red,
    this.enableIconRotation = false,
  });

  final PageController controller;
  final List<FloatingBottomBarItem> items;
  final ValueChanged<int> onTap;
  final Color color;
  final Color itemColor;
  final Color activeItemColor;
  final bool enableIconRotation;

  @override
  _FloatingBottomBarState createState() => _FloatingBottomBarState();
}

class _FloatingBottomBarState extends State<FloatingBottomBar> {
  double _screenWidth = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    const height = _kHeight + _kMargin * 2;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, child) {
        var scrollPosition = 0.0;
        var currentIndex = 0;
        if (widget.controller.hasClients) {
          scrollPosition = widget.controller.page!;
          currentIndex = (widget.controller.page! + 0.5).toInt();
        }

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[],
        );
      },
    );
  }

  double _firstItemX() {
    return _kMargin + (_screenWidth - _kMargin * 2) * 0.1;
  }

  double _lastItemX() {
    return _screenWidth -
        _kMargin -
        (_screenWidth - _kMargin * 2) * 0.1 -
        (_kCircleRadius + _kCircleMargin) * 2;
  }

  double _itemDistance() {
    return (_lastItemX() - _firstItemX()) / (widget.items.length - 1);
  }

  double _itemXByScrollPosition(double scrollPosition) {
    return _firstItemX() + _itemDistance() * scrollPosition;
  }

  double _itemXByIndex(int index) {
    return _firstItemX() + _itemDistance() * index;
  }
}

class _Item extends StatelessWidget {
  const _Item(
    this.index, {
    required this.iconData,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final int index;
  final IconData iconData;
  final String label;
  final Color color;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: SizedBox.fromSize(
        size: const Size(_kCircleRadius * 2, _kCircleRadius * 2),
        child: RawMaterialButton(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                iconData,
                size: _kItemSize - 4,
                color: color,
              ),
              if (label != null) ...[
                const SizedBox(height: 3.0),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ],
          ),
          onPressed: () => onTap(index),
        ),
      ),
    );
  }
}

class _ActiveItem extends StatelessWidget {
  const _ActiveItem(
    this.index, {
    required this.iconData,
    required this.color,
    required this.scrollPosition,
    required this.enableRotation,
    required this.onTap,
  });

  final int index;
  final IconData iconData;
  final Color color;
  final double scrollPosition;
  final bool enableRotation;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      iconData,
      size: _kItemSize,
      color: color,
    );

    return InkWell(
      child: SizedBox.fromSize(
        size: const Size(_kCircleRadius * 2, _kCircleRadius * 2),
        child: enableRotation
            ? Transform.rotate(
                angle: _kPi * 2 * (scrollPosition % 1),
                child: icon,
              )
            : icon,
      ),
      onTap: () => onTap(index),
    );
  }
}

class _Painter extends CustomPainter {
  _Painter({required this.x, required this.color})
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true,
        _shadowColor =
            kIsWeb ? Colors.grey.shade600 : Colors.grey.withOpacity(0.4);

  final double x;
  final Color color;
  final Paint _paint;
  final Color _shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBar(canvas, size);
    _drawCircle(canvas);
  }

  @override
  bool shouldRepaint(_Painter oldDelegate) {
    return x != oldDelegate.x || color != oldDelegate.color;
  }

  void _drawBar(Canvas canvas, Size size) {
    const left = _kMargin;
    final right = size.width - _kMargin;
    const top = _kMargin;
    const bottom = top + _kHeight;

    final path = Path()
      ..moveTo(left + _kTopRadius, top)
      ..lineTo(x - _kTopRadius, top)
      ..relativeArcToPoint(
        const Offset(_kTopRadius, _kTopRadius),
        radius: const Radius.circular(_kTopRadius),
      )
      ..relativeArcToPoint(
        const Offset((_kCircleRadius + _kCircleMargin) * 2, 0.0),
        radius: const Radius.circular(_kCircleRadius + _kCircleMargin),
        clockwise: false,
      )
      ..relativeArcToPoint(
        const Offset(_kTopRadius, -_kTopRadius),
        radius: const Radius.circular(_kTopRadius),
      )
      ..lineTo(right - _kTopRadius, top)
      ..relativeArcToPoint(
        const Offset(_kTopRadius, _kTopRadius),
        radius: const Radius.circular(_kTopRadius),
      )
      ..lineTo(right, bottom - _kBottomRadius)
      ..relativeArcToPoint(
        const Offset(-_kBottomRadius, _kBottomRadius),
        radius: const Radius.circular(_kBottomRadius),
      )
      ..lineTo(left + _kBottomRadius, bottom)
      ..relativeArcToPoint(
        const Offset(-_kBottomRadius, -_kBottomRadius),
        radius: const Radius.circular(_kBottomRadius),
      )
      ..lineTo(left, top + _kTopRadius)
      ..relativeArcToPoint(
        const Offset(_kTopRadius, -_kTopRadius),
        radius: const Radius.circular(_kTopRadius),
      );

    canvas
      ..drawShadow(path, _shadowColor, 5.0, false)
      ..drawPath(path, _paint);
  }

  void _drawCircle(Canvas canvas) {
    final path = Path()
      ..addArc(
        Rect.fromCircle(
          center: Offset(
            x + _kCircleMargin + _kCircleRadius,
            _kMargin + _kCircleMargin,
          ),
          radius: _kCircleRadius,
        ),
        0,
        _kPi * 2,
      );

    canvas
      ..drawShadow(path, _shadowColor, 3.0, false)
      ..drawPath(path, _paint);
  }
}
