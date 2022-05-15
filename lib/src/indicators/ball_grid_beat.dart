import 'package:flutter/material.dart';
import 'package:loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallGridBeat.
class BallGridBeat extends StatefulWidget {
  const BallGridBeat({Key? key}) : super(key: key);

  @override
  State<BallGridBeat> createState() => _BallGridBeatState();
}

class _BallGridBeatState extends State<BallGridBeat>
    with TickerProviderStateMixin, IndicatorController {
  static const _ballNum = 9;

  static const _durationInMills = [
    960,
    930,
    1190,
    1130,
    1340,
    940,
    1200,
    820,
    1190,
  ];

  static const List<int> _delayInMills = [
    360,
    400,
    680,
    410,
    710,
    790,
    1080,
    100,
    320,
  ];

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _animations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _ballNum; i++) {
      _animationControllers.add(AnimationController(
        value: _delayInMills[i] / _durationInMills[i],
        vsync: this,
        duration: Duration(milliseconds: _durationInMills[i]),
      ));
      _animations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear)));
      _animationControllers[i].repeat();
    }
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
