import 'package:flutter/material.dart';

/// Animates the y axis scale of a transformed widget.
class ScaleYTransition extends AnimatedWidget {
  const ScaleYTransition({
    Key? key,
    required Animation<double> scaleY,
    this.alignment = Alignment.center,
    this.child,
  }) : super(key: key, listenable: scaleY);

  Animation<double> get scaleY => listenable as Animation<double>;

  final Alignment alignment;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final double scaleYValue = scaleY.value;
    final Matrix4 transform = Matrix4.identity()..scale(1.0, scaleYValue, 1.0);
    return Transform(
      transform: transform,
      alignment: alignment,
      child: child,
    );
  }
}
