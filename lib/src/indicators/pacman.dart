import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// Pacman.
class Pacman extends StatefulWidget {
  @override
  _PacmanState createState() => _PacmanState();
}

class _PacmanState extends State<Pacman> with TickerProviderStateMixin {
  static const _BEGIN_TIMES = [0, 500];
  static const _BALL_NUM = 2;

  late AnimationController _pacmanAnimationController;
  List<AnimationController> _ballAnimationControllers = [];

  late Animation<double> _rotateAnimation;
  List<Animation<double>> _translateXAnimations = [];
  List<Animation<double>> _opacityAnimations = [];

  List<CancelableOperation<int>> _delayFeatures = [];

  @override
  void initState() {
    super.initState();
    initPacmanAnimation();
    initBallAnimation();
  }

  void initPacmanAnimation() {
    _pacmanAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _rotateAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: pi / 4, end: 0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi / 4), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _pacmanAnimationController,
      curve: Cubic(0.25, 0.1, 0.25, 1.0),
    ));

    _pacmanAnimationController.repeat();
  }

  void initBallAnimation() {
    for (int i = 0; i < _BALL_NUM; i++) {
      _ballAnimationControllers.add(AnimationController(
          vsync: this, duration: Duration(milliseconds: 1000)));

      _translateXAnimations.add(Tween(begin: 0.0, end: -1.0).animate(
          CurvedAnimation(
              parent: _ballAnimationControllers[i], curve: Curves.linear)));
      _opacityAnimations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 70),
        TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.7), weight: 30),
      ]).animate(CurvedAnimation(
          parent: _ballAnimationControllers[i], curve: Curves.linear)));

      _delayFeatures.add(CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: _BEGIN_TIMES[i])).then((t) {
        _ballAnimationControllers[i].repeat();
        return 0;
      })));
    }
  }

  @override
  void dispose() {
    _delayFeatures.forEach((f) => f.cancel());
    _pacmanAnimationController.dispose();
    _ballAnimationControllers.forEach((f) => f.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraint) {
      final pacmanSize = constraint.maxWidth / 2;

      final pacman = Positioned.fromRect(
        child: AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (_, child) {
            return IndicatorShapeWidget(
              shape: Shape.arc,
              data: _rotateAnimation.value,
            );
          },
        ),
        rect: Rect.fromLTWH(
          constraint.maxWidth / 8,
          constraint.maxHeight / 4,
          pacmanSize,
          pacmanSize,
        ),
      );

      final circleSize = constraint.maxWidth / 8;
      final widgets = List<Widget>.filled(_BALL_NUM + 1, Container());
      for (int i = 0; i < _BALL_NUM; i++) {
        widgets[i] = Positioned.fromRect(
          child: FadeTransition(
            opacity: _opacityAnimations[i],
            child: AnimatedBuilder(
              animation: _translateXAnimations[i],
              child: IndicatorShapeWidget(shape: Shape.circle),
              builder: (_, child) {
                return Transform.translate(
                  offset: Offset(
                      _translateXAnimations[i].value * constraint.maxWidth / 2,
                      0.0),
                  child: child,
                );
              },
            ),
          ),
          rect: Rect.fromLTWH(
              constraint.maxWidth - circleSize,
              constraint.maxHeight / 2 - circleSize / 2,
              circleSize,
              circleSize),
        );
      }
      widgets[_BALL_NUM] = pacman;

      return Stack(
        children: widgets,
      );
    });
  }
}
