import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// LineScaleParty.
class LineScaleParty extends StatefulWidget {
  const LineScaleParty({Key? key}) : super(key: key);

  @override
  _LineScalePartyState createState() => _LineScalePartyState();
}

class _LineScalePartyState extends State<LineScaleParty>
    with TickerProviderStateMixin {
  static const _beginTimes = [770, 290, 280, 740];
  static const _durations = [1260, 430, 1010, 730];

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _animations = [];
  final List<CancelableOperation<int>> _delayFeatures = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 4; i++) {
      _animationControllers.add(AnimationController(
          vsync: this, duration: Duration(milliseconds: _durations[i])));

      _animations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear)));

      _delayFeatures.add(CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: _beginTimes[i])).then((t) {
        _animationControllers[i].repeat();
        return 0;
      })));
    }
  }

  @override
  void dispose() {
    for (var f in _delayFeatures) {
      f.cancel();
    }
    for (var f in _animationControllers) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = _animations
        .asMap()
        .entries
        .map(
          (entry) => Expanded(
            child: AnimatedBuilder(
              animation: entry.value,
              builder: (BuildContext context, Widget? child) {
                return FractionallySizedBox(
                  heightFactor: entry.value.value,
                  child: IndicatorShapeWidget(
                    shape: Shape.line,
                    index: entry.key,
                  ),
                );
              },
            ),
          ),
        )
        .toList();

    for (int i = 0; i < widgets.length - 1; i++) {
      if (i % 2 == 0) {
        widgets.insert(++i, Expanded(child: Container()));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }
}
