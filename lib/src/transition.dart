import "state.dart";

/// Describes how to get from one [AStarState] to another. 
/// 
/// Subclass this in your application to provide more context. For example, in a grid, just the
/// position of each cell may suffice, but in a game, you may wish to provide the move or action
/// played to get from state to state. For navigation, you may want to provide directions, etc. 
class AStarTransition<T extends AStarState<T>> {
  /// The parent state. 
  final T parent;
  /// A const constructor
  const AStarTransition(this.parent);
}
