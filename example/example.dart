// ignore_for_file: avoid_print

import "package:a_star/a_star.dart";

class CoordinatesState extends AStarState<CoordinatesState> {
  static const goal = 100;

  final int x;
  final int y;

  const CoordinatesState(this.x, this.y, {super.depth = 0});

  @override
  Iterable<CoordinatesState> expand() => [
    CoordinatesState(x, y + 1, depth: depth + 1),  // down
    CoordinatesState(x, y - 1, depth: depth + 1),  // up
    CoordinatesState(x + 1, y, depth: depth + 1),  // right
    CoordinatesState(x - 1, y, depth: depth + 1),  // left
  ];

  @override
  double heuristic() => ((goal - x).abs() + (goal - y).abs()).toDouble();

  @override
  String hash() => "($x, $y)";

  @override
  bool isGoal() => x == goal && y == goal;
}

void main() {
  const start = CoordinatesState(0, 0);
  final result = aStar(start);
  if (result == null) { print("No path"); return; }

  final path = result.reconstructPath();
  for (final step in path) {
    print("Walk to $step");
  }
}
