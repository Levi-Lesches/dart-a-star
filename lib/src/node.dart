import "dart:collection";
import "package:meta/meta.dart";

import "state.dart";

/// A node in an A* search.
///
/// Each node is a wrapper around some corresponding [AStarState], [T]. This node caches some
/// calculations about its [state], like [hash] and [heuristic], while also storing tree data,
/// like [depth] and [parent].
///
/// Nodes can be used in [Set]s and [Map]s as they override [hashCode] and [==] in terms of [hash].
/// Nodes can also be compared by [cost] and implement [Comparable] to do so.
///
/// When given a node as a result of running A*, use [reconstructPath] to get the path of states
/// that led to this node. This is especially useful in puzzles or games where the path to a
/// solution is significant, but can be ignored in cases where only the solution itself is needed.
@immutable
class AStarNode<T extends AStarState<T>> implements Comparable<AStarNode<T>> {
  /// The cached result of calling [AStarState.hash] on [state].
  final String hash;

  /// The cached result of calling [AStarState.heuristic] on [state].
  final double heuristic;

  /// The depth of this node in the A* tree. The root has depth 0.
  num get depth => state.depth;

  /// The underlying [AStarState] this node represents.
  final T state;

  /// This node's parent. If this node is the root, [parent] will be null.
  final AStarNode<T>? parent;

  /// Creates an A* node based on an [AStarState].
  AStarNode(this.state, {this.parent})
      : hash = state.hash(),
        heuristic = state.heuristic();

  /// The total cost of this node.
  ///
  /// In f(x) = g(x) + h(x):
  /// - f(x) is the [cost]
  /// - g(x) is the [depth]
  /// - h(x) is the [heuristic].
  ///
  /// Working on cached values allows this cost to be compared cheaply.
  double get cost => depth + heuristic;

  /// Returns the list of [AStarState]s that led to this node during A* search.
  Iterable<T> reconstructPath() {
    final path = Queue<T>();
    path.addFirst(this.state);
    var current = parent;
    while (current != null) {
      path.addFirst(current.state);
      current = current.parent;
    }
    return path;
  }

  /// Expands this node into all its child nodes by calling [AStarState.expand].
  Iterable<AStarNode<T>> expand() sync* {
    for (final newState in state.expand()) {
      yield AStarNode(newState, parent: this);
    }
  }

  @override
  int get hashCode => hash.hashCode;

  @override
  bool operator ==(Object other) => other is AStarNode && hash == other.hash;

  @override
  int compareTo(AStarNode<T> other) => cost.compareTo(other.cost);
}
