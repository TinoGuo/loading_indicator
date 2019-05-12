import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

class BallClipRotate extends StatefulWidget {
  @override
  _BallClipRotateState createState() => _BallClipRotateState();
}

/// TODO. remove every build to improve the performance.
class _BallClipRotateState extends State<BallClipRotate>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _scaleAnimation;
  Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..addListener(() => setState(() {}));
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    _rotateAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi), weight: 1),
      TweenSequenceItem(tween: Tween(begin: pi, end: 2 * pi), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scale(_scaleAnimation.value)
        ..rotateZ(_rotateAnimation.value),
      child: IndicatorShapeWidget(Shape.ringThirdFour),
    );
  }
}
