import 'package:flutter/material.dart';
import 'package:loading_indicator/src/decorate/decorate.dart';

const double _kDefaultStrokeWidth = 2;

/// CircleStrokeSpin.
class CircleStrokeSpin extends StatelessWidget {
  const CircleStrokeSpin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = DecorateContext.of(context)!.decorateData.colors.first;
    final strokeWidth = DecorateContext.of(context)!.decorateData.strokeWidth;
    return CircularProgressIndicator(
      strokeWidth: strokeWidth == 0 ? _kDefaultStrokeWidth : strokeWidth,
      color: color,
      backgroundColor:
          DecorateContext.of(context)!.decorateData.pathBackgroundColor,
    );
  }
}
