# LoadingIndicator
![](https://github.com/TinoGuo/loading_indicator/workflows/Flutter%20Build%20Test%20CI/badge.svg?branch=master)
[![pub package](https://img.shields.io/pub/v/loading_indicator.svg)](https://pub.dev/packages/loading_indicator)

一个开箱即用的loading加载库，包含34个不同类型动画，灵感来源于[loaders.css](https://github.com/ConnorAtherton/loaders.css)和[NVActivityIndicatorView](https://github.com/ninjaprox/NVActivityIndicatorView)。


## Demo

现在你可以点击这个[地址](https://tinoguo.github.io/loading_indicator/)来进行预览.**3D效果在web上会失效.**

![](gif/demo_2021_07_18_02.gif)

## 动画类型

| Type | Type | Type | Type |
|---|---|---|---|
|1. ballPulse | 2. ballGridPulse | 3. ballClipRotate | 4. squareSpin|
|5. ballClipRotatePulse | 6. ballClipRotateMultiple | 7. ballPulseRise | 8. ballRotate|
|9. cubeTransition | 10. ballZigZag | 11. ballZigZagDeflect | 12. ballTrianglePath|
|13. ballTrianglePathColored | 14.ballTrianglePathColoredFilled | 15. ballScale | 16. lineScale|
|17. lineScaleParty | 18. ballScaleMultiple | 19. ballPulseSync | 20. ballBeat|
|21. lineScalePulseOut | 22. lineScalePulseOutRapid |23. ballScaleRipple | 24. ballScaleRippleMultiple|
|25. ballSpinFadeLoader | 26. lineSpinFadeLoader | 27. triangleSkewSpin | 28. pacman|
|29. ballGridBeat | 30. semiCircleSpin| 31. ballRotateChase | 32. orbit|
|33. audioEqualizer | 34. circleStrokeSpin|

## 安装
从[pub](https://pub.dev/packages/loading_indicator)安装最新版本。

## 使用
简单且强大的API。

```
LoadingIndicator(
    colors: const [Colors.white],       /// 必须, 颜色集合
    indicatorType: Indicator.ballPulse, /// 可选, loading的类型
    strokeWidth: 2,                     /// 可选, 线条宽度，只对含有线条的组件有效
    backgroundColor: Colors.black,      /// 可选, 组件背景色
    pathBackgroundColor: Colors.black   /// 可选, 线条背景色
)
```

## 开源协议
[Apache 2.0](LICENSE)