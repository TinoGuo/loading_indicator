import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallGridBeat.
class BallGridBeat extends StatefulWidget {
  const BallGridBeat({Key? key}) : super(key: key);

  @override
  _BallGridBeatState createState() => _BallGridBeatState();
}

class _BallGridBeatState extends State<BallGridBeat>
    with TickerProviderStateMixin {
  static const _ballNum = 9;

//  static const _DURATIONS = [
//    720,
//    1020,
//    1280,
//    1420,
//    1450,
//    1180,
//    870,
//    1450,
//    1060,
//  ];
//  static const _BEGIN_TIMES = [-60, 250, 170, 480, 310, 30, 460, 780, 450];
  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _animations = [];
  final List<CancelableOperation> _delayFeatures = [];

  @override
  void initState() {
    super.initState();
    final random = Random();
    for (int i = 0; i < _ballNum; i++) {
      final duration = random.nextInt(1000) + 600;
      final delay = random.nextInt(1000) - 200;
      _animationControllers.add(AnimationController(
          vsync: this, duration: Duration(milliseconds: duration)));
      _animations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear)));
      _delayFeatures.add(CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: delay)).then((t) {
        _animationControllers[i].repeat();
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
        scale: _animations[i],
        child: FadeTransition(
          opacity: _animations[i],
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
