import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';
import 'package:loading_indicator/src/transition/ScaleYTransition.dart';

/// LineScalePulseOut.
class LineScalePulseOut extends StatefulWidget {
  @override
  _LineScalePulseOutState createState() => _LineScalePulseOutState();
}

class _LineScalePulseOutState extends State<LineScalePulseOut>
    with TickerProviderStateMixin {
  static const _BEGIN_TIMES = [400, 200, 0, 200, 400];

  List<AnimationController> _animationControllers = List(5);
  List<Animation<double>> _animations = List(5);
  List<CancelableOperation<int>> _delayFeatures = List(5);

  @override
  void initState() {
    super.initState();
    final cubic = Cubic(0.85, 0.25, 0.37, 0.85);
    for (int i = 0; i < 5; i++) {
      _animationControllers[i] = AnimationController(
          vsync: this, duration: const Duration(seconds: 1));
      _animations[i] = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 1),
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
    _animationControllers.forEach((f) => f?.dispose());
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
