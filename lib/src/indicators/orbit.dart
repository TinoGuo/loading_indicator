import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// Orbit.
class Orbit extends StatefulWidget {
  @override
  _OrbitState createState() => _OrbitState();
}

class _OrbitState extends State<Orbit> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _ring1ScaleAnimation;
  late Animation<double> _ring1OpacityAnimation;
  late Animation<double> _ring2ScaleAnimation;
  late Animation<double> _ring2OpacityAnimation;
  late Animation<double> _coreAnimation;
  late Animation<double> _satelliteAnimation;

  @override
  void initState() {
    super.initState();
//    final cubic = Cubic(0.19, 1.0, 0.22, 1.0);

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1900));

    _ring1ScaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 0.01),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 2.0), weight: 100),
    ]).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.45, 1.0, curve: Curves.linear)));
    _ring1OpacityAnimation = Tween(begin: 0.8, end: 0.0).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.45, 1.0, curve: Curves.linear)));
    _ring2ScaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 0.01),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 2.1), weight: 100),
    ]).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.55, 1.0, curve: Curves.linear)));
    _ring2OpacityAnimation = Tween(begin: 0.70, end: 0.0).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.55, 0.65, curve: Curves.linear)));
    _coreAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.3), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 45),
    ]).animate(_animationController);
    _satelliteAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi), weight: 1),
      TweenSequenceItem(tween: Tween(begin: pi, end: 2 * pi), weight: 1),
    ]).animate(_animationController);

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
      builder: (_, constraint) {
        final satelliteRatio = 0.25;
        final distanceRatio = 1.5;
        final coreSize =
            constraint.maxWidth / (1 + satelliteRatio + distanceRatio);
        final satelliteSize = constraint.maxWidth * satelliteRatio / 2;
        final center =
            Offset(constraint.maxWidth / 2, constraint.maxHeight / 2);
        final deltaX = center.dx - satelliteSize / 2;
        final deltaY = center.dy - satelliteSize / 2;

        return Stack(
          children: <Widget>[
            Positioned.fromRect(
              rect: Rect.fromCircle(center: center, radius: coreSize / 2),
              child: ScaleTransition(
                scale: _coreAnimation,
                child: IndicatorShapeWidget(shape: Shape.circle),
              ),
            ),
            Positioned.fromRect(
              rect: Rect.fromCircle(center: center, radius: coreSize / 2),
              child: FadeTransition(
                opacity: _ring1OpacityAnimation,
                child: ScaleTransition(
                  scale: _ring1ScaleAnimation,
                  child: IndicatorShapeWidget(shape: Shape.circle),
                ),
              ),
            ),
            Positioned.fromRect(
              rect: Rect.fromCircle(center: center, radius: coreSize / 2),
              child: FadeTransition(
                opacity: _ring2OpacityAnimation,
                child: ScaleTransition(
                  scale: _ring2ScaleAnimation,
                  child: IndicatorShapeWidget(shape: Shape.circle),
                ),
              ),
            ),
            Positioned.fromRect(
              rect: Rect.fromLTWH(center.dx - satelliteSize / 2,
                  center.dy - satelliteSize / 2, satelliteSize, satelliteSize),
              child: AnimatedBuilder(
                animation: _satelliteAnimation,
                child: IndicatorShapeWidget(shape: Shape.circle),
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(sin(_satelliteAnimation.value) * deltaX,
                        -cos(_satelliteAnimation.value) * deltaY),
                    child: child,
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }
}
