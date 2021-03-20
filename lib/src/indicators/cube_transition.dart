import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// CubeTransition.
class CubeTransition extends StatefulWidget {
  @override
  _CubeTransitionState createState() => _CubeTransitionState();
}

class _CubeTransitionState extends State<CubeTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Size?> _translateAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
    _translateAnimation = TweenSequence([
      TweenSequenceItem(
          tween: SizeTween(begin: Size(0.0, 0.0), end: Size(1.0, 0.0)),
          weight: 1),
      TweenSequenceItem(
          tween: SizeTween(begin: Size(1.0, 0.0), end: Size(1.0, 1.0)),
          weight: 1),
      TweenSequenceItem(
          tween: SizeTween(begin: Size(1.0, 1.0), end: Size(0.0, 1.0)),
          weight: 1),
      TweenSequenceItem(
          tween: SizeTween(begin: Size(0.0, 1.0), end: Size(0.0, 0.0)),
          weight: 1),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));

    _rotateAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -pi / 2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -pi / 2, end: -pi), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -pi, end: -pi * 1.5), weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: -pi * 1.5, end: -pi * 2), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraint) {
      final squareSize = constraint.maxWidth / 5;

      final deltaX = constraint.maxWidth - squareSize;
      final deltaY = constraint.maxHeight - squareSize;

      return AnimatedBuilder(
        animation: _animationController,
        child: IndicatorShapeWidget(shape: Shape.rectangle),
        builder: (_, child) => Stack(
          children: [
            Positioned.fromRect(
              rect: Rect.fromLTWH(0, 0, squareSize, squareSize),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(_translateAnimation.value!.width * deltaX,
                      _translateAnimation.value!.height * deltaY)
                  ..rotateZ(_rotateAnimation.value)
                  ..scale(_scaleAnimation.value),
                child: child,
              ),
            ),
            Positioned.fromRect(
              rect: Rect.fromLTWH(constraint.maxWidth - squareSize,
                  constraint.maxHeight - squareSize, squareSize, squareSize),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(-_translateAnimation.value!.width * deltaX,
                      -_translateAnimation.value!.height * deltaY)
                  ..rotateZ(_rotateAnimation.value)
                  ..scale(_scaleAnimation.value),
                child: child,
              ),
            ),
          ],
        ),
      );
    });
  }
}
