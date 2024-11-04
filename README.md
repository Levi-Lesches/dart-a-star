# A* path finding with Dart

A simple but generally applicable [A* algorithm](https://en.wikipedia.org/wiki/A*_search_algorithm) implemented in Dart.

A* is an efficient family of algorithms to find the shortest path from one to
another. This package implements the simplest version, but [other variants](https://en.wikipedia.org/wiki/A*_search_algorithm#Variants)
are available, like [IDA*](https://en.wikipedia.org/wiki/Iterative_deepening_A*).

While A* typically represents paths on a physical grid, it can also be used when problems are
represented in an abstract space. Puzzles are a good example, as each configuration represents
one state, and the transitions between states are all the legal moves. See for example
[the 15/8-puzzle](https://www.geeksforgeeks.org/8-puzzle-problem-using-branch-and-bound).

To use, override the `AStarState` class with a state that describes your problem, and override the following members:

- `double heuristic()`, which estimates how "close" the state is to the goal
- `String hash()`, which generates a unique hash for the state
- `Iterable<T> expand()`, which generates all neighbor states
- `bool isGoal()`, which determines if the state is the end state

Here is an example of a simple state that represents going from `(0, 0)` to `(100, 100)` on a grid.

```dart
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
```

To get your result, pass a starting state to `aStar()`. You can use
`reconstructPath()` on the result to walk back through the search tree and get
the whole path, which is especially helpful for puzzles:

```dart
void main() {
  const start = CoordinatesState(0, 0);
  final result = aStar(start);
  if (result == null) { print("No path"); return; }

  final path = result.reconstructPath();
  for (final step in path) {
    print("Walk to $step");
  }
}
```

This package was originally developed by [Seth Ladd](https://github.com/sethladd) and [Eric Seidel](https://github.com/eseidel). See an (old) running example from them [here](https://levi-lesches.github.io/dart-a-star).

# Contributors

* https://github.com/sethladd
* https://github.com/PedersenThomas
* https://github.com/filiph
* https://github.com/eseidel
