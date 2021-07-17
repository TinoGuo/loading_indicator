# LoadingIndicator
![](https://github.com/TinoGuo/loading_indicator/workflows/Flutter%20Build%20Test%20CI/badge.svg?branch=master)
[![pub package](https://img.shields.io/pub/v/loading_indicator.svg)](https://pub.dev/packages/loading_indicator)

A collection of out of the box loading animations written in pure dart, no extra dependency, inspired by [loaders.css](https://github.com/ConnorAtherton/loaders.css) and [NVActivityIndicatorView](https://github.com/ninjaprox/NVActivityIndicatorView).


## Demo

Now, you can click [this site](https://tinoguo.github.io/loading_indicator/) to preview.**3D effect will be invalid in web.**

![](gif/demo_2021_07_18.gif)

## Animation types

| Type | Type | Type | Type |
|---|---|---|---|
|1. ballPulse | 2. ballGridPulse | 3. ballClipRotate | 4. squareSpin|
|5. ballClipRotatePulse | 6. ballClipRotateMultiple | 7. ballPulseRise | 8. ballRotate|
|9. cubeTransition | 10. ballZigZag | 11. ballZigZagDeflect | 12. ballTrianglePath|
|13. ballScale | 14. lineScale | 15. lineScaleParty | 16. ballScaleMultiple|
|17. ballPulseSync | 18. ballBeat | 19. lineScalePulseOut | 20. lineScalePulseOutRapid|
|21. ballScaleRipple | 22. ballScaleRippleMultiple | 23. ballSpinFadeLoader | 24. lineSpinFadeLoader|
|25. triangleSkewSpin | 26. pacman | 27. ballGridBeat | 28. semiCircleSpin|
|29. ballRotateChase | 30. orbit | 31. audioEqualizer | 32. circleStrokeSpin|

## Installing
Install the latest version from [pub](https://pub.dev/packages/loading_indicator)

## Usage
Simple but powerful parameters

```
LoadingIndicator(
    colors: const [Colors.white],       /// The color collections
    indicatorType: Indicator.ballPulse, /// The loading type of the widget
    strokeWidth: 2,                     /// The stroke of the line, only applicable to widget which contains line
    backgroundColor: Colors.black,      /// Background of the widget
)
```

[中文版](README_CN.md)

## License
[Apache 2.0](LICENSE)