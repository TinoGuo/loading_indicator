import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// TriangleSkewSpin.
class TriangleSkewSpin extends StatefulWidget {
  const TriangleSkewSpin({Key? key}) : super(key: key);

  @override
  _TriangleSkewSpinState createState() => _TriangleSkewSpinState();
}

class _TriangleSkewSpinState extends State<TriangleSkewSpin>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    const cubic = Cubic(0.09, 0.57, 0.49, 0.9);
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _animation = TweenSequence([
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(0.0, 0.0), end: const Offset(0.0, pi)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0.0, pi), end: const Offset(pi, pi)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(pi, pi), end: const Offset(pi, 0.0)),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(pi, 0.0), end: const Offset(0.0, 0.0)),
          weight: 1),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        child: const IndicatorShapeWidget(shape: Shape.triangle),
        builder: (_, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()

              /// Whooops, must add this line to 3D effect.
              ..setEntry(3, 2, 0.006)
              ..rotateX(_animation.value.dx)
              ..rotateY(_animation.value.dy),
            child: child,
          );
        });
  }
}
