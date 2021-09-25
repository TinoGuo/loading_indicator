import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallClipRotateMultiple.
class BallClipRotateMultiple extends StatefulWidget {
  const BallClipRotateMultiple({Key? key}) : super(key: key);

  @override
  _BallClipRotateMultipleState createState() => _BallClipRotateMultipleState();
}

class _BallClipRotateMultipleState extends State<BallClipRotateMultiple>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                ..scale(_scaleAnimation.value)
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
                  ..scale(_scaleAnimation.value)
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
