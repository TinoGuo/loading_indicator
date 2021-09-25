import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// SquareSpin.
class SquareSpin extends StatefulWidget {
  const SquareSpin({Key? key}) : super(key: key);

  @override
  _SquareSpinState createState() => _SquareSpinState();
}

class _SquareSpinState extends State<SquareSpin>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _xAnimation;
  late Animation<double> _yAnimation;
  late Animation<double> _xAnimation2;
  late Animation<double> _yAnimation2;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));
    const cubic = Cubic(.09, .57, .49, .9);
    _xAnimation = Tween<double>(begin: 0, end: pi).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.25, curve: cubic)));
    _yAnimation = Tween<double>(begin: 0, end: pi).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.25, 0.5, curve: cubic)));
    _xAnimation2 = Tween<double>(begin: pi, end: 0).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.75, curve: cubic)));
    _yAnimation2 = Tween<double>(begin: pi, end: 2 * pi).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.75, 1, curve: cubic)));

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
      child: const IndicatorShapeWidget(shape: Shape.rectangle),
      builder: (_, child) {
        late double x, y;
        if (_animationController.value < 0.5) {
          x = _xAnimation.value;
          y = _yAnimation.value;
        } else if (_animationController.value < 1) {
          x = _xAnimation2.value;
          y = _yAnimation2.value;
        }
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()

            /// Whooops, must add this line to 3D effect.
            ..setEntry(3, 2, 0.006)
            ..rotateX(x)
            ..rotateY(y),
          child: child,
        );
      },
    );
  }
}
