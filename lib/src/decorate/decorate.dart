import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

/// Information about a piece of animation (e.g., color).
@immutable
class DecorateData {
  final Color color;
  final Indicator indicator;
  final List<Color>? colors;

  const DecorateData(
      {required this.indicator, this.color = Colors.white, this.colors});

  @override
  bool operator ==(other) {
    if (other.runtimeType != this.runtimeType) return false;

    return other is DecorateData &&
        this.color == other.color &&
        this.colors == other.colors &&
        this.indicator == other.indicator;
  }

  @override
  int get hashCode => hashValues(color, indicator);

  @override
  String toString() {
    return 'DecorateData{color: $color, indicator: $indicator}';
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
