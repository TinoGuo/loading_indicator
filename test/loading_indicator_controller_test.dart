import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loading_indicator/loading_indicator.dart';

Widget _indicatorApp(
  Indicator indicator, {
  LoadingIndicatorController? controller,
  Key? repaintBoundaryKey,
}) {
  Widget child = SizedBox.square(
    dimension: 100,
    child: LoadingIndicator(
      indicatorType: indicator,
      colors: const [Colors.blue, Colors.red, Colors.green],
      controller: controller,
    ),
  );
  if (repaintBoundaryKey != null) {
    child = RepaintBoundary(key: repaintBoundaryKey, child: child);
  }
  return MaterialApp(home: Center(child: child));
}

Widget _comparisonApp(
  Indicator indicator,
  LoadingIndicatorController firstController,
  LoadingIndicatorController secondController,
  GlobalKey firstKey,
  GlobalKey secondKey,
) {
  Widget item(LoadingIndicatorController controller, GlobalKey key) {
    return RepaintBoundary(
      key: key,
      child: ColoredBox(
        color: Colors.white,
        child: SizedBox.square(
          dimension: 100,
          child: LoadingIndicator(
            indicatorType: indicator,
            colors: const [Colors.blue, Colors.red, Colors.green],
            controller: controller,
          ),
        ),
      ),
    );
  }

  return MaterialApp(
    home: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        item(firstController, firstKey),
        item(secondController, secondKey),
      ],
    ),
  );
}

List<double> _transitionValues(WidgetTester tester, GlobalKey key) {
  final root = find.byKey(key);
  final scales = tester
      .widgetList<ScaleTransition>(
        find.descendant(of: root, matching: find.byType(ScaleTransition)),
      )
      .map((widget) => widget.scale.value);
  final opacities = tester
      .widgetList<FadeTransition>(
        find.descendant(of: root, matching: find.byType(FadeTransition)),
      )
      .map((widget) => widget.opacity.value);
  return [...scales, ...opacities];
}

void main() {
  group('LoadingIndicatorController', () {
    testWidgets('controls every indicator without errors', (tester) async {
      for (final indicator in Indicator.values) {
        final controller = LoadingIndicatorController();
        await tester.pumpWidget(
          _indicatorApp(indicator, controller: controller),
        );
        await tester.pump(const Duration(milliseconds: 32));

        expect(controller.isAttached, isTrue, reason: '$indicator attaches');
        expect(
          controller.status,
          LoadingIndicatorPlaybackStatus.playing,
          reason: '$indicator starts playing',
        );

        controller.pause();
        final pausedProgress = controller.progress;
        await tester.pump(const Duration(seconds: 1));
        expect(
          controller.progress,
          pausedProgress,
          reason: '$indicator pauses immediately',
        );

        for (final target in [0.0, 0.5, 1.0]) {
          await controller.pauseAt(
            target,
            behavior: LoadingIndicatorPauseBehavior.jumpToTarget,
          );
          expect(
            controller.progress,
            closeTo(target, 0.000001),
            reason: '$indicator jumps to $target',
          );

          controller.resume();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 32));
          final naturalPause = controller.pauseAt(target);
          await tester.pump(const Duration(seconds: 7));
          await naturalPause;
          expect(
            controller.progress,
            closeTo(target, 0.000001),
            reason: '$indicator naturally pauses at $target',
          );
        }

        controller.resume();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 32));
        expect(
          controller.progress,
          isNot(closeTo(1.0, 0.000001)),
          reason: '$indicator resumes',
        );
        expect(tester.takeException(), isNull, reason: '$indicator is safe');

        await tester.pumpWidget(const SizedBox.shrink());
        expect(controller.isAttached, isFalse);
        controller.dispose();
      }
    });

    testWidgets('waits for targets ahead and across a loop boundary',
        (tester) async {
      final controller = LoadingIndicatorController();
      await tester.pumpWidget(
        _indicatorApp(Indicator.ballScaleMultiple, controller: controller),
      );
      await tester.pump(const Duration(milliseconds: 200));

      final firstPause = controller.pauseAt(0.5);
      expect(controller.status, LoadingIndicatorPlaybackStatus.pausing);
      await tester.pump(const Duration(milliseconds: 299));
      expect(controller.status, LoadingIndicatorPlaybackStatus.pausing);
      await tester.pump(const Duration(milliseconds: 1));
      await firstPause;
      expect(controller.status, LoadingIndicatorPlaybackStatus.paused);
      expect(controller.progress, closeTo(0.5, 0.000001));

      controller.resume();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(controller.progress, closeTo(0.8, 0.001));

      final wrappedPause = controller.pauseAt(0.2);
      await tester.pump(const Duration(milliseconds: 399));
      expect(controller.status, LoadingIndicatorPlaybackStatus.pausing);
      await tester.pump(const Duration(milliseconds: 1));
      await wrappedPause;
      expect(controller.progress, closeTo(0.2, 0.000001));

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });

    testWidgets('supports exact target and both loop boundaries',
        (tester) async {
      final controller = LoadingIndicatorController();
      await tester.pumpWidget(
        _indicatorApp(Indicator.ballScaleMultiple, controller: controller),
      );

      for (final target in [0.0, 0.5, 1.0]) {
        await controller.pauseAt(
          target,
          behavior: LoadingIndicatorPauseBehavior.jumpToTarget,
        );
        expect(controller.progress, closeTo(target, 0.000001));

        await controller.pauseAt(target);
        expect(controller.status, LoadingIndicatorPlaybackStatus.paused);
        expect(controller.progress, closeTo(target, 0.000001));
      }

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });

    testWidgets('keeps 0.0 and 1.0 distinct for secondary tracks',
        (tester) async {
      final controller = LoadingIndicatorController();
      await tester.pumpWidget(
        _indicatorApp(Indicator.pacman, controller: controller),
      );

      await controller.pauseAt(
        1.0,
        behavior: LoadingIndicatorPauseBehavior.jumpToTarget,
      );
      var opacityValues = tester
          .widgetList<FadeTransition>(find.byType(FadeTransition))
          .map((transition) => transition.opacity.value)
          .toList();
      expect(opacityValues.last, closeTo(0.7, 0.000001));

      await controller.pauseAt(
        0.0,
        behavior: LoadingIndicatorPauseBehavior.jumpToTarget,
      );
      opacityValues = tester
          .widgetList<FadeTransition>(find.byType(FadeTransition))
          .map((transition) => transition.opacity.value)
          .toList();
      expect(opacityValues.last, closeTo(1.0, 0.000001));

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });

    for (final indicator in [
      Indicator.ballScaleMultiple,
      Indicator.ballGridPulse,
    ]) {
      testWidgets('jump and wait preserve the same group frame for $indicator',
          (tester) async {
        final jumpController = LoadingIndicatorController();
        final waitController = LoadingIndicatorController();
        final jumpKey = GlobalKey();
        final waitKey = GlobalKey();
        await tester.pumpWidget(
          _comparisonApp(
            indicator,
            jumpController,
            waitController,
            jumpKey,
            waitKey,
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));

        final jumpFuture = jumpController.pauseAt(
          0.7,
          behavior: LoadingIndicatorPauseBehavior.jumpToTarget,
        );
        final waitFuture = waitController.pauseAt(0.7);
        await jumpFuture;
        await tester.pump(const Duration(seconds: 2));
        expect(
          waitController.status,
          LoadingIndicatorPlaybackStatus.paused,
          reason: '$indicator reaches the natural pause target',
        );
        await waitFuture;
        final jumpValues = _transitionValues(tester, jumpKey);
        final waitValues = _transitionValues(tester, waitKey);
        expect(jumpValues.length, waitValues.length);
        for (var index = 0; index < jumpValues.length; index++) {
          expect(jumpValues[index], closeTo(waitValues[index], 0.000001));
        }

        await tester.pumpWidget(const SizedBox.shrink());
        jumpController.dispose();
        waitController.dispose();
      });
    }

    testWidgets('preserves reverse direction after resuming', (tester) async {
      final controller = LoadingIndicatorController();
      await tester.pumpWidget(
        _indicatorApp(Indicator.ballZigZagDeflect, controller: controller),
      );
      await tester.pump(const Duration(milliseconds: 900));
      controller.pause();
      final reverseProgress = controller.progress!;

      controller.resume();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.progress, lessThan(reverseProgress));

      final pauseFuture = controller.pauseAt(0.8);
      await tester.pump(const Duration(seconds: 2));
      await pauseFuture;
      expect(controller.progress, closeTo(0.8, 0.000001));

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });

    testWidgets('queues commands while detached and applies them on attach',
        (tester) async {
      final controller = LoadingIndicatorController();
      final pauseFuture = controller.pauseAt(
        0.5,
        behavior: LoadingIndicatorPauseBehavior.jumpToTarget,
      );
      expect(controller.status, LoadingIndicatorPlaybackStatus.detached);

      await tester.pumpWidget(
        _indicatorApp(Indicator.circleStrokeSpin, controller: controller),
      );
      await pauseFuture;
      expect(controller.status, LoadingIndicatorPlaybackStatus.paused);
      expect(controller.progress, closeTo(0.5, 0.000001));

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });

    testWidgets('notifies listeners when status and progress change',
        (tester) async {
      final controller = LoadingIndicatorController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      await tester.pumpWidget(
        _indicatorApp(Indicator.ballPulse, controller: controller),
      );
      final afterAttachment = notifications;
      expect(afterAttachment, greaterThan(0));

      await tester.pump(const Duration(milliseconds: 100));
      expect(notifications, greaterThan(afterAttachment));
      final afterProgress = notifications;

      controller.pause();
      expect(notifications, greaterThan(afterProgress));
      expect(controller.status, LoadingIndicatorPlaybackStatus.paused);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });

    testWidgets('resumes automatically when its controller is removed',
        (tester) async {
      final controller = LoadingIndicatorController();
      LoadingIndicatorController? attachedController = controller;
      late StateSetter updateHost;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              updateHost = setState;
              return SizedBox.square(
                dimension: 100,
                child: LoadingIndicator(
                  indicatorType: Indicator.circleStrokeSpin,
                  controller: attachedController,
                ),
              );
            },
          ),
        ),
      );

      controller.pause();
      final pausedValue = tester
          .widget<RotationTransition>(find.byType(RotationTransition))
          .turns
          .value;
      updateHost(() => attachedController = null);
      await tester.pump();
      expect(controller.status, LoadingIndicatorPlaybackStatus.detached);
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester
            .widget<RotationTransition>(find.byType(RotationTransition))
            .turns
            .value,
        isNot(closeTo(pausedValue, 0.000001)),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });

    testWidgets('retains a waiting command across detach and reattach',
        (tester) async {
      final controller = LoadingIndicatorController();
      await tester.pumpWidget(
        _indicatorApp(Indicator.ballScaleMultiple, controller: controller),
      );
      final pauseFuture = controller.pauseAt(0.9);
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(const SizedBox.shrink());
      expect(controller.status, LoadingIndicatorPlaybackStatus.detached);
      await tester.pumpWidget(
        _indicatorApp(Indicator.ballScaleMultiple, controller: controller),
      );
      await tester.pump(const Duration(seconds: 1));
      await pauseFuture;
      expect(controller.status, LoadingIndicatorPlaybackStatus.paused);
      expect(controller.progress, closeTo(0.9, 0.000001));

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });

    testWidgets('cancels replaced and disposed commands', (tester) async {
      final controller = LoadingIndicatorController();
      await tester.pumpWidget(
        _indicatorApp(Indicator.ballScaleMultiple, controller: controller),
      );

      final replaced = controller.pauseAt(0.9);
      final replacedExpectation = expectLater(
        replaced,
        throwsA(isA<LoadingIndicatorCommandCanceled>()),
      );
      controller.resume();
      await replacedExpectation;

      final disposed = controller.pauseAt(0.9);
      final disposedExpectation = expectLater(
        disposed,
        throwsA(isA<LoadingIndicatorCommandCanceled>()),
      );
      controller.dispose();
      await disposedExpectation;
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });

    testWidgets('rejects concurrent attachment', (tester) async {
      final controller = LoadingIndicatorController();
      await tester.pumpWidget(
        MaterialApp(
          home: Row(
            children: [
              Expanded(
                child: LoadingIndicator(
                  indicatorType: Indicator.ballPulse,
                  controller: controller,
                ),
              ),
              Expanded(
                child: LoadingIndicator(
                  indicatorType: Indicator.ballBeat,
                  controller: controller,
                ),
              ),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isFlutterError);
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });

    test('validates progress and rejects commands after dispose', () {
      final controller = LoadingIndicatorController();
      expect(() => controller.pauseAt(-0.1), throwsRangeError);
      expect(() => controller.pauseAt(1.1), throwsRangeError);
      expect(() => controller.pauseAt(double.nan), throwsRangeError);
      controller.dispose();
      expect(controller.pause, throwsStateError);
      expect(controller.resume, throwsStateError);
      expect(() => controller.pauseAt(0.5), throwsStateError);
    });
  });
}
