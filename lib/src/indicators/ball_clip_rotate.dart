import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/control/loading_indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';
import 'package:loading_indicator/src/transition/matrix4_transform.dart';

/// BallClipRotate.
class BallClipRotate extends StatefulWidget {
  const BallClipRotate({Key? key}) : super(key: key);

  @override
  State<BallClipRotate> createState() => _BallClipRotateState();
}

class _BallClipRotateState extends State<BallClipRotate>
    with SingleTickerProviderStateMixin, IndicatorController {
  static const _durationInMills = 750;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _durationInMills),
    );
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    _rotateAnimation = Tween(begin: 0.0, end: 2 * pi).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));

    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scaleWithValues(_scaleAnimation.value, _scaleAnimation.value,
                _scaleAnimation.value, 1.0)
            ..rotateZ(_rotateAnimation.value),
          child: child,
        );
      },
      child: const IndicatorShapeWidget(shape: Shape.ringThirdFour),
    );
  }
}
