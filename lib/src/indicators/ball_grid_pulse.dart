import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

class BallGridPulse extends StatefulWidget {
  const BallGridPulse();

  @override
  _BallGridPulseState createState() => _BallGridPulseState();
}

class _BallGridPulseState extends State<BallGridPulse>
    with TickerProviderStateMixin {
  static const _BALL_NUM = 9;

  List<AnimationController> _animationControllers = List(_BALL_NUM);
  List<Animation<double>> _scaleAnimations = List(_BALL_NUM);
  List<Animation<double>> _opacityAnimations = List(_BALL_NUM);
  List<CancelableOperation<int>> _delayFeatures = List(_BALL_NUM);

  @override
  void initState() {
    super.initState();
    final random = Random();
    for (int i = 0; i < _BALL_NUM; i++) {
      final duration = random.nextInt(1000) + 600;
      final delay = random.nextInt(1000) - 200;
      _animationControllers[i] = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: duration),
      );
      _scaleAnimations[i] = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
        parent: _animationControllers[i],
        curve: Curves.linear,
      ));
      _opacityAnimations[i] = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear));
      _animationControllers[i].repeat(reverse: true);

      _delayFeatures[i] = CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: delay)).then((t) {
        _animationControllers[i].repeat();
      }));
    }
  }

  @override
  void dispose() {
    _delayFeatures.forEach((f) => f?.cancel());
    _animationControllers.forEach((f) => f?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widgets = List<Widget>(_BALL_NUM);
    for (int i = 0; i < _BALL_NUM; i++) {
      widgets[i] = ScaleTransition(
        alignment: Alignment.center,
        scale: _scaleAnimations[i],
        child: FadeTransition(
          opacity: _opacityAnimations[i],
          child: IndicatorShapeWidget(Shape.circle),
        ),
      );
    }

    return GridView.count(
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      crossAxisCount: 3,
      children: widgets,
    );
  }
}
