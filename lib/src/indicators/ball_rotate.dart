import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallRotate.
class BallRotate extends StatefulWidget {
  const BallRotate({Key? key}) : super(key: key);

  @override
  _BallRotateState createState() => _BallRotateState();
}

class _BallRotateState extends State<BallRotate>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    /// If set b to -0.13, value is negative, [TweenSequence]'s transform will throw error.
    const cubic = Cubic(0.7, 0.87, 0.22, 0.86);
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));
    _rotateAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animationController, curve: cubic));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotateAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: _buildSingleCircle(0.8, 0)),
            const Expanded(child: SizedBox()),
            Expanded(child: _buildSingleCircle(1.0, 1)),
            const Expanded(child: SizedBox()),
            Expanded(child: _buildSingleCircle(0.8, 2)),
          ],
        ),
      ),
    );
  }

  _buildSingleCircle(
    double opacity,
    int index,
  ) {
    return Opacity(
      opacity: opacity,
      child: IndicatorShapeWidget(
        shape: Shape.circle,
        index: index,
      ),
    );
  }
}
