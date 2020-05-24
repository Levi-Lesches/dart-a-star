/*
 Copyright 2012 Seth Ladd

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

library a_star;

import 'dart:async';
import 'dart:collection';

/// The A* class works on any class that implements the [Graph] interface.
abstract class Graph<T extends Node<T>> {
  /// Returns an [Iterable] of all the nodes of the [Graph]. This is accessed
  /// only during the setup phase, so it's not critical to optimize this.
  ///
  /// If you have a 2D [List] of Lists called [:tiles:], for example, you can
  /// simply do:
  ///     get allNodes => tiles.expand((row) => row);
  Iterable<T> get allNodes;

  /// Given two adjancent Nodes, returns the cost (distance) from [a] to [b]
  /// (the direction can matter). Returns [:null:] if [b] is not reachable from
  /// [a].
  num getDistance(T a, T b);

  /// Given two nodes (not necessarily adjancent), returns an estimate of the
  /// distance between them. The better the estimate, the more direct is
  /// the search. But better estimates also often mean slower performance.
  /// (The search works even if the return from the heuristic function is
  /// constant. The A* search becomes breadth-first search.)
  ///
  /// Optimize this first.
  num getHeuristicDistance(T a, T b);

  /// Given a node, return all connected nodes.
  Iterable<T> getNeighboursOf(T node);
}

/// Mixin class with which the [Graph]'s nodes should be extended.
///
///     class MyTraversableTile extends MyTile with Node<MyTraversableTile> { /* ... */ }
mixin Node<T extends Node<T>> {
  num _f;
  num _g;
  T _parent;
  bool _isInOpenSet = false; // Much faster than finding nodes in iterables.
  bool _isInClosedSet = false;
}

/// The A* Star algorithm itself. Instantiated with a [Graph] (e.g., a map).
class AStar<T extends Node<T>> {
  final Graph<T> graph;

  AStar(Graph<T> this.graph);

  // TODO: cacheNeighbours option - tells AStar that the graph is not changing
  // in terms of which nodes are neighbouring which nodes
  // TODO: cacheDistances option - tells AStar that the graph is not changing
  // in terms of traversal costs between nodes.

  bool _zeroed = true;

  final Queue<T> NO_VALID_PATH = Queue<T>();

  void _zeroNodes() {
    for (final node in graph.allNodes) {
      node
        .._isInClosedSet = false
        .._isInOpenSet = false
        .._parent = null;
      // No need to zero out f and g, A* doesn't depend on them being set
      // to 0 (it overrides them on first access to each node).
    }
    _zeroed = true;
  }

  /// Perform A* search from [start] to [goal] asynchronously.
  ///
  /// Returns a [Future] that completes with the path [Queue]. (Empty [Queue]
  /// means no valid path from start to goal was found.
  ///
  /// TODO: Optional weighing for suboptimal, but faster path finding.
  /// http://en.wikipedia.org/wiki/A*_search_algorithm#Bounded_relaxation
  Future<Queue<T>> findPath(T start, T goal) =>
      Future<Queue<T>>(() => findPathSync(start, goal));

  /// Perform A* search from [start] to [goal].
  ///
  /// Returns empty [Queue] when there is no path between the two nodes.
  ///
  /// TODO: Optional weighing for suboptimal, but faster path finding.
  /// http://en.wikipedia.org/wiki/A*_search_algorithm#Bounded_relaxation
  Queue<T> findPathSync(T start, T goal) {
    if (!_zeroed) {
      _zeroNodes();
    }

    final open = Queue<T>();
    T lastClosed;

    open.add(start);
    start
      .._isInOpenSet = true
      .._f = -1.0
      .._g = -1.0;

    _zeroed = false;

    while (open.isNotEmpty) {
      // Find node with best (lowest) cost.
      var currentNode = open.fold<T>(null, (a, b) {
        if (a == null) {
          return b;
        }
        return a._f < b._f ? a : b;
      });

      if (currentNode == goal) {
        // queues are more performant when adding to the front
        final path = Queue<T>()..add(goal);

        // Go up the chain to recreate the path
        while (currentNode._parent != null) {
          currentNode = currentNode._parent;
          path.addFirst(currentNode);
        }

        return path;
      }

      open.remove(currentNode);
      currentNode._isInOpenSet = false; // Much faster than finding nodes
      // in iterables.
      lastClosed = currentNode;
      currentNode._isInClosedSet = true;

      for (final candidate in graph.getNeighboursOf(currentNode)) {
        final distance = graph.getDistance(currentNode, candidate);
        if (distance != null || (candidate == goal)) {
          // If the new node is open or the new node is our destination.
          if (candidate._isInClosedSet) {
            continue;
          }

          if (!candidate._isInOpenSet) {
            candidate
              .._parent = lastClosed
              .._g = currentNode._g + distance;
            final h = graph.getHeuristicDistance(candidate, goal);
            candidate._f = candidate._g + h;

            open.add(candidate);
            candidate._isInOpenSet = true;
          }
        }
      }
    }

    // No path found.
    return NO_VALID_PATH;
  }
}
