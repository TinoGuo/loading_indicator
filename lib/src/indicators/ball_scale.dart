import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

class BallScale extends StatefulWidget {
  @override
  _BallScaleState createState() => _BallScaleState();
}

class _BallScaleState extends State<BallScale>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween(begin: 0.0, end: 1.0).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (ctx, child) => Container(
            child: Opacity(
              opacity: 1 - _animation.value,
              child: Transform.scale(
                scale: _animation.value,
                child: IndicatorShapeWidget(Shape.circle),
              ),
            ),
          ),
    );
  }
}
