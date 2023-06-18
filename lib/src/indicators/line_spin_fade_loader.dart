import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

import '../decorate/decorate.dart';

/// LineSpinFadeLoader.
class LineSpinFadeLoader extends StatefulWidget {
  const LineSpinFadeLoader({Key? key}) : super(key: key);

  @override
  State<LineSpinFadeLoader> createState() => _LineSpinFadeLoaderState();
}

const int _kLineSize = 8;

class _LineSpinFadeLoaderState extends State<LineSpinFadeLoader>
    with TickerProviderStateMixin, IndicatorController {
  static const _durationInMills = 1000;
  static const _delayInMills = [0, 120, 240, 360, 480, 600, 720, 840];

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _opacityAnimations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _kLineSize; i++) {
      _animationControllers.add(AnimationController(
        value: _delayInMills[i] / _durationInMills,
        vsync: this,
        duration: const Duration(milliseconds: _durationInMills),
      ));
      _opacityAnimations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear)));

      _animationControllers[i].repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strokeWidth = DecorateContext.of(context)!.decorateData.strokeWidth;
    return LayoutBuilder(builder: (ctx, constraint) {
      final circleSize = constraint.maxWidth / 3;

      final widgets = List<Widget>.filled(8, Container());
      final center = Offset(constraint.maxWidth / 2, constraint.maxHeight / 2);
      for (int i = 0; i < widgets.length; i++) {
        final angle = pi * i / 4;
        widgets[i] = Positioned.fromRect(
          rect: Rect.fromLTWH(
            center.dx + circleSize * (sin(angle)) - circleSize / 4,
            center.dy + circleSize * (cos(angle)) - circleSize / 2,
            circleSize / 2,
            circleSize,
          ),
          child: FadeTransition(
            opacity: _opacityAnimations[i],
            child: Transform.rotate(
              angle: -angle,
              child: IndicatorShapeWidget(
                shape: Line(strokeWidth: strokeWidth),
                index: i,
              ),
            ),
          ),
        );
      }
      return Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: widgets,
      );
    });
  }
}
