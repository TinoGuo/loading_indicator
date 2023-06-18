import 'package:flutter/material.dart';
import 'package:loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

import '../decorate/decorate.dart';

/// LineScalePulseOutRapid.
class LineScalePulseOutRapid extends StatefulWidget {
  const LineScalePulseOutRapid({Key? key}) : super(key: key);

  @override
  State<LineScalePulseOutRapid> createState() => _LineScalePulseOutRapidState();
}

class _LineScalePulseOutRapidState extends State<LineScalePulseOutRapid>
    with TickerProviderStateMixin, IndicatorController {
  static const _durationInMills = 900;
  static const _delayInMills = [500, 250, 0, 250, 500];

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _animations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    const cubic = Cubic(0.11, 0.49, 0.38, 0.78);
    for (int i = 0; i < 5; i++) {
      _animationControllers.add(AnimationController(
        value: _delayInMills[i] / _durationInMills,
        vsync: this,
        duration: const Duration(milliseconds: _durationInMills),
      ));
      _animations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 80),
        TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 10),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 10),
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
