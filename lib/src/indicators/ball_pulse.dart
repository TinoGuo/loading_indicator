import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallPulse.
class BallPulse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BallPulseState();
  }
}

class _BallPulseState extends State<BallPulse> with TickerProviderStateMixin {
  static const _beginTimes = [
    120,
    240,
    360,
  ];

  List<AnimationController> _animationController = [];
  List<Animation<double>> _scaleAnimations = [];
  List<Animation<double>> _opacityAnimations = [];
  List<CancelableOperation<int>> _delayFeature = [];

  @override
  void initState() {
    super.initState();
    final cubic = Cubic(0.2, 0.68, 0.18, 0.08);
    for (int i = 0; i < 3; i++) {
      _animationController.add(AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 750),
      ));
      _scaleAnimations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.1), weight: 45),
        TweenSequenceItem(tween: Tween(begin: 0.1, end: 1.0), weight: 35),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20),
      ]).animate(
          CurvedAnimation(parent: _animationController[i], curve: cubic)));
      _opacityAnimations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 45),
        TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.0), weight: 35),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20),
      ]).animate(
          CurvedAnimation(parent: _animationController[i], curve: cubic)));

      /// Better solution is welcome!!! Very stupid work solution.
      _delayFeature.add(CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: _beginTimes[i])).then((_) {
        _animationController[i].repeat();
        return 0;
      })));
    }
  }

  @override
  void dispose() {
    _delayFeature.forEach((f) => f.cancel());
    _animationController.forEach((f) => f.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widgets = List<Widget>.filled(3, Container());
    for (int i = 0; i < 3; i++) {
      widgets[i] = FadeTransition(
        opacity: _opacityAnimations[i],
        child: ScaleTransition(
          child: IndicatorShapeWidget(shape: Shape.circle),
          scale: _scaleAnimations[i],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: widgets[0]),
        SizedBox(width: 2),
        Expanded(child: widgets[1]),
        SizedBox(width: 2),
        Expanded(child: widgets[2]),
      ],
    );
  }
}
