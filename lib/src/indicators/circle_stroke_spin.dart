import 'package:flutter/material.dart';
import 'package:loading_indicator/src/decorate/decorate.dart';

/// CircleStrokeSpin.
class CircleStrokeSpin extends StatelessWidget {
  const CircleStrokeSpin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = DecorateContext.of(context)!.decorateData.colors.first;
    return CircularProgressIndicator(
      strokeWidth: DecorateContext.of(context)!.decorateData.strokeWidth,
      color: color,
      backgroundColor:
          DecorateContext.of(context)!.decorateData.pathBackgroundColor,
    );
  }
}
