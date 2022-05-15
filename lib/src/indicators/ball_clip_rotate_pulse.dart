import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallClipRotatePulse.
class BallClipRotatePulse extends StatefulWidget {
  const BallClipRotatePulse({Key? key}) : super(key: key);

  @override
  State<BallClipRotatePulse> createState() => _BallClipRotatePulseState();
}

class _BallClipRotatePulseState extends State<BallClipRotatePulse>
    with SingleTickerProviderStateMixin, IndicatorController {
  late AnimationController _animationController;
  late Animation<double> _outCircleScale;
  late Animation<double> _outCircleRotate;
  late Animation<double> _innerCircle;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    const cubic = Cubic(0.09, 0.57, 0.49, 0.9);
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _outCircleScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));
    _outCircleRotate = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi), weight: 1),
      TweenSequenceItem(tween: Tween(begin: pi, end: 2 * pi), weight: 1),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));
    _innerCircle = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, child) => Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: <Widget>[
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(_outCircleScale.value)
              ..rotateZ(_outCircleRotate.value),
            child: const IndicatorShapeWidget(
              shape: Shape.ringTwoHalfVertical,
              index: 0,
            ),
          ),
          Transform.scale(
            scale: _innerCircle.value * 0.3,
            child: const IndicatorShapeWidget(
              shape: Shape.circle,
              index: 1,
            ),
          ),
        ],
      ),
    );
  }
}
