import 'package:flutter/material.dart';
import 'package:loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallGridPulse.
class BallGridPulse extends StatefulWidget {
  const BallGridPulse({Key? key}) : super(key: key);

  @override
  State<BallGridPulse> createState() => _BallGridPulseState();
}

class _BallGridPulseState extends State<BallGridPulse>
    with TickerProviderStateMixin, IndicatorController {
  static const _ballNum = 9;

  static const _durationInMills = [
    720,
    1020,
    1280,
    1420,
    1450,
    1180,
    870,
    1450,
    1060,
  ];

  static const _delayInMills = [
    660,
    250,
    1110,
    480,
    310,
    30,
    460,
    480,
    450,
  ];

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _scaleAnimations = [];
  final List<Animation<double>> _opacityAnimations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _ballNum; i++) {
      final duration = _durationInMills[i];
      final delay = _delayInMills[i];
      _animationControllers.add(AnimationController(
        value: delay / duration,
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
      _animationControllers[i].repeat();
    }
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
