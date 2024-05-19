// ignore_for_file: avoid_print

import "dart:math";

import "package:a_star/a_star.dart";

class CoordinatesState extends AStarState<CoordinatesState> {
  final int x;
  final int y;
  final int goalX;
  final int goalY;
  final String? direction;
  CoordinatesState(this.x, this.y, this.goalX, this.goalY, {this.direction, required super.depth});

  Iterable<CoordinatesState> getNeighbors() => [
    CoordinatesState(x, y + 1, goalX, goalY, direction: "up", depth: depth + 1),
    CoordinatesState(x, y - 1, goalX, goalY, direction: "down", depth: depth + 1),
    CoordinatesState(x + 1, y, goalX, goalY, direction: "right", depth: depth + 1),
    CoordinatesState(x - 1, y, goalX, goalY, direction: "left", depth: depth + 1),
  ];

  bool get isValid => true;

  @override
  Iterable<CoordinatesState> expand() => [
    for (final neighbor in getNeighbors())
      if (neighbor.isValid)
        neighbor,
  ];

  @override
  double heuristic() => sqrt(pow(goalX - x, 2) + pow(goalY - y, 2));

  @override
  bool isGoal() => x == goalX && y == goalY;

  @override
  String hash() => "($x, $y)";
}

void main() {
  final start = CoordinatesState(0, 0, 10, 10, depth: 0);
  final result = aStar(start);
  if (result == null) {
    print("Could not find a path");
    return;
  }
  final path = result.reconstructPath();
  for (final intermediate in path) {
    if (intermediate.direction == null) {
      print("Start at ${intermediate.hash()}");
    } else {
      print("Go ${intermediate.direction} to ${intermediate.hash()}");
    }
  }
}
