# CHANGES

## 1.1.0
* Updated to Dart 3.0
* Added more generic AStarState API, which allows for an infinite or non-physical grid
* Added AStarTransition, which describes going from one state to another

## 1.0.0
* Updated for Dart 2.15+ null safety
* dart:html web/* example still exists, but is not tested and may not work.
* Move from hand-rolled set of lints to Dart team package:lint recommended ones.

## 0.4.0
* Updated for compatibility with 2019 Dart (2.8+).

## 0.2.0

* Fix bug with rounding and actually find the shortest path.
  https://github.com/sethladd/dart-a-star/pull/1