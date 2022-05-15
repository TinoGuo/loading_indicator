import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallSpinFadeLoader.
class BallSpinFadeLoader extends StatefulWidget {
  const BallSpinFadeLoader({Key? key}) : super(key: key);

  @override
  State<BallSpinFadeLoader> createState() => _BallSpinFadeLoaderState();
}

const int _kBallSize = 8;

class _BallSpinFadeLoaderState extends State<BallSpinFadeLoader>
    with TickerProviderStateMixin, IndicatorController {
  static const _durationInMills = 1000;
  static const _delayInMills = [0, 120, 240, 360, 480, 600, 720, 840];

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _scaleAnimations = [];
  final List<Animation<double>> _opacityAnimations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _kBallSize; i++) {
      _animationControllers.add(AnimationController(
        value: _delayInMills[i] / _durationInMills,
        vsync: this,
        duration: const Duration(milliseconds: _durationInMills),
      ));
      _opacityAnimations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear)));
      _scaleAnimations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear)));

      _animationControllers[i].repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraint) {
      final circleSize = constraint.maxWidth / 3;

      final widgets = List<Widget>.filled(8, Container());
      final center = Offset(constraint.maxWidth / 2, constraint.maxHeight / 2);
      for (int i = 0; i < widgets.length; i++) {
        final angle = pi * i / 4;
        widgets[i] = Positioned.fromRect(
          rect: Rect.fromLTWH(
            /// the radius is circleSize / 4, the startX and startY need to subtract that value.
            center.dx + circleSize * (sin(angle)) - circleSize / 4,
            center.dy + circleSize * (cos(angle)) - circleSize / 4,
            circleSize / 2,
            circleSize / 2,
          ),
          child: FadeTransition(
            opacity: _opacityAnimations[i],
            child: ScaleTransition(
              scale: _scaleAnimations[i],
              child: IndicatorShapeWidget(
                shape: Shape.circle,
                index: i,
              ),
            ),
          ),
        );
      }

      return Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: widgets,
      );
    });
  }
}
