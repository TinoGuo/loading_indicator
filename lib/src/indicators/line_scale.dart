import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';
import 'package:loading_indicator/src/transition/ScaleYTransition.dart';

/// LineScale.
class LineScale extends StatefulWidget {
  @override
  _LineScaleState createState() => _LineScaleState();
}

class _LineScaleState extends State<LineScale> with TickerProviderStateMixin {
  static const _BEGIN_TIMES = [100, 200, 300, 400, 500];

  List<AnimationController> _animationControllers = [];
  List<Animation<double>> _animations = [];
  List<CancelableOperation<int>> _delayFeatures = [];

  @override
  void initState() {
    super.initState();
    final cubic = Cubic(0.2, 0.68, 0.18, 0.08);

    for (int i = 0; i < 5; i++) {
      _animationControllers.add(AnimationController(
          vsync: this, duration: const Duration(seconds: 1)));

      _animations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 1),
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
    List<Widget> widgets = _animations
        .map((Animation<double> anim) => Expanded(
              child: ScaleYTransition(
                alignment: Alignment.center,
                scaleY: anim,
                child: IndicatorShapeWidget(shape: Shape.line),
              ),
            ))
        .toList();

    for (int i = 0; i < widgets.length - 1; i++) {
      if (i % 2 == 0) {
        widgets.insert(++i, Expanded(child: Container()));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }
}
