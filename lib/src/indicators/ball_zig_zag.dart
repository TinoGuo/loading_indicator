import 'package:flutter/material.dart';
import 'package:loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallZigZag.
class BallZigZag extends StatefulWidget {
  const BallZigZag({Key? key}) : super(key: key);

  @override
  State<BallZigZag> createState() => _BallZigZagState();
}

class _BallZigZagState extends State<BallZigZag>
    with SingleTickerProviderStateMixin, IndicatorController {
  static const _durationInMills = 700;

  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: _durationInMills));

    _animation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, 0), end: const Offset(-1, -1)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-1, -1), end: const Offset(1, -1)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(1, -1), end: const Offset(0, 0)),
          weight: 1),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));

    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraint) {
      final circleSize = constraint.maxWidth / 5;
      final deltaX = constraint.maxWidth / 2 - circleSize / 2;
      final deltaY = constraint.maxHeight / 2 - circleSize / 2;

      return AnimatedBuilder(
        animation: _animationController,
        builder: (_, child) {
          return Stack(
            children: <Widget>[
              Positioned.fromRect(
                rect: Rect.fromLTWH(deltaX, deltaY, circleSize, circleSize),
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(deltaX * _animation.value.dx,
                        deltaY * _animation.value.dy),
                  child: const IndicatorShapeWidget(
                    shape: Circle(),
                    index: 0,
                  ),
                ),
              ),
              Positioned.fromRect(
                rect: Rect.fromLTWH(deltaX, deltaY, circleSize, circleSize),
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(deltaX * -_animation.value.dx,
                        deltaY * -_animation.value.dy),
                  child: const IndicatorShapeWidget(
                    shape: Circle(),
                    index: 1,
                  ),
                ),
              )
            ],
          );
        },
      );
    });
  }
}
