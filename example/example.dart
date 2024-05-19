// ignore_for_file: avoid_print

import "package:a_star/a_star.dart";

class CoordinatesState extends AStarState<CoordinatesState> {
  final int x;
  final int y;
  final int goalX;
  final int goalY;
  final String? direction;
  CoordinatesState(this.x, this.y, this.goalX, this.goalY, {required super.depth, this.direction});

  Iterable<CoordinatesState> getNeighbors() => [
    CoordinatesState(x, y + 1, goalX, goalY, direction: "up", depth: depth + 1),
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
  double heuristic() => (goalX - x).abs() + (goalY - y).abs().toDouble();

  @override
  bool isGoal() => x == goalX && y == goalY;

  @override
  String hash() => "($x, $y)";
}

void main() {
  final start = CoordinatesState(0, 0, 1000, 1000, depth: 0);
  final result = aStar(start, limit: 3000, verbose: true);
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
