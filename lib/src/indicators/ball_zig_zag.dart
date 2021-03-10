import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallZigZag.
class BallZigZag extends StatefulWidget {
  @override
  _BallZigZagState createState() => _BallZigZagState();
}

class _BallZigZagState extends State<BallZigZag>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _animation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: Offset(0, 0), end: Offset(-1, -1)), weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Offset(-1, -1), end: Offset(1, -1)), weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Offset(1, -1), end: Offset(0, 0)), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));

    _animationController.repeat();
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
      final deltaX = constraint.maxWidth / 2 - circleSize / 2;
      final deltaY = constraint.maxHeight / 2 - circleSize / 2;

      return AnimatedBuilder(
        animation: _animationController,
        child: IndicatorShapeWidget(shape: Shape.circle),
        builder: (_, child) {
          return Stack(
            children: <Widget>[
              Positioned.fromRect(
                rect: Rect.fromLTWH(deltaX, deltaY, circleSize, circleSize),
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(deltaX * _animation.value.dx,
                        deltaY * _animation.value.dy),
                  child: child,
                ),
              ),
              Positioned.fromRect(
                rect: Rect.fromLTWH(deltaX, deltaY, circleSize, circleSize),
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(deltaX * -_animation.value.dx,
                        deltaY * -_animation.value.dy),
                  child: child,
                ),
              )
            ],
          );
        },
      );
    });
  }
}
