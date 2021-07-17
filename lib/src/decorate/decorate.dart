import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

/// Information about a piece of animation (e.g., color).
@immutable
class DecorateData {
  final Color? backgroundColor;
  final Indicator indicator;
  final List<Color> colors;

  const DecorateData({
    required this.indicator,
    this.backgroundColor,
    required this.colors,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecorateData &&
          runtimeType == other.runtimeType &&
          backgroundColor == other.backgroundColor &&
          indicator == other.indicator &&
          colors == other.colors;

  @override
  int get hashCode =>
      backgroundColor.hashCode ^ indicator.hashCode ^ colors.hashCode;

  @override
  String toString() {
    return 'DecorateData{backgroundColor: $backgroundColor, indicator: $indicator, colors: $colors}';
  }
}

/// Establishes a subtree in which decorate queries resolve to the given data.
class DecorateContext extends InheritedWidget {
  final DecorateData decorateData;

  DecorateContext({
    Key? key,
    required this.decorateData,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(DecorateContext oldWidget) =>
      oldWidget.decorateData == this.decorateData;

  static DecorateContext? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }
}
