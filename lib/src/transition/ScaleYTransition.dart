import 'package:flutter/material.dart';

class ScaleYTransition extends AnimatedWidget {
  const ScaleYTransition({
    Key key,
    @required Animation<double> scaleY,
    this.alignment = Alignment.center,
    this.child,
  })  : assert(scaleY != null),
        super(key: key, listenable: scaleY);

  Animation<double> get scaleY => listenable;

  final Alignment alignment;

  final Widget child;

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
