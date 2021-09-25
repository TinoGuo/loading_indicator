import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallTrianglePath.
class BallTrianglePath extends StatefulWidget {
  const BallTrianglePath({Key? key}) : super(key: key);

  @override
  _BallTrianglePathState createState() => _BallTrianglePathState();
}

class _BallTrianglePathState extends State<BallTrianglePath>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _topCenterAnimation;
  late Animation<Offset> _leftBottomAnimation;
  late Animation<Offset> _rightBottomAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _topCenterAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, 0), end: const Offset(0.5, 1)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0.5, 1), end: const Offset(-0.5, 1)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-0.5, 1), end: const Offset(0, 0)),
          weight: 1),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _leftBottomAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, 0), end: const Offset(0.5, -1)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0.5, -1), end: const Offset(1, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)),
          weight: 1),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _rightBottomAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, 0), end: const Offset(-1, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-1, 0), end: const Offset(-0.5, -1)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-0.5, -1), end: const Offset(0, 0)),
          weight: 1),
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
      builder: (ctx, constraint) {
        final circleSize = constraint.maxWidth / 5;
        final container = Size(constraint.maxWidth, constraint.maxHeight);

        List<Widget> widgets = List.filled(3, Container());
        widgets[0] = Positioned.fromRect(
          rect: Rect.fromLTWH(constraint.maxWidth / 2 - circleSize / 2, 0,
              circleSize, circleSize),
          child:
              _buildAnimatedRing(container, circleSize, _topCenterAnimation, 0),
        );
        widgets[1] = Positioned.fromRect(
          rect: Rect.fromLTWH(
              0, constraint.maxHeight - circleSize, circleSize, circleSize),
          child: _buildAnimatedRing(
              container, circleSize, _leftBottomAnimation, 1),
        );
        widgets[2] = Positioned.fromRect(
          rect: Rect.fromLTWH(constraint.maxWidth - circleSize,
              constraint.maxHeight - circleSize, circleSize, circleSize),
          child: _buildAnimatedRing(
              container, circleSize, _rightBottomAnimation, 2),
        );

        return Stack(children: widgets);
      },
    );
  }

  _buildAnimatedRing(
    Size size,
    double circleSize,
    Animation<Offset> animation,
    int index,
  ) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, child) {
        return Transform(
          transform: Matrix4.identity()
            ..translate(
              animation.value.dx * (size.width - circleSize),
              animation.value.dy * (size.height - circleSize),
            ),
          child: child,
        );
      },
      child: IndicatorShapeWidget(
        shape: Shape.ring,
        index: index,
      ),
    );
  }
}
