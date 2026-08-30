# LoadingIndicator
![](https://github.com/TinoGuo/loading_indicator/workflows/Flutter%20Build%20Test%20CI/badge.svg?branch=master)
[![pub package](https://img.shields.io/pub/v/loading_indicator.svg)](https://pub.dev/packages/loading_indicator)
[![pub package](https://img.shields.io/pub/v/loading_indicator.svg)](https://pub.dev/packages/loading_indicator)
![GitHub top language](https://img.shields.io/github/languages/top/TinoGuo/loading_indicator)

一个开箱即用的loading加载库，包含34个不同类型动画，灵感来源于[loaders.css](https://github.com/ConnorAtherton/loaders.css)和[NVActivityIndicatorView](https://github.com/ninjaprox/NVActivityIndicatorView)。


## Demo

现在你可以点击这个[地址](https://tinoguo.github.io/loading_indicator/)来进行预览.**3D效果在web上会失效.**

![](gif/demo_2021_07_18_02.gif)

## 动画类型

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

## 安装

从[pub](https://pub.dev/packages/loading_indicator)安装最新版本。

## 准备发布版本

请在最新的 `master` checkout 中运行发布脚本。脚本会从已有的稳定版本
tag 自动计算下一个版本，并更新根目录的 `pubspec.yaml`：

```bash
./scripts/prepare_release.sh --dry-run
./scripts/prepare_release.sh patch
```

支持 `patch`、`minor`、`major`，也支持直接指定版本号，例如 `4.0.2`。
脚本默认会从 `origin` 刷新 tag，并忽略远端已经删除但本地仍残留的 tag。
如果 release tag 在当前提交历史中，或其提交已经被完整 cherry-pick 到当前分支，则可以继续；否则会停止，
避免 Release changelog 使用错误的起始版本。实际执行 `patch`（不是
`--dry-run`）时，要求本地 `master` 干净且与 `origin/master` 一致，随后只更新根目录
`pubspec.yaml`，自动 commit、push `master`、创建并 push 下一个版本 tag，最后调用
`gh release create --generate-notes`，并使用检测到的上一个 release tag。
脚本不会修改 `example/pubspec.yaml`。需要本机已安装并登录 `gh`；现有按 tag 触发的
workflow 会在脚本已经创建 Release 时自动跳过，避免重复创建。执行 `minor`、`major`
或直接指定版本时，只更新本地根目录 `pubspec.yaml`，并打印 release note 命令供手动执行。

## 使用

简单且强大的API。

```dart
LoadingIndicator(
  indicatorType: Indicator.ballPulse, // 必须：动画类型
  colors: const [Colors.white],        // 可选：颜色集合
  strokeWidth: 2,                      // 可选：描边和线条宽度
  backgroundColor: Colors.black,       // 可选：组件背景色
  pathBackgroundColor: Colors.black,   // 可选：线条背景色
)
```

`strokeWidth` 可调整 `lineScale`、`lineScaleParty`、`lineScalePulseOut`、
`lineScalePulseOutRapid` 和 `lineSpinFadeLoader` 的线条宽度。如果不设置，
这些动画会保持原本根据组件尺寸自动计算的宽度。

不传 Controller 时，所有动画会自动循环播放。需要控制动画时，在组件的生命周期内创建并释放
`LoadingIndicatorController`：

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

Controller 支持全部 34 种动画：

```dart
_controller.pause(); // 立即冻结当前帧。

await _controller.pauseAt(0.5); // 下一次自然运行到 50% 时暂停。

await _controller.pauseAt(
  1.0,
  behavior: LoadingIndicatorPauseBehavior.jumpToTarget,
); // 整组动画立即前进到目标位置并暂停。

_controller.resume();
```

`progress` 是 indicator 参考动画轨道的归一化进度，范围为 `0.0–1.0`：`0.0`
表示循环刚开始，`1.0` 表示重置前的最后一帧。`pauseAt` 会在真正暂停后完成；待执行命令
被替换或 Controller 被释放时，Future 会以 `LoadingIndicatorCommandCanceled` 结束。
一个 Controller 同时只能绑定一个 `LoadingIndicator`；未挂载时提交的最后一条命令会在
下次挂载时执行。

### 从 3.x 迁移

4.0 删除了组件的 `pause` 参数，请改用 Controller：

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
