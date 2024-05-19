/// A state used in an A* algorithm. 
/// 
/// This class mainly exists to require three important functions:
/// - [hash]: Compute a short and unique hash to represent this state
/// - [heuristic]: Calculates the estimated distance to the goal state
/// - [expand]: Gets all possible neighbor states reachable from this one
abstract class AStarState<T extends AStarState<T>> {
  final int depth = 0;
  
  /// The heuristic (estimated cost) of this state. See https://en.wikipedia.org/wiki/Heuristic_(computer_science).
  double heuristic();
  
  /// Determines a unique hash to represent this state. 
  /// 
  /// This hash is used in [Set]s, [Map]s (as [hashCode]) and during debugging.
  String hash();

  /// Gets all possible states reachable from this state. 
  /// 
  /// It is okay to return cyclic paths from this function. In a scenario with reversible actions,
  /// it is possible to go from, for example, `State A` to `State B`, and from `State B` to 
  /// `State A`. It is okay to return both states when needed, as the cycle will be detected
  /// by comparing each state's [hash] values. 
  Iterable<T> expand(); 

  /// Whether this state is the goal state.
  bool isGoal();
}
