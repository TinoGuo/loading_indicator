import 'package:flutter/material.dart';
import 'package:loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

import '../decorate/decorate.dart';

/// LineScalePulseOut.
class LineScalePulseOut extends StatefulWidget {
  const LineScalePulseOut({Key? key}) : super(key: key);

  @override
  State<LineScalePulseOut> createState() => _LineScalePulseOutState();
}

class _LineScalePulseOutState extends State<LineScalePulseOut>
    with TickerProviderStateMixin, IndicatorController {
  static const _durationInMills = 1000;
  static const _delayInMills = [400, 200, 0, 200, 400];

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _animations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    const cubic = Cubic(0.85, 0.25, 0.37, 0.85);
    for (int i = 0; i < 5; i++) {
      _animationControllers.add(AnimationController(
          value: _delayInMills[i] / _durationInMills,
          vsync: this,
          duration: const Duration(milliseconds: _durationInMills)));
      _animations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 1),
      ]).animate(
          CurvedAnimation(parent: _animationControllers[i], curve: cubic)));

      _animationControllers[i].repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strokeWidth = DecorateContext.of(context)!.decorateData.strokeWidth;
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
                  shape: Line(strokeWidth: strokeWidth),
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
