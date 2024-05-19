// ignore_for_file: avoid_print

import "package:collection/collection.dart";
import "node.dart";
import "state.dart";

/// Runs the A* algorithm on the given state, returning the first goal state, or null. 
/// 
/// If [verbose] is true, this will print debug info about which states were expanded during the 
/// search. Once the algorithm reaches [limit] states (1,000 by default), it returns null to 
/// indicate failure.
/// 
/// To replay the path from the [state] to the goal state, use [AStarNode.reconstructPath].
AStarNode<T>? aStar<T extends AStarState<T>>(T state, {bool verbose = false, int limit = 1000}) {
  final startNode = AStarNode(state);
  final opened = <AStarNode<T>>{startNode};
  final closed = <AStarNode<T>>{};
  final open = PriorityQueue<AStarNode<T>>()..add(startNode);
  var count = 0;

  while (open.isNotEmpty) {
    final node = open.removeFirst();
    if (verbose) print("[$count] Exploring: ${node.hash}");
    if (node.state.isGoal()) return node;
    opened.remove(node);
    closed.add(node);
    if (count++ >= limit) {
      if (verbose) print("ABORT: Hit A* limit of $limit nodes");
      return null;
    }
    for (final newNode in node.expand()) {
      if (closed.contains(newNode) || opened.contains(newNode)) continue;
      if (verbose) print("[$count]   Got: ${newNode.hash}");
      open.add(newNode);
      opened.add(newNode);
    }
  }
  return null;
}
