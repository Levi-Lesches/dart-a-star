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

import 'dart:collection';
import 'dart:async';
import 'package:collection/collection.dart';

/**
 * The A* class works on any class that implements the [Graph] interface.
 */
abstract class Graph<T extends Node> {
  /**
   * Returns an [Iterable] of all the nodes of the [Graph]. This is accessed
   * only during the setup phase, so it's not critical to optimize this.
   *
   * If you have a 2D [List] of Lists called [:tiles:], for example, you can
   * simply do:
   *     get allNodes => tiles.expand((row) => row);
   */
  Iterable<T> get allNodes;

  /**
   * Given two adjancent Nodes, returns the cost (distance) from [a] to [b] (the
   * direction can matter). Returns [:null:] if [b] is not reachable from [a].
   */
  num getDistance(T a, T b);

  /**
   * Given two nodes (not necessarily adjancent), returns an estimate of the
   * distance between them. The better the estimate, the more direct is
   * the search. But better estimates also often mean slower performance.
   * (The search works even if the return from the heuristic function is
   * constant. The A* search becomes breadth-first search.)
   *
   * Optimize this first.
   */
  num getHeuristicDistance(T a, T b);

  /**
   * Given a node, return all connected nodes.
   */
  Iterable<T> getNeighboursOf(T node);
}

/**
 * Mixin class with which the [Graph]'s nodes should be extended. For example:
 *
 *     class MyMapTile extends Object with Node { /* ... */ }
 *
 * Or, in some cases, your graph nodes will already be extending something
 * else, so:
 *
 *     class MyTraversableTile extends MyTile with Node { /* ... */ }
 */
class Node extends Object {
  num _f;
  num _g;
  Node _parent;
  bool _isInOpenSet = false;  // Much faster than finding nodes in iterables.
  bool _isInClosedSet = false;
}

/**
 * The A* Star algorithm itself. Instantiated with a [Graph] (e.g., a map).
 */
class AStar<T extends Node> {
  final Graph<T> graph;

  AStar(Graph<T> this.graph);
  // TODO: cacheNeighbours option - tells AStar that the graph is not changing
  // in terms of which nodes are neighbouring which nodes
  // TODO: cacheDistances option - tells AStar that the graph is not changing
  // in terms of traversal costs between nodes.

  final PriorityQueue<T> _open = new HeapPriorityQueue<T>((l, r) => l._f.compareTo(r._f));
  bool _zeroed = true;

  final Queue<T> NO_VALID_PATH = new Queue<T>();

  void _zeroNodes() {
    graph.allNodes.forEach((Node node) {
      node._isInClosedSet = false;
      node._isInOpenSet = false;
      node._parent = null;
      // No need to zero out f and g, A* doesn't depend on them being set
      // to 0 (it overrides them on first access to each node).
    });
    _zeroed = true;
  }

  /**
   * Perform A* search from [start] to [goal] asynchronously.
   *
   * Returns a [Future] that completes with the path [Queue]. (Empty [Queue]
   * means no valid path from start to goal was found.
   *
   * TODO: Optional weighing for suboptimal, but faster path finding.
   * http://en.wikipedia.org/wiki/A*_search_algorithm#Bounded_relaxation
   */
  Future<Queue<T>> findPath(T start, T goal) {
    return new Future<Queue<T>>(() => findPathSync(start, goal));
  }

  /**
   * Perform A* search from [start] to [goal].
   *
   * Returns empty [Queue] when there is no path between the two nodes.
   *
   * TODO: Optional weighing for suboptimal, but faster path finding.
   * http://en.wikipedia.org/wiki/A*_search_algorithm#Bounded_relaxation
   */
  Queue<T> findPathSync(T start, T goal) {
    if (!_zeroed) _zeroNodes();

    _open.clear();
    _open.add(start);
    start._isInOpenSet = true;
    start._f = -1.0;
    start._g = -1.0;

    _zeroed = false;

    while (_open.isNotEmpty) {
      // Find node with best (lowest) cost.
      T currentNode = _open.removeFirst();

      if (currentNode == goal) {
        // queues are more performant when adding to the front
        final Queue<T> path = new Queue<T>();
        path.add(goal);

        // Go up the chain to recreate the path
        while (currentNode._parent != null) {
          currentNode = currentNode._parent;
          path.addFirst(currentNode);
        }

        return path;
      }

      currentNode._isInOpenSet = false;  // Much faster than finding nodes
                                         // in iterables.
      currentNode._isInClosedSet = true;

      for (final T candidate in graph.getNeighboursOf(currentNode)) {
        num distance = graph.getDistance(currentNode, candidate);
        if (distance != null) {
          // If the new node is open or the new node is our destination.
          if (candidate._isInClosedSet) {
            continue;
          }

          if (!candidate._isInOpenSet || candidate._g > currentNode._g + distance) {
            candidate._parent = currentNode;

            candidate._g = currentNode._g + distance;
            num h = graph.getHeuristicDistance(candidate, goal);
            candidate._f = candidate._g + h;

            _open.add(candidate);
            candidate._isInOpenSet = true;
          }
        }
      }
    }

    // No path found.
    return NO_VALID_PATH;
  }
}
