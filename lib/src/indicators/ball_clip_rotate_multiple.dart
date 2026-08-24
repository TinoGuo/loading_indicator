import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/control/loading_indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';
import 'package:loading_indicator/src/transition/matrix4_transform.dart';

/// BallClipRotateMultiple.
class BallClipRotateMultiple extends StatefulWidget {
  const BallClipRotateMultiple({Key? key}) : super(key: key);

  @override
  State<BallClipRotateMultiple> createState() => _BallClipRotateMultipleState();
}

class _BallClipRotateMultipleState extends State<BallClipRotateMultiple>
    with SingleTickerProviderStateMixin, IndicatorController {
  static const _durationInMills = 1000;

  late AnimationController _animationController;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: _durationInMills));
    _rotateAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi), weight: 1),
      TweenSequenceItem(tween: Tween(begin: pi, end: 2 * pi), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.0), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraint) => AnimatedBuilder(
        animation: _animationController,
        builder: (_, child) => Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..scaleWithValues(_scaleAnimation.value, _scaleAnimation.value,
                    _scaleAnimation.value, 1.0)
                ..rotateZ(_rotateAnimation.value),
              child: child,
            ),
            Positioned(
              left: constraint.maxWidth / 4,
              top: constraint.maxHeight / 4,
              width: constraint.maxWidth / 2,
              height: constraint.maxHeight / 2,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scaleWithValues(_scaleAnimation.value, _scaleAnimation.value,
                      _scaleAnimation.value, 1.0)
                  ..rotateZ(-_rotateAnimation.value),
                child: child,
              ),
            ),
          ],
        ),
        child: const IndicatorShapeWidget(shape: Shape.ringTwoHalfVertical),
      ),
    );
  }
}
