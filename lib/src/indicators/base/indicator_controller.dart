import 'package:flutter/material.dart';
import 'package:loading_indicator/src/decorate/decorate.dart';

mixin IndicatorController<T extends StatefulWidget> on State<T> {
  bool isPaused = false;

  List<AnimationController> get animationControllers;

  @override
  void activate() {
    super.activate();
    _initAnimState();
  }

  void _initAnimState() {
    final DecorateData decorateData = DecorateContext.of(context)!.decorateData;
    isPaused = decorateData.pause;
  }

  @override
  void didChangeDependencies() {
    final DecorateData decorateData = DecorateContext.of(context)!.decorateData;
    if (decorateData.pause != isPaused) {
      isPaused = decorateData.pause;
      if (decorateData.pause) {
        for (var element in animationControllers) {
          element.stop(canceled: false);
        }
      } else {
        for (var element in animationControllers) {
          element.repeat();
        }
      }
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    for (var element in animationControllers) {
      element.dispose();
    }
    super.dispose();
  }
}
