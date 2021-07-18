# LoadingIndicator
![](https://github.com/TinoGuo/loading_indicator/workflows/Flutter%20Build%20Test%20CI/badge.svg?branch=master)
[![pub package](https://img.shields.io/pub/v/loading_indicator.svg)](https://pub.dev/packages/loading_indicator)

A collection of out of the box loading animations written in pure dart, no extra dependency, inspired by [loaders.css](https://github.com/ConnorAtherton/loaders.css) and [NVActivityIndicatorView](https://github.com/ninjaprox/NVActivityIndicatorView).


## Demo

Now, you can click [this site](https://tinoguo.github.io/loading_indicator/) to preview.**3D effect will be invalid in web.**

![](gif/demo_2021_07_18_02.gif)

## Animation types

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

## Installing
Install the latest version from [pub](https://pub.dev/packages/loading_indicator)

## Usage
Simple but powerful parameters

```
LoadingIndicator(
    indicatorType: Indicator.ballPulse, /// Required, The loading type of the widget
    colors: const [Colors.white],       /// Optional, The color collections
    strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
    backgroundColor: Colors.black,      /// Optional, Background of the widget
    pathBackgroundColor: Colors.black   /// Optional, the stroke backgroundColor
)
```

[中文版](README_CN.md)

## License
[Apache 2.0](LICENSE)