import 'package:flutter/material.dart';

import '../loading.dart';

class DecorateData {
  final Color color;
  final Indicator indicator;

  const DecorateData({@required this.indicator, this.color = Colors.white});

  @override
  bool operator ==(other) =>
      other is DecorateData &&
      this.color == other.color &&
      this.indicator == other.indicator;

  @override
  int get hashCode => 31 * this.color.hashCode + this.indicator.hashCode;

  @override
  String toString() {
    return 'DecorateData{color: $color, indicator: $indicator}';
  }
}

class DecorateContext extends InheritedWidget {
  final DecorateData decorateData;

  DecorateContext({
    Key key,
    @required this.decorateData,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return !(oldWidget is DecorateContext &&
        oldWidget.decorateData == this.decorateData);
  }

  static DecorateContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(DecorateContext);
  }
}
