# CHANGES

## 3.0.0
* **Breaking**: Moved `AStarNode.depth` to `AStarState.depth`. This allows you to customize your depth values, which is useful in cases where different actions have different costs

## 2.0.0
* Updated to Dart 3.0
* Added a more generic API, which allows for an infinite or non-physical grid
* **Breaking**: Removed the legacy API

## 1.0.0
* Updated for Dart 2.15+ null safety
* dart:html web/* example still exists, but is not tested and may not work.
* Move from hand-rolled set of lints to Dart team package:lint recommended ones.

## 0.4.0
* Updated for compatibility with 2019 Dart (2.8+).

## 0.2.0

* Fix bug with rounding and actually find the shortest path.
  https://github.com/sethladd/dart-a-star/pull/1