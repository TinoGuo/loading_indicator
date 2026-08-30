# LoadingIndicator
![](https://github.com/TinoGuo/loading_indicator/workflows/Flutter%20Build%20Test%20CI/badge.svg?branch=master)
[![pub package](https://img.shields.io/pub/v/loading_indicator.svg)](https://pub.dev/packages/loading_indicator)
![GitHub top language](https://img.shields.io/github/languages/top/TinoGuo/loading_indicator)

A collection of out of the box loading animations written in pure dart, no extra dependency, inspired by [loaders.css](https://github.com/ConnorAtherton/loaders.css) and [NVActivityIndicatorView](https://github.com/ninjaprox/NVActivityIndicatorView).


## Demo

Now, you can click [this site](https://tinoguo.github.io/loading_indicator/) to preview.**3D effect will be invalid in web.**

![](gif/demo_2021_07_18_02.gif)

## Animation types

| Type                        | Type                             | Type                  | Type                        |
|-----------------------------|----------------------------------|-----------------------|-----------------------------|
| 1. ballPulse                | 2. ballGridPulse                 | 3. ballClipRotate     | 4. squareSpin               |
| 5. ballClipRotatePulse      | 6. ballClipRotateMultiple        | 7. ballPulseRise      | 8. ballRotate               |
| 9. cubeTransition           | 10. ballZigZag                   | 11. ballZigZagDeflect | 12. ballTrianglePath        |
| 13. ballTrianglePathColored | 14.ballTrianglePathColoredFilled | 15. ballScale         | 16. lineScale               |
| 17. lineScaleParty          | 18. ballScaleMultiple            | 19. ballPulseSync     | 20. ballBeat                |
| 21. lineScalePulseOut       | 22. lineScalePulseOutRapid       | 23. ballScaleRipple   | 24. ballScaleRippleMultiple |
| 25. ballSpinFadeLoader      | 26. lineSpinFadeLoader           | 27. triangleSkewSpin  | 28. pacman                  |
| 29. ballGridBeat            | 30. semiCircleSpin               | 31. ballRotateChase   | 32. orbit                   |
| 33. audioEqualizer          | 34. circleStrokeSpin             |

## Installing

Install the latest version from [pub](https://pub.dev/packages/loading_indicator)

## Preparing a release

Use the release helper from the latest `master` checkout to calculate the next
version from the existing stable tags and update the root `pubspec.yaml`:

```bash
./scripts/prepare_release.sh --dry-run
./scripts/prepare_release.sh patch
```

`patch`, `minor`, and `major` are supported, as well as an explicit version
such as `4.0.2`. The helper refreshes tags from `origin` and refuses to
continue when the latest tag is not part of the current history. A real patch
run (not `--dry-run`) requires a clean `master` matching `origin/master`,
updates only the root `pubspec.yaml`, commits it, pushes `master`, creates and
pushes the next version tag, and invokes `gh release create` with
`--generate-notes` and the detected previous release tag. It does not modify
`example/pubspec.yaml`. `gh` must be installed and authenticated. The existing
tag-triggered workflow safely skips release creation when the script has
already created it. `minor`, `major`, and explicit versions only update the
local root `pubspec.yaml` and print the release-notes command.

## Usage

Simple but powerful parameters

```dart
LoadingIndicator(
  indicatorType: Indicator.ballPulse, // Required: animation type
  colors: const [Colors.white],        // Optional: color collection
  strokeWidth: 2,                      // Optional: stroke and line width
  backgroundColor: Colors.black,       // Optional: widget background
  pathBackgroundColor: Colors.black,   // Optional: stroke background
)
```

`strokeWidth` controls the bar width of `lineScale`, `lineScaleParty`,
`lineScalePulseOut`, `lineScalePulseOutRapid`, and `lineSpinFadeLoader`.
When omitted, these indicators keep their original size-derived bar width.

Without a controller, every indicator plays continuously. To control playback,
create and dispose a `LoadingIndicatorController` with your widget:

```dart
late final LoadingIndicatorController _controller;

@override
void initState() {
  super.initState();
  _controller = LoadingIndicatorController();
}

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return LoadingIndicator(
    indicatorType: Indicator.ballScaleMultiple,
    controller: _controller,
  );
}
```

The controller works with all 34 animation types:

```dart
_controller.pause(); // Freeze the current frame immediately.

await _controller.pauseAt(0.5); // Pause the next time progress reaches 50%.

await _controller.pauseAt(
  1.0,
  behavior: LoadingIndicatorPauseBehavior.jumpToTarget,
); // Advance the complete animation group to the target and pause now.

_controller.resume();
```

`progress` is the normalized position (`0.0` to `1.0`) of an indicator's
reference animation track: `0.0` is the start of a loop and `1.0` is its final
frame before reset. `pauseAt` completes only after the indicator has paused.
Replacing a pending command or disposing the controller completes that Future
with `LoadingIndicatorCommandCanceled`. One controller can be attached to only
one `LoadingIndicator` at a time; the last command sent while detached is
applied on the next attachment.

### Migrating from 3.x

Version 4.0 removes the `pause` widget parameter. Replace it with a controller:

```dart
// 3.x
LoadingIndicator(indicatorType: Indicator.ballPulse, pause: isPaused);

// 4.0
LoadingIndicator(
  indicatorType: Indicator.ballPulse,
  controller: controller,
);

void setPaused(bool isPaused) {
  isPaused ? controller.pause() : controller.resume();
}
```

[中文版](README_CN.md)

## License

```text
Copyright 2019 Tino Guo.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
