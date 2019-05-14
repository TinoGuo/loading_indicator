import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';
import 'package:loading_indicator/src/transition/ScaleYTransition.dart';

class LineScalePulseOutRapid extends StatefulWidget {
  @override
  _LineScalePulseOutRapidState createState() => _LineScalePulseOutRapidState();
}

class _LineScalePulseOutRapidState extends State<LineScalePulseOutRapid>
    with TickerProviderStateMixin {
  static const _BEGIN_TIMES = [500, 250, 0, 250, 500];

  List<AnimationController> _animationControllers = List(5);
  List<Animation<double>> _animations = List(5);
  List<CancelableOperation<int>> _delayFeatures = List(5);

  @override
  void initState() {
    super.initState();
    final cubic = Cubic(0.11, 0.49, 0.38, 0.78);
    for (int i = 0; i < 5; i++) {
      _animationControllers[i] = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 900));
      _animations[i] = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 80),
        TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 10),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 10),
      ]).animate(
          CurvedAnimation(parent: _animationControllers[i], curve: cubic));

      _delayFeatures[i] = CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: _BEGIN_TIMES[i])).then((t) {
        _animationControllers[i].repeat();
      }));
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
    final widgets = List<Widget>(9);
    for (int i = 0; i < widgets.length; i++) {
      if (i.isEven) {
        widgets[i] = Expanded(
          child: ScaleYTransition(
            scaleY: _animations[i ~/ 2],
            child: IndicatorShapeWidget(shape: Shape.line),
          ),
        );
      } else {
        widgets[i] = Expanded(child: Container());
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }
}
