import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

class SemiCircleSpin extends StatefulWidget {
  @override
  _SemiCircleSpinState createState() => _SemiCircleSpinState();
}

/// TODO. remove every build to improve the performance.
class _SemiCircleSpinState extends State<SemiCircleSpin>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..addListener(() => setState(() {}));
    _animation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi), weight: 1),
      TweenSequenceItem(tween: Tween(begin: pi, end: 2 * pi), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _animation.value,
      child: IndicatorShapeWidget(Shape.circleSemi),
    );
  }
}
