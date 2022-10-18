import 'package:flutter/material.dart';
import 'package:loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallPulseRise.
class BallPulseRise extends StatefulWidget {
  const BallPulseRise({Key? key}) : super(key: key);

  @override
  State<BallPulseRise> createState() => _BallPulseRiseState();
}

class _BallPulseRiseState extends State<BallPulseRise>
    with SingleTickerProviderStateMixin, IndicatorController {
  late AnimationController _animationController;
  late Animation<double> _oddScaleAnimation;
  late Animation<double> _oddTranslateAnimation;

  late Animation<double> _evenScaleAnimation;
  late Animation<double> _evenTranslateAnimation;

  @override
  List<AnimationController> get animationControllers => [_animationController];

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    const cubic = Cubic(0.15, 0.46, 0.9, 0.6);

    _oddScaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.75), weight: 50),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));
    _oddTranslateAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: -1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -1.0, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));

    _evenScaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));
    _evenTranslateAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -1.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _animationController, curve: cubic));

    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraint) {
        const circleSpacing = 2;
        final circleSize = (constraint.maxWidth - 4 * circleSpacing) / 5;
        const x = 0;
        final y = (constraint.maxHeight - circleSize) / 2;
        final widgets = List<Widget>.filled(5, Container());
        final deltaY = constraint.maxHeight / 3;

        for (int i = 0; i < 5; i++) {
          Widget child = _buildSingleCircle(i, deltaY);
          widgets[i] = Positioned.fromRect(
            rect: Rect.fromLTWH(
              x + circleSize * i + circleSpacing * i,
              y,
              circleSize,
              circleSize,
            ),
            child: child,
          );
        }
        return Stack(
          children: widgets,
        );
      },
    );
  }

  Widget _buildSingleCircle(int index, double deltaY) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(index.isEven
                ? _evenScaleAnimation.value
                : _oddScaleAnimation.value)
            ..translate(
                0.0,
                index.isEven
                    ? _evenTranslateAnimation.value * deltaY
                    : _oddTranslateAnimation.value * deltaY)
            ..setEntry(3, 2, 0.006),
          child: child,
        );
      },
      child: IndicatorShapeWidget(
        shape: Shape.circle,
        index: index,
      ),
    );
  }
}
