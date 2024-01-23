import "dart:collection";
import "transition.dart";

abstract class AStarState<T extends AStarState<T>> {
  // -------------------- Fields --------------------

  final int depth;
  num? heuristic;
  String? hashed;

  AStarTransition<T>? transition;
  bool isFinalized = false;
  AStarState({required this.transition, required this.depth});

  num get score => heuristic == null
    ? throw StateError("You must call AStarState.finalize() before using its score") 
    : depth + heuristic!;

  // -------------------- A* methods --------------------

  void finalize() {
    heuristic = calculateHeuristic();
    hashed = hash();
    isFinalized = true;
  }

  String hash();
  bool isGoal();
  double calculateHeuristic();
  Iterable<T> getNeighbors();

  Queue<AStarTransition<T>> reconstructPath() {
    final path = Queue<AStarTransition<T>>();
    var current = transition;
    while (current != null) {
      path.addFirst(current);
      current = current.parent.transition;
    }
    return path;
  }

  // -------------------- Common overrides --------------------

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => hashed == null
    ? throw StateError("You must call AStarState.finalize() before using its hash code")
    : hashed.hashCode;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => other is AStarState<T> && other.hashed == hashed;

  @override
  String toString() => hashed ?? "Unfinalized state";

  int compareTo(T other) => score.compareTo(other.score);
}
