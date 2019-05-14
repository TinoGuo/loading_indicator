import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

class BallSpinFadeLoader extends StatefulWidget {
  @override
  _BallSpinFadeLoaderState createState() => _BallSpinFadeLoaderState();
}

class _BallSpinFadeLoaderState extends State<BallSpinFadeLoader>
    with TickerProviderStateMixin {
  static const _BEGIN_TIMES = [0, 120, 240, 360, 480, 600, 720, 840];

  List<AnimationController> _animationControllers = List(8);
  List<Animation<double>> _scaleAnimations = List(8);
  List<Animation<double>> _opacityAnimations = List(8);
  List<CancelableOperation<int>> _delayFeatures = List(8);

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _animationControllers.length; i++) {
      _animationControllers[i] =
          AnimationController(vsync: this, duration: const Duration(seconds: 1))
            ..addListener(() => setState(() {}));
      _opacityAnimations[i] = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear));
      _scaleAnimations[i] = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear));

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
    return LayoutBuilder(builder: (ctx, constraint) {
      final circleSize = constraint.maxWidth / 3;

      final widgets = List<Widget>(8);
      final center = Offset(constraint.maxWidth / 2, constraint.maxHeight / 2);
      for (int i = 0; i < widgets.length; i++) {
        final angle = pi * i / 4;
        widgets[i] = Positioned.fromRect(
          rect: Rect.fromLTWH(
            /// the radius is circleSize / 4, the startX and startY need to subtract that value.
            center.dx + circleSize * (sin(angle)) - circleSize / 4,
            center.dy + circleSize * (cos(angle)) - circleSize / 4,
            circleSize / 2,
            circleSize / 2,
          ),
          child: Opacity(
            opacity: _opacityAnimations[i].value,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(_scaleAnimations[i].value),
              child: IndicatorShapeWidget(shape: Shape.circle),
            ),
          ),
        );
      }

      return Stack(children: widgets);
    });
  }
}
