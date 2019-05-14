import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

class BallTrianglePath extends StatefulWidget {
  @override
  _BallTrianglePathState createState() => _BallTrianglePathState();
}

class _BallTrianglePathState extends State<BallTrianglePath>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Offset> _topCenterAnimation;
  Animation<Offset> _leftBottomAnimation;
  Animation<Offset> _rightBottomAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(() => setState(() {}));

    _topCenterAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: Offset(0, 0), end: Offset(0.5, 1)), weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Offset(0.5, 1), end: Offset(-0.5, 1)), weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Offset(-0.5, 1), end: Offset(0, 0)), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _leftBottomAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: Offset(0, 0), end: Offset(0.5, -1)), weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Offset(0.5, -1), end: Offset(1, 0)), weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Offset(1, 0), end: Offset(0, 0)), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _rightBottomAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: Offset(0, 0), end: Offset(-1, 0)), weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Offset(-1, 0), end: Offset(-0.5, -1)), weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Offset(-0.5, -1), end: Offset(0, 0)), weight: 1),
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

        List<Widget> widgets = List(3);
        widgets[0] = Positioned.fromRect(
          rect: Rect.fromLTWH(constraint.maxWidth / 2 - circleSize / 2, 0,
              circleSize, circleSize),
          child: Transform(
            transform: Matrix4.identity()
              ..translate(
                _topCenterAnimation.value.dx *
                    (constraint.maxWidth - circleSize),
                _topCenterAnimation.value.dy *
                    (constraint.maxHeight - circleSize),
              ),
            child: IndicatorShapeWidget(shape: Shape.ring),
          ),
        );
        widgets[1] = Positioned.fromRect(
          rect: Rect.fromLTWH(
              0, constraint.maxHeight - circleSize, circleSize, circleSize),
          child: Transform(
            transform: Matrix4.identity()
              ..translate(
                _leftBottomAnimation.value.dx *
                    (constraint.maxWidth - circleSize),
                _leftBottomAnimation.value.dy *
                    (constraint.maxHeight - circleSize),
              ),
            child: IndicatorShapeWidget(shape: Shape.ring),
          ),
        );
        widgets[2] = Positioned.fromRect(
          rect: Rect.fromLTWH(constraint.maxWidth - circleSize,
              constraint.maxHeight - circleSize, circleSize, circleSize),
          child: Transform(
            transform: Matrix4.identity()
              ..translate(
                _rightBottomAnimation.value.dx *
                    (constraint.maxWidth - circleSize),
                _rightBottomAnimation.value.dy *
                    (constraint.maxHeight - circleSize),
              ),
            child: IndicatorShapeWidget(shape: Shape.ring),
          ),
        );

        return Stack(children: widgets);
      },
    );
  }
}
