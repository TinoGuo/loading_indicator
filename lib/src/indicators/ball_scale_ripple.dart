import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallScaleRipple.
class BallScaleRipple extends StatefulWidget {
  @override
  _BallScaleRippleState createState() => _BallScaleRippleState();
}

class _BallScaleRippleState extends State<BallScaleRipple>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    final cubic = Cubic(0.21, 0.53, 0.56, 0.8);
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _opacityAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.1, end: 1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
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
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: IndicatorShapeWidget(shape: Shape.ring),
      ),
    );
  }
}
