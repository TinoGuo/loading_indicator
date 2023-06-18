import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// Pacman.
class Pacman extends StatefulWidget {
  const Pacman({Key? key}) : super(key: key);

  @override
  State<Pacman> createState() => _PacmanState();
}

class _PacmanState extends State<Pacman>
    with TickerProviderStateMixin, IndicatorController {
  static const _manDurationInMills = 500;
  static const _ballDurationInMills = 1000;
  static const _delayInMills = [0, 500];
  static const _ballNum = 2;

  late AnimationController _pacmanAnimationController;
  final List<AnimationController> _ballAnimationControllers = [];

  late Animation<double> _rotateAnimation;
  final List<Animation<double>> _translateXAnimations = [];
  final List<Animation<double>> _opacityAnimations = [];

  @override
  List<AnimationController> get animationControllers =>
      [_pacmanAnimationController, ..._ballAnimationControllers];

  @override
  void initState() {
    super.initState();
    initPacmanAnimation();
    initBallAnimation();
  }

  void initPacmanAnimation() {
    _pacmanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _manDurationInMills),
    );
    _rotateAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: pi / 4, end: 0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: pi / 4), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _pacmanAnimationController,
      curve: const Cubic(0.25, 0.1, 0.25, 1.0),
    ));

    _pacmanAnimationController.repeat();
  }

  void initBallAnimation() {
    for (int i = 0; i < _ballNum; i++) {
      _ballAnimationControllers.add(AnimationController(
        value: _delayInMills[i] / _ballDurationInMills,
        vsync: this,
        duration: const Duration(milliseconds: _ballDurationInMills),
      ));

      _translateXAnimations.add(Tween(begin: 0.0, end: -1.0).animate(
          CurvedAnimation(
              parent: _ballAnimationControllers[i], curve: Curves.linear)));
      _opacityAnimations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 70),
        TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.7), weight: 30),
      ]).animate(CurvedAnimation(
          parent: _ballAnimationControllers[i], curve: Curves.linear)));

      _ballAnimationControllers[i].repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraint) {
      final pacmanSize = constraint.maxWidth / 2;

      final pacman = Positioned.fromRect(
        rect: Rect.fromLTWH(
          constraint.maxWidth / 8,
          constraint.maxHeight / 4,
          pacmanSize,
          pacmanSize,
        ),
        child: AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (_, child) {
            return IndicatorShapeWidget(
              shape: const Arc(),
              data: _rotateAnimation.value,
              index: 0,
            );
          },
        ),
      );

      final circleSize = constraint.maxWidth / 8;
      final widgets = List<Widget>.filled(_ballNum + 1, Container());
      for (int i = 0; i < _ballNum; i++) {
        widgets[i] = Positioned.fromRect(
          rect: Rect.fromLTWH(
              constraint.maxWidth - circleSize,
              constraint.maxHeight / 2 - circleSize / 2,
              circleSize,
              circleSize),
          child: FadeTransition(
            opacity: _opacityAnimations[i],
            child: AnimatedBuilder(
              animation: _translateXAnimations[i],
              child: const IndicatorShapeWidget(shape: Circle()),
              builder: (_, child) {
                return Transform.translate(
                  offset: Offset(
                      _translateXAnimations[i].value * constraint.maxWidth / 2,
                      0.0),
                  child: IndicatorShapeWidget(
                    shape: const Circle(),
                    index: i + 1,
                  ),
                );
              },
            ),
          ),
        );
      }
      widgets[_ballNum] = pacman;

      return Stack(
        children: widgets,
      );
    });
  }
}
