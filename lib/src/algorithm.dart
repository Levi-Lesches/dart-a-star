import "package:collection/collection.dart";
import "state.dart";

/// Runs the A* algorithm on the given state, returning the first goal state, or null. 
/// 
/// If [verbose] is true, this will print debug info about which states were expanded during the 
/// search. Once the algorithm reaches [limit] states (1,000 by default), it returns null to 
/// indicate failure.
/// 
/// To replay the path from the [start] to the goal state, use [AStarState.reconstructPath].
T? aStar<T extends AStarState<T>>(T start, {bool verbose = false, int limit = 1000}) {
  if (!start.isFinalized) throw StateError("A* State must be finalized");
  final open = PriorityQueue<T>((a, b) => a.compareTo(b))..add(start);
  final opened = <T>{start};
  final closed = <T>{};
  var count = 0;
  
  while (open.isNotEmpty) {
    final node = open.removeFirst();
    if (verbose) print("[$count] Exploring: ${node.hashed}");  // ignore: avoid_print
    opened.remove(node);
    closed.add(node);
    if (node.isGoal()) {
      return node;
    }
    if (count++ >= limit) {
      if (verbose) print("ABORT: Hit A* limit");  // ignore: avoid_print
      return null;
    }
    for (final neighbor in node.getNeighbors()) {
      if (closed.contains(neighbor)) continue;
      if (opened.contains(neighbor)) continue;
      if (verbose) print("[$count]   Got: ${neighbor.hashed}");  // ignore: avoid_print
      open.add(neighbor);
      opened.add(neighbor);
    }
  }
  return null;
}
