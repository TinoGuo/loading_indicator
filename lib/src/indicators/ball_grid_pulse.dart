import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallGridPulse.
class BallGridPulse extends StatefulWidget {
  const BallGridPulse({Key? key}) : super(key: key);

  @override
  _BallGridPulseState createState() => _BallGridPulseState();
}

class _BallGridPulseState extends State<BallGridPulse>
    with TickerProviderStateMixin {
  static const _ballNum = 9;

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _scaleAnimations = [];
  final List<Animation<double>> _opacityAnimations = [];
  final List<CancelableOperation<int>> _delayFeatures = [];

  @override
  void initState() {
    super.initState();
    final random = Random();
    for (int i = 0; i < _ballNum; i++) {
      final duration = random.nextInt(1000) + 600;
      final delay = random.nextInt(1000) - 200;
      _animationControllers.add(AnimationController(
        vsync: this,
        duration: Duration(milliseconds: duration),
      ));
      _scaleAnimations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
        parent: _animationControllers[i],
        curve: Curves.linear,
      )));
      _opacityAnimations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear)));
      _animationControllers[i].repeat(reverse: true);

      _delayFeatures.add(CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: delay)).then((t) {
        _animationControllers[i].repeat();
        return 0;
      })));
    }
  }

  @override
  void dispose() {
    for (var f in _delayFeatures) {
      f.cancel();
    }
    for (var f in _animationControllers) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widgets = List<Widget>.filled(_ballNum, Container());
    for (int i = 0; i < _ballNum; i++) {
      widgets[i] = ScaleTransition(
        alignment: Alignment.center,
        scale: _scaleAnimations[i],
        child: FadeTransition(
          opacity: _opacityAnimations[i],
          child: IndicatorShapeWidget(
            shape: Shape.circle,
            index: i,
          ),
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
