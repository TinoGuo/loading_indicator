import 'package:flutter/material.dart';
import 'package:loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallScaleRippleMultiple.
class BallScaleRippleMultiple extends StatefulWidget {
  const BallScaleRippleMultiple({Key? key}) : super(key: key);

  @override
  State<BallScaleRippleMultiple> createState() =>
      _BallScaleRippleMultipleState();
}

class _BallScaleRippleMultipleState extends State<BallScaleRippleMultiple>
    with TickerProviderStateMixin, IndicatorController {
  static const _durationInMills = 1250;
  static const _delayInMills = [0, 200, 400];

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _opacityAnimations = [];
  final List<Animation<double>> _scaleAnimations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    const cubic = Cubic(0.21, 0.53, 0.56, 0.8);
    for (int i = 0; i < 3; i++) {
      _animationControllers.add(AnimationController(
        value: _delayInMills[i] / _durationInMills,
        vsync: this,
        duration: const Duration(milliseconds: _durationInMills),
      ));
      _opacityAnimations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 70),
        TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.0), weight: 30),
      ]).animate(
          CurvedAnimation(parent: _animationControllers[i], curve: cubic)));
      _scaleAnimations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 70),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
      ]).animate(
          CurvedAnimation(parent: _animationControllers[i], curve: cubic)));
      _animationControllers[i].repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = List.filled(3, Container());
    for (int i = 0; i < widgets.length; i++) {
      widgets[i] = ScaleTransition(
        scale: _scaleAnimations[i],
        child: FadeTransition(
          opacity: _opacityAnimations[i],
          child: IndicatorShapeWidget(
            shape: Shape.ring,
            index: i,
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: widgets,
    );
  }
}
