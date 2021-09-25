import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// LineScalePulseOut.
class LineScalePulseOut extends StatefulWidget {
  const LineScalePulseOut({Key? key}) : super(key: key);

  @override
  _LineScalePulseOutState createState() => _LineScalePulseOutState();
}

class _LineScalePulseOutState extends State<LineScalePulseOut>
    with TickerProviderStateMixin {
  static const _beginTimes = [400, 200, 0, 200, 400];

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _animations = [];
  final List<CancelableOperation<int>> _delayFeatures = [];

  @override
  void initState() {
    super.initState();
    const cubic = Cubic(0.85, 0.25, 0.37, 0.85);
    for (int i = 0; i < 5; i++) {
      _animationControllers.add(AnimationController(
          vsync: this, duration: const Duration(seconds: 1)));
      _animations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 1),
      ]).animate(
          CurvedAnimation(parent: _animationControllers[i], curve: cubic)));

      _delayFeatures.add(CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: _beginTimes[i])).then((t) {
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
    final widgets = List<Widget>.filled(9, Container());
    for (int i = 0; i < widgets.length; i++) {
      if (i.isEven) {
        widgets[i] = Expanded(
          child: AnimatedBuilder(
            animation: _animations[i ~/ 2],
            builder: (BuildContext context, Widget? child) {
              return FractionallySizedBox(
                heightFactor: _animations[i ~/ 2].value,
                child: IndicatorShapeWidget(
                  shape: Shape.line,
                  index: i ~/ 2,
                ),
              );
            },
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
