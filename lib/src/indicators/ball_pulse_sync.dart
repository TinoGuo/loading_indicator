import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// BallPulseSync.
class BallPulseSync extends StatefulWidget {
  const BallPulseSync({Key? key}) : super(key: key);

  @override
  _BallPulseSyncState createState() => _BallPulseSyncState();
}

class _BallPulseSyncState extends State<BallPulseSync>
    with TickerProviderStateMixin {
  static const _beginTimes = [70, 140, 210];

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _animations = [];
  final List<CancelableOperation<int>> _delayFeatures = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      _animationControllers.add(AnimationController(
          vsync: this, duration: const Duration(milliseconds: 600)));

      _animations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: -1.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -1.0, end: 0.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.easeInOut)));

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
    return LayoutBuilder(builder: (ctx, constraint) {
      final circleSize = (constraint.maxWidth - 4) / 3;
      final deltaY = (constraint.maxHeight / 2 - circleSize) / 2;

      List<Widget> widgets = List.filled(5, Container());
      for (int i = 0; i < 5; i++) {
        if (i.isEven) {
          widgets[i] = Expanded(
            child: AnimatedBuilder(
              animation: _animationControllers[i ~/ 2],
              builder: (_, child) {
                return Transform.translate(
                  offset: Offset(0, _animations[i ~/ 2].value * deltaY),
                  child: child,
                );
              },
              child: IndicatorShapeWidget(
                shape: Shape.circle,
                index: i,
              ),
            ),
          );
        } else {
          widgets[i] = const Expanded(
            child: SizedBox(),
          );
        }
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgets,
      );
    });
  }
}
