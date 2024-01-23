import "package:collection/collection.dart";
import "state.dart";

T? aStar<T extends AStarState<T>>(T start, {bool verbose = false, int limit = 1000}) {
  // A* states _do_ implement [Comparable], but if this comparison function isn't provided,
  // that is checked at runtime for every element, which slows things down.
  // See https://pub.dev/documentation/collection/latest/collection/PriorityQueue/PriorityQueue.html
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
    for (final neighbor in node.getNeighbors()) {
      if (count++ >= limit) {
        if (verbose) print("ABORT: Hit A* limit");  // ignore: avoid_print
        return null;
      }
      if (closed.contains(neighbor)) continue;
      if (opened.contains(neighbor)) continue;
      if (verbose) print("[$count]   Got: ${neighbor.hashed}");  // ignore: avoid_print
      open.add(neighbor);
      opened.add(neighbor);
    }
  }
  return null;
}
