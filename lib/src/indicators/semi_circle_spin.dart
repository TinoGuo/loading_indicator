import 'package:flutter/material.dart';
import 'package:loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// SemiCircleSpin.
class SemiCircleSpin extends StatefulWidget {
  const SemiCircleSpin({Key? key}) : super(key: key);

  @override
  State<SemiCircleSpin> createState() => _SemiCircleSpinState();
}

class _SemiCircleSpinState extends State<SemiCircleSpin>
    with SingleTickerProviderStateMixin, IndicatorController {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _animation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: const IndicatorShapeWidget(shape: SemiCircle()),
    );
  }
}
