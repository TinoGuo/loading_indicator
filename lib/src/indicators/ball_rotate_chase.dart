import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallRotateChase.
class BallRotateChase extends StatefulWidget {
  @override
  _BallRotateChaseState createState() => _BallRotateChaseState();
}

class _BallRotateChaseState extends State<BallRotateChase>
    with SingleTickerProviderStateMixin {
  static const _BALL_NUM = 5;

  late AnimationController _animationController;
  List<Animation<double>> _scaleAnimations = [];
  List<Animation<double>> _translateAnimations = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    for (int i = 0; i < _BALL_NUM; i++) {
      final rate = i / 5;
      final cubic = Cubic(0.5, 0.15 + rate, 0.25, 1.0);
      _scaleAnimations.add(Tween(begin: 1 - rate, end: 0.2 + rate).animate(
          CurvedAnimation(parent: _animationController, curve: cubic)));
      _translateAnimations.add(Tween(begin: 0.0, end: 2 * pi).animate(
          CurvedAnimation(parent: _animationController, curve: cubic)));

      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraint) {
      final circleSize = constraint.maxWidth / 5;

      final deltaX = (constraint.maxWidth - circleSize) / 2;
      final deltaY = (constraint.maxHeight - circleSize) / 2;

      final widgets = List<Widget>.filled(_BALL_NUM, Container());
      for (int i = 0; i < _BALL_NUM; i++) {
        widgets[i] = Positioned.fromRect(
          rect: Rect.fromLTWH(deltaX, deltaY, circleSize, circleSize),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (_, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(
                    deltaX * sin(_translateAnimations[i].value),
                    deltaY * -cos(_translateAnimations[i].value),
                  ),

                /// scale must in child, if upper would align topLeft.
                child: ScaleTransition(
                  scale: _scaleAnimations[i],
                  child: child,
                ),
              );
            },
            child: IndicatorShapeWidget(shape: Shape.circle),
          ),
        );
      }
      return Stack(children: widgets);
    });
  }
}
