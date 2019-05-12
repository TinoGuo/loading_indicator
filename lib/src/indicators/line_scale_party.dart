import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

class LineScaleParty extends StatefulWidget {
  @override
  _LineScalePartyState createState() => _LineScalePartyState();
}

class _LineScalePartyState extends State<LineScaleParty>
    with TickerProviderStateMixin {
  static const _BEGIN_TIMES = [770, 290, 280, 740];
  static const _DURATION = [1260, 430, 1010, 730];

  List<AnimationController> _animationControllers = List(4);
  List<Animation<double>> _animations = List(4);
  List<CancelableOperation<int>> _delayFeatures = List(4);

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 4; i++) {
      _animationControllers[i] = AnimationController(
          vsync: this, duration: Duration(milliseconds: _DURATION[i]))
        ..addListener(() => setState(() {}));

      _animations[i] = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear));

      _delayFeatures[i] = CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: _BEGIN_TIMES[i])).then((t) {
        _animationControllers[i].repeat();
      }));
    }
  }

  @override
  void dispose() {
    for (var value1 in _delayFeatures) {
      value1.cancel();
    }
    for (var value in _animationControllers) {
      value.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = _animations
        .map((Animation<double> anim) => anim.value)
        .map((double val) => Expanded(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..scale(1.0, val),
                child: IndicatorShapeWidget(Shape.line),
              ),
            ))
        .toList();

    for (int i = 0; i < widgets.length - 1; i++) {
      if (i % 2 == 0) {
        widgets.insert(++i, Expanded(child: Container()));
      }
    }

    return Row(children: widgets);
  }
}
