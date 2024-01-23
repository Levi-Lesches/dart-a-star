import "dart:collection";
import "transition.dart";

/// A state used in an A* algorithm. 
/// 
/// This class mainly exists to require three important functions:
/// - [hash]: Compute a short and unique hash to represent this state
/// - [calculateHeuristic]: Calculates the estimated distance to the goal state
/// - [getNeighbors]: Gets all possible neighbor states reachable from this one
/// 
/// When creating a state to be used in A*, be sure to call [finalize] first. This will
/// cache some fields for the A* algorithm to improve performance (but it is mandatory).
/// Note that [finalize] is **not** called automatically so that you can implement
/// [getNeighbors] in terms of a `copyWith` function, make a small change, _then_ call [finalize].
/// 
/// Each [AStarState] has an [AStarTransition] associated with it to describe how to get to this
/// state from its parent. After getting a result from [aStar], use [reconstructPath] to get a list
/// of [AStarTransition]s describing how to get from the start state to the goal state. 
abstract class AStarState<T extends AStarState<T>> {
  // -------------------- Bookkeeping Fields --------------------

  /// How many steps the algorithm had to take to get to this state.
  /// 
  /// Generally, this should start at 0 and increment by 1 when a state expands. 
  final int depth;
  /// The cached heuristic, as determined by [calculateHeuristic]. Null until [finalize] is called.
  num? heuristic;
  /// The unique hash, cached, as determined by [hashed]. Null until [finalize] is called.
  String? hashed;

  /// The transition from the previous state, if any. If null, this is the root state.
  AStarTransition<T>? transition;
  /// Whether this state has been finalized. See [finalize].
  bool isFinalized = false;
  /// Constructs a new A* state. 
  AStarState({required this.transition, required this.depth});

  /// The actual cost of this state, by combining [depth] and [heuristic].
  num get cost => heuristic == null
    ? throw StateError("You must call AStarState.finalize() before using its score") 
    : depth + heuristic!;

  // -------------------- A* methods --------------------

  /// Computes any expensive fields, such as the [heuristic] and [hash], once and caches them.
  /// 
  /// This function must be called before A* runs. This includes the root state and every state
  /// spawned in [getNeighbors]. This function isn't called in the constructor to give you the
  /// opportunity to copy a parent state, make changes to it, _then_ finalize it. This is especially
  /// helpful in cases where the initialization logic is non-trivial, and it's simpler to just copy
  /// an existing state and only modify a small part of it. 
  void finalize() {
    heuristic = calculateHeuristic();
    hashed = hash();
    isFinalized = true;
  }

  /// Determines a unique hash to represent this state. 
  /// 
  /// This hash is used in [Set]s, [Map]s (as [hashCode]) and during debugging.
  String hash();
  /// Whether this state is the goal state.
  bool isGoal();
  /// The heuristic (estimated cost) of this state. See https://en.wikipedia.org/wiki/Heuristic_(computer_science).
  double calculateHeuristic();

  /// Gets all possible states reachable from this state. 
  /// 
  /// It is okay to return cyclic paths from this function. In a scenario with reversible actions,
  /// it is possible to go from, for example, `State A` to `State B`, and from `State B` to 
  /// `State A`. It is okay to return both states when needed, as the cycle will be detected
  /// by comparing each state's [hash] values. 
  /// 
  /// Be sure to: 
  /// - increment the [depth] of each neighbor
  /// - pass a [AStarTransition] that represents how to get to the neighbor
  /// - call [finalize] on the neighbor so it can be used in A*
  Iterable<T> getNeighbors();

  /// Recursively explores this state's [transition] to find a path from the root state to here.
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

  /// Compares two states by cost.
  int compareTo(T other) => cost.compareTo(other.cost);
}
