import 'package:flutter/material.dart';
import 'package:loading_indicator/src/control/loading_indicator_controller.dart';
import 'package:loading_indicator/src/decorate/decorate.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// CircleStrokeSpin.
class CircleStrokeSpin extends StatefulWidget {
  const CircleStrokeSpin({Key? key}) : super(key: key);

  @override
  State<CircleStrokeSpin> createState() => _CircleStrokeSpinState();
}

class _CircleStrokeSpinState extends State<CircleStrokeSpin>
    with SingleTickerProviderStateMixin, IndicatorController {
  late final AnimationController _animationController;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    final strokeWidth = DecorateContext.of(context)!.decorateData.strokeWidth;
    return Padding(
      padding: EdgeInsets.all(strokeWidth / 2),
      child: RotationTransition(
        turns: _animationController,
        child: const IndicatorShapeWidget(shape: Shape.ringThirdFour),
      ),
    );
  }
}
