import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallScaleRippleMultiple.
class BallScaleRippleMultiple extends StatefulWidget {
  @override
  _BallScaleRippleMultipleState createState() =>
      _BallScaleRippleMultipleState();
}

class _BallScaleRippleMultipleState extends State<BallScaleRippleMultiple>
    with TickerProviderStateMixin {
  static const _BEGIN_TIMES = [0, 200, 400];

  List<AnimationController> _animationControllers = [];
  List<Animation<double>> _opacityAnimations = [];
  List<Animation<double>> _scaleAnimations = [];
  List<CancelableOperation<int>> _delayFeatures = [];

  @override
  void initState() {
    super.initState();
    final cubic = Cubic(0.21, 0.53, 0.56, 0.8);
    for (int i = 0; i < 3; i++) {
      _animationControllers.add(AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1250)));
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
      _delayFeatures.add(CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: _BEGIN_TIMES[i])).then((t) {
        _animationControllers[i].repeat();
        return 0;
      })));
    }
  }

  @override
  void dispose() {
    _delayFeatures.forEach((f) => f.cancel());
    _animationControllers.forEach((f) => f.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = List.filled(3, Container());
    for (int i = 0; i < widgets.length; i++) {
      widgets[i] = ScaleTransition(
        scale: _scaleAnimations[i],
        child: FadeTransition(
          opacity: _opacityAnimations[i],
          child: IndicatorShapeWidget(shape: Shape.ring),
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
