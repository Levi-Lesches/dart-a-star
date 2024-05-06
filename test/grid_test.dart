import "dart:math";
import "package:test/test.dart";
import "package:a_star/a_star.dart";

class CoordinatesState extends AStarState<CoordinatesState> {
  final int x;
  final int y;
  final int goalX;
  final int goalY;
  final String? direction;
  CoordinatesState(this.x, this.y, this.goalX, this.goalY, {this.direction});

  Iterable<CoordinatesState> getNeighbors() => [
    CoordinatesState(x, y + 1, goalX, goalY, direction: "up"),
    CoordinatesState(x, y - 1, goalX, goalY, direction: "down"),
    CoordinatesState(x + 1, y, goalX, goalY, direction: "right"),
    CoordinatesState(x - 1, y, goalX, goalY, direction: "left"),
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

void main() => test("Simple path should be exactly 21 spaces", () {
  final start = CoordinatesState(0, 0, 10, 10);
  final result = aStar(start);
  expect(result, isNotNull); if (result == null) return;
  final path = result.reconstructPath();
  expect(path, isNotEmpty);
  expect(path, hasLength(21));
  final origin = path.first;
  final destination = path.last;
  expect(origin.x, start.x);
  expect(origin.y, start.y);
  expect(destination.x, start.goalX);
  expect(destination.y, start.goalY);
});
