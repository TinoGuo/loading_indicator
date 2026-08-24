### [4.0.0] 2026/08/24
* **Breaking:** Remove the `pause` parameter from `LoadingIndicator` and add `LoadingIndicatorController`.
* Support immediate pause, natural `pauseAt`, virtual-time jump, resume, playback status, progress, and command cancellation.
* Add controllable playback to all 34 indicators, including a package-owned `circleStrokeSpin` animation.
* Preserve the direction and relative timing of multi-track and reversing animations when pausing or jumping.
* Apply `strokeWidth` to every line indicator [#36](https://github.com/TinoGuo/loading_indicator/pull/36)
* Update the example and English/Chinese migration documentation.

### [3.1.1] 2023/06/25
* Update SDK constraints
* Fix CI issue

### [3.1.0] 2022/05/15
* Remove delay future implementation
* Smooth animation when start
* Support pause animation

### [3.0.4] 2022/05/12
* Fix rebuild not work [#27](https://github.com/TinoGuo/loading_indicator/issues/27)

### [3.0.3] 2022/02/26
* Configure the strokeWidth from decorate data [#25](https://github.com/TinoGuo/loading_indicator/issues/25)

### [3.0.2] 2021/09/25
* Apply Lint and analyzer

### [3.0.1] 2021/07/19
* Fix the line corner be sharp after scale [#16](https://github.com/TinoGuo/loading_indicator/issues/16)

### [3.0.0] 2021/07/18
* Support color collection [#17](https://github.com/TinoGuo/loading_indicator/pull/17)
* Support customize stroke width [#17](https://github.com/TinoGuo/loading_indicator/pull/17)
* Support customize stroke background [#18](https://github.com/TinoGuo/loading_indicator/pull/18)

### [2.1.1] 2021/05/22
* Bump Dart to 2.13

### [2.0.1] 2021/03/28
* Fix not some animations not working

### [2.0.0] 2021/03/11
* Added support for null safety (Flutter 2.0)
* Updated deprecated items.

### [1.2.0] - 2020/07/18
* add `ball_triangle_path_colored`, thanks [Kok Wai Gie](https://github.com/woshikie)

### [1.1.0] - 2019/05/23
* color is not required, if it is null, it will follow primary color.
* aspectRatio is 1 to keep all animation play as expected.

### [1.0.0] - 2019/05/14.
* improve performance.
* add chinese readme.

### [0.0.1] - 2019/05/11.
* initial release.
