import 'package:flutter/material.dart';
import 'package:loading_indicator/src/decorate/decorate.dart';

/// CircleStrokeSpin.
class CircleStrokeSpin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = DecorateContext.of(context)!.decorateData.colors.first;
    return CircularProgressIndicator(
      strokeWidth: 2,
      color: color,
      backgroundColor:
          DecorateContext.of(context)!.decorateData.pathBackgroundColor,
    );
  }
}
