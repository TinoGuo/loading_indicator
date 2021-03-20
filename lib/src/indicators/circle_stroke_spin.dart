import 'package:flutter/material.dart';
import 'package:loading_indicator/src/decorate/decorate.dart';

/// CircleStrokeSpin.
class CircleStrokeSpin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = DecorateContext.of(context)!.decorateData.color;
    return Theme(
      data: Theme.of(context).copyWith(accentColor: color),
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }
}
