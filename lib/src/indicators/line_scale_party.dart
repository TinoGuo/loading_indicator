import 'package:flutter/material.dart';
import 'package:loading_indicator/src/indicators/base/indicator_controller.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// LineScaleParty.
class LineScaleParty extends StatefulWidget {
  const LineScaleParty({Key? key}) : super(key: key);

  @override
  State<LineScaleParty> createState() => _LineScalePartyState();
}

class _LineScalePartyState extends State<LineScaleParty>
    with TickerProviderStateMixin, IndicatorController {
  static const _delayInMills = [770, 290, 280, 740];
  static const _durationInMills = [1260, 430, 1010, 730];

  final List<AnimationController> _animationControllers = [];
  final List<Animation<double>> _animations = [];

  @override
  List<AnimationController> get animationControllers => _animationControllers;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 4; i++) {
      _animationControllers.add(AnimationController(
        value: _delayInMills[i] / _durationInMills[i],
        vsync: this,
        duration: Duration(milliseconds: _durationInMills[i]),
      ));

      _animations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear)));

      _animationControllers[i].repeat();
    }
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
